import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:dube/models/customer.dart';
import 'package:dube/models/customer_reliability.dart';
import 'package:dube/models/debt_history.dart';
import 'package:dube/models/debt_record.dart';
import 'package:dube/models/debtor_entry.dart';
import 'package:dube/models/shop_note.dart';
import 'package:dube/utils/formatters.dart';

class DbHelper {
  DbHelper._();

  static final DbHelper instance = DbHelper._();

  static const _dbName = 'dube.db';
  static const _dbVersion = 3;

  static const tableCustomers = 'Customers';
  static const tableDebts = 'DebtRecords';
  static const tableHistory = 'DebtHistory';
  static const tableShopNotes = 'shop_notes';

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null && existing.isOpen) return existing;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCustomers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableDebts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        items_description TEXT NOT NULL,
        total_amount REAL NOT NULL,
        amount_paid REAL DEFAULT 0.0,
        currency TEXT NOT NULL DEFAULT 'ETB',
        due_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES $tableCustomers (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        debt_id INTEGER NOT NULL,
        action_type TEXT NOT NULL,
        note TEXT,
        amount_change REAL,
        new_due_date TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (debt_id) REFERENCES $tableDebts (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_customers_phone ON $tableCustomers (phone)',
    );
    await db.execute(
      'CREATE INDEX idx_debts_customer ON $tableDebts (customer_id)',
    );
    await db.execute(
      'CREATE INDEX idx_debts_status ON $tableDebts (status)',
    );
    await db.execute(
      'CREATE INDEX idx_history_debt ON $tableHistory (debt_id)',
    );

    await _createNotesTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createNotesTable(db);
    }
    if (oldVersion < 3) {
      try {
        await db.execute(
          'ALTER TABLE $tableDebts ADD COLUMN currency TEXT NOT NULL DEFAULT "ETB"',
        );
      } catch (_) {}
    }
  }

  Future<void> _createNotesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableShopNotes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        is_todo INTEGER NOT NULL DEFAULT 0,
        is_done INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_pinned ON $tableShopNotes (is_pinned, updated_at)',
    );
  }

  Future<void> refreshOverdueStatuses() async {
    final db = await database;
    final rows = await db.query(
      tableDebts,
      where: 'status != ?',
      whereArgs: [DebtStatus.settled],
    );
    final batch = db.batch();
    for (final row in rows) {
      final debt = DebtRecord.fromMap(row);
      final nextStatus =
          debt.isPastDue ? DebtStatus.overdue : DebtStatus.active;
      if (nextStatus != debt.status) {
        batch.update(
          tableDebts,
          {'status': nextStatus},
          where: 'id = ?',
          whereArgs: [debt.id],
        );
      }
    }
    await batch.commit(noResult: true);
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await database;
    final rows = await db.query(
      tableCustomers,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Customer.fromMap(rows.first);
  }

  Future<Customer?> getCustomerByPhone(String phone) async {
    final db = await database;
    final rows = await db.query(
      tableCustomers,
      where: 'phone = ?',
      whereArgs: [phone.trim()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Customer.fromMap(rows.first);
  }

  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return db.insert(tableCustomers, customer.toMap());
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return db.update(
      tableCustomers,
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<List<DebtRecord>> getDebtsForCustomer(int customerId) async {
    final db = await database;
    final rows = await db.query(
      tableDebts,
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: "CASE status WHEN 'overdue' THEN 0 WHEN 'active' THEN 1 ELSE 2 END, due_date ASC",
    );
    return rows.map(DebtRecord.fromMap).toList();
  }

  Future<DebtRecord?> getDebtById(int id) async {
    final db = await database;
    final rows = await db.query(
      tableDebts,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DebtRecord.fromMap(rows.first);
  }

  Future<List<DebtHistory>> getHistoryForDebt(int debtId) async {
    final db = await database;
    final rows = await db.query(
      tableHistory,
      where: 'debt_id = ?',
      whereArgs: [debtId],
      orderBy: 'created_at DESC, id DESC',
    );
    return rows.map(DebtHistory.fromMap).toList();
  }

  Future<List<DebtHistoryEntry>> getHistoryForCustomer(int customerId) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT h.*, d.items_description, d.currency
      FROM $tableHistory h
      INNER JOIN $tableDebts d ON d.id = h.debt_id
      WHERE d.customer_id = ?
      ORDER BY h.created_at DESC, h.id DESC
      ''',
      [customerId],
    );
    return rows.map((row) {
      return DebtHistoryEntry(
        history: DebtHistory.fromMap(row),
        itemsDescription: row['items_description'] as String,
        debtId: row['debt_id'] as int,
        currency: (row['currency'] as String?)?.trim().isNotEmpty == true
            ? (row['currency'] as String).trim()
            : 'ETB',
      );
    }).toList();
  }

  Future<double> getCustomerOutstanding(int customerId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(total_amount - amount_paid), 0) AS outstanding
      FROM $tableDebts
      WHERE customer_id = ? AND status != ?
      ''',
      [customerId, DebtStatus.settled],
    );
    return (result.first['outstanding'] as num?)?.toDouble() ?? 0;
  }

  Future<DashboardStats> getDashboardStats() async {
    await refreshOverdueStatuses();
    final db = await database;

    final totalRows = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(total_amount - amount_paid), 0) AS total
      FROM $tableDebts
      WHERE status != ?
      ''',
      [DebtStatus.settled],
    );
    final overdueRows = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM $tableDebts
      WHERE status = ?
      ''',
      [DebtStatus.overdue],
    );
    final borrowerRows = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT customer_id) AS count
      FROM $tableDebts
      WHERE status != ?
      ''',
      [DebtStatus.settled],
    );

    return DashboardStats(
      totalActiveDube: (totalRows.first['total'] as num?)?.toDouble() ?? 0,
      overdueAccounts: (overdueRows.first['count'] as num?)?.toInt() ?? 0,
      totalBorrowers: (borrowerRows.first['count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<DebtorEntry>> getAllDebtorEntries({
    bool includeSettled = true,
  }) async {
    await refreshOverdueStatuses();
    final db = await database;
    final whereClause = includeSettled ? '' : 'WHERE d.status != ?';
    final whereArgs = includeSettled ? <Object>[] : [DebtStatus.settled];

    final rows = await db.rawQuery(
      '''
      SELECT
        d.id AS d_id,
        d.customer_id AS d_customer_id,
        d.items_description AS d_items_description,
        d.total_amount AS d_total_amount,
        d.amount_paid AS d_amount_paid,
        d.currency AS d_currency,
        d.due_date AS d_due_date,
        d.created_at AS d_created_at,
        d.status AS d_status,
        c.id AS c_id,
        c.name AS c_name,
        c.phone AS c_phone,
        c.notes AS c_notes
      FROM $tableDebts d
      INNER JOIN $tableCustomers c ON c.id = d.customer_id
      $whereClause
      ORDER BY
        CASE d.status
          WHEN 'overdue' THEN 0
          WHEN 'active' THEN 1
          ELSE 2
        END,
        CASE WHEN d.status = 'settled' THEN d.id ELSE 0 END DESC,
        d.due_date ASC,
        d.id DESC
      ''',
      whereArgs,
    );

    return rows.map((row) {
      return DebtorEntry(
        customer: Customer(
          id: row['c_id'] as int,
          name: row['c_name'] as String,
          phone: row['c_phone'] as String,
          notes: row['c_notes'] as String?,
        ),
        debt: DebtRecord(
          id: row['d_id'] as int,
          customerId: row['d_customer_id'] as int,
          itemsDescription: row['d_items_description'] as String,
          totalAmount: (row['d_total_amount'] as num).toDouble(),
          amountPaid: (row['d_amount_paid'] as num?)?.toDouble() ?? 0,
          currency: (row['d_currency'] as String?)?.trim().isNotEmpty == true
              ? (row['d_currency'] as String).trim()
              : 'ETB',
          dueDate: row['d_due_date'] as String,
          createdAt: row['d_created_at'] as String,
          status: row['d_status'] as String,
        ),
      );
    }).toList();
  }

  Future<List<DebtorEntry>> getOutstandingDebts() async {
    return getAllDebtorEntries(includeSettled: false);
  }

  Future<CustomerReliabilityStats> getCustomerReliabilityStats(
    int customerId,
  ) async {
    await refreshOverdueStatuses();
    final db = await database;

    final debtsRows = await db.query(
      tableDebts,
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );

    if (debtsRows.isEmpty) {
      return CustomerReliabilityStats(
        customerId: customerId,
        settledDebtsCount: 0,
        activeDebtsCount: 0,
        overdueDebtsCount: 0,
        onTimeSettledCount: 0,
        totalLifetimeBorrowed: 0.0,
        totalLifetimeRepaid: 0.0,
      );
    }

    int settledCount = 0;
    int activeCount = 0;
    int overdueCount = 0;
    double totalBorrowed = 0.0;
    double totalRepaid = 0.0;
    final settledDebtIds = <int>[];
    final settledDebtDueMap = <int, DateTime>{};

    for (final row in debtsRows) {
      final status = row['status'] as String;
      final total = (row['total_amount'] as num).toDouble();
      final paid = (row['amount_paid'] as num?)?.toDouble() ?? 0.0;
      final id = row['id'] as int;
      final dueDate = DateTime.parse(row['due_date'] as String);

      totalBorrowed += total;
      totalRepaid += paid;

      if (status == DebtStatus.settled) {
        settledCount++;
        settledDebtIds.add(id);
        settledDebtDueMap[id] = dueDate;
      } else if (status == DebtStatus.overdue) {
        overdueCount++;
      } else {
        activeCount++;
      }
    }

    int onTimeCount = 0;
    if (settledDebtIds.isNotEmpty) {
      final placeholders = List.filled(settledDebtIds.length, '?').join(',');
      final historyRows = await db.query(
        tableHistory,
        where: 'debt_id IN ($placeholders) AND action_type = ?',
        whereArgs: [...settledDebtIds, HistoryAction.settled],
      );

      final settledTimeMap = <int, DateTime>{};
      for (final h in historyRows) {
        final dId = h['debt_id'] as int;
        final settledAt = DateTime.parse(h['created_at'] as String);
        if (!settledTimeMap.containsKey(dId) ||
            settledAt.isBefore(settledTimeMap[dId]!)) {
          settledTimeMap[dId] = settledAt;
        }
      }

      for (final dId in settledDebtIds) {
        final dueDate = settledDebtDueMap[dId]!;
        final settledAt = settledTimeMap[dId];
        if (settledAt != null) {
          final settledDay =
              DateTime(settledAt.year, settledAt.month, settledAt.day);
          final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
          if (!settledDay.isAfter(dueDay)) {
            onTimeCount++;
          }
        } else {
          onTimeCount++;
        }
      }
    }

    return CustomerReliabilityStats(
      customerId: customerId,
      settledDebtsCount: settledCount,
      activeDebtsCount: activeCount,
      overdueDebtsCount: overdueCount,
      onTimeSettledCount: onTimeCount,
      totalLifetimeBorrowed: totalBorrowed,
      totalLifetimeRepaid: totalRepaid,
    );
  }

  Future<CustomerReliabilityStats?> getCustomerReliabilityStatsByPhone(
    String phone,
  ) async {
    final customer = await getCustomerByPhone(phone);
    if (customer == null || customer.id == null) return null;
    return getCustomerReliabilityStats(customer.id!);
  }

  Future<int> createDube({
    required String name,
    required String phone,
    required String itemsDescription,
    required double totalAmount,
    required DateTime dueDate,
    String currency = 'ETB',
    String? notes,
  }) async {
    final db = await database;
    return db.transaction((txn) async {
      final existing = await txn.query(
        tableCustomers,
        where: 'phone = ?',
        whereArgs: [phone.trim()],
        limit: 1,
      );

      late final int customerId;
      if (existing.isNotEmpty) {
        customerId = existing.first['id'] as int;
        await txn.update(
          tableCustomers,
          {
            'name': name.trim(),
            if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
          },
          where: 'id = ?',
          whereArgs: [customerId],
        );
      } else {
        customerId = await txn.insert(tableCustomers, {
          'name': name.trim(),
          'phone': phone.trim(),
          'notes': notes?.trim(),
        });
      }

      final now = DateTime.now().toIso8601String();
      final dueIso = dueDate.toIso8601String();
      final status =
          isPastDueDate(dueDate) ? DebtStatus.overdue : DebtStatus.active;
      final cleanCurrency = currency.trim().isEmpty ? 'ETB' : currency.trim();

      final debtId = await txn.insert(tableDebts, {
        'customer_id': customerId,
        'items_description': itemsDescription.trim(),
        'total_amount': totalAmount,
        'amount_paid': 0.0,
        'currency': cleanCurrency,
        'due_date': dueIso,
        'created_at': now,
        'status': status,
      });

      await txn.insert(tableHistory, {
        'debt_id': debtId,
        'action_type': HistoryAction.created,
        'note': 'New Dube recorded',
        'amount_change': totalAmount,
        'new_due_date': dueIso,
        'created_at': now,
      });

      return debtId;
    });
  }

  Future<DebtRecord> recordPayment({
    required int debtId,
    required double amount,
    String? note,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Payment amount must be greater than zero.');
    }

    final db = await database;
    return db.transaction((txn) async {
      final rows = await txn.query(
        tableDebts,
        where: 'id = ?',
        whereArgs: [debtId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw StateError('Debt record not found.');
      }

      final debt = DebtRecord.fromMap(rows.first);
      if (debt.isSettled) {
        throw StateError('This Dube is already settled.');
      }

      final remaining = debt.remainingBalance;
      if (amount - remaining > 0.005) {
        throw ArgumentError(
          'Payment cannot exceed the remaining balance of ${formatEtb(remaining, debt.currency)}.',
        );
      }

      final newPaid = debt.amountPaid + amount;
      final settled = (debt.totalAmount - newPaid) <= 0.005;
      final now = DateTime.now().toIso8601String();
      final nextStatus = settled
          ? DebtStatus.settled
          : (debt.isPastDue ? DebtStatus.overdue : DebtStatus.active);

      await txn.update(
        tableDebts,
        {
          'amount_paid': newPaid,
          'status': nextStatus,
        },
        where: 'id = ?',
        whereArgs: [debtId],
      );

      await txn.insert(tableHistory, {
        'debt_id': debtId,
        'action_type':
            settled ? HistoryAction.settled : HistoryAction.partialPayment,
        'note': note?.trim().isNotEmpty == true
            ? note!.trim()
            : (settled ? 'Paid in full' : 'Partial payment recorded'),
        'amount_change': amount,
        'created_at': now,
      });

      return debt.copyWith(amountPaid: newPaid, status: nextStatus);
    });
  }

  Future<DebtRecord> extendDueDate({
    required int debtId,
    required DateTime newDueDate,
    String? note,
  }) async {
    final db = await database;
    return db.transaction((txn) async {
      final rows = await txn.query(
        tableDebts,
        where: 'id = ?',
        whereArgs: [debtId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw StateError('Debt record not found.');
      }

      final debt = DebtRecord.fromMap(rows.first);
      if (debt.isSettled) {
        throw StateError('Cannot extend a settled Dube.');
      }

      final now = DateTime.now().toIso8601String();
      final dueIso = newDueDate.toIso8601String();
      final nextStatus =
          isPastDueDate(newDueDate) ? DebtStatus.overdue : DebtStatus.active;

      await txn.update(
        tableDebts,
        {
          'due_date': dueIso,
          'status': nextStatus,
        },
        where: 'id = ?',
        whereArgs: [debtId],
      );

      await txn.insert(tableHistory, {
        'debt_id': debtId,
        'action_type': HistoryAction.extendedDeadline,
        'note': note?.trim().isNotEmpty == true
            ? note!.trim()
            : 'Due date extended to ${formatDate(newDueDate)}',
        'new_due_date': dueIso,
        'created_at': now,
      });

      return debt.copyWith(dueDate: dueIso, status: nextStatus);
    });
  }

  Future<DebtRecord> settleDebt({
    required int debtId,
    String? note,
  }) async {
    final db = await database;
    return db.transaction((txn) async {
      final rows = await txn.query(
        tableDebts,
        where: 'id = ?',
        whereArgs: [debtId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw StateError('Debt record not found.');
      }

      final debt = DebtRecord.fromMap(rows.first);
      if (debt.isSettled) {
        throw StateError('This Dube is already settled.');
      }

      final remaining = debt.remainingBalance;
      final newPaid = debt.totalAmount;
      final now = DateTime.now().toIso8601String();

      await txn.update(
        tableDebts,
        {
          'amount_paid': newPaid,
          'status': DebtStatus.settled,
        },
        where: 'id = ?',
        whereArgs: [debtId],
      );

      await txn.insert(tableHistory, {
        'debt_id': debtId,
        'action_type': HistoryAction.settled,
        'note': note?.trim().isNotEmpty == true
            ? note!.trim()
            : 'Settled in full (${formatEtb(remaining, debt.currency)})',
        'amount_change': remaining,
        'created_at': now,
      });

      return debt.copyWith(amountPaid: newPaid, status: DebtStatus.settled);
    });
  }

  Future<DebtRecord> updateDebt({
    required int debtId,
    required String itemsDescription,
    required double totalAmount,
    String? currency,
    DateTime? dueDate,
    String? note,
  }) async {
    final db = await database;
    return db.transaction((txn) async {
      final rows = await txn.query(
        tableDebts,
        where: 'id = ?',
        whereArgs: [debtId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw StateError('Debt record not found.');
      }

      final debt = DebtRecord.fromMap(rows.first);
      final debtCurr = debt.currency;
      if (totalAmount < debt.amountPaid - 0.005) {
        throw ArgumentError(
          'Total amount cannot be less than the already paid amount of ${formatEtb(debt.amountPaid, debtCurr)}.',
        );
      }

      final newDue = dueDate ?? debt.dueDateTime;
      final dueIso = newDue.toIso8601String();
      final remaining = totalAmount - debt.amountPaid;
      final isSettled = remaining <= 0.005;
      final nextStatus = isSettled
          ? DebtStatus.settled
          : (isPastDueDate(newDue) ? DebtStatus.overdue : DebtStatus.active);

      final newCurrency = currency?.trim().isNotEmpty == true
          ? currency!.trim()
          : debt.currency;

      final amountDiff = totalAmount - debt.totalAmount;
      final now = DateTime.now().toIso8601String();

      await txn.update(
        tableDebts,
        {
          'items_description': itemsDescription.trim(),
          'total_amount': totalAmount,
          'currency': newCurrency,
          'due_date': dueIso,
          'status': nextStatus,
        },
        where: 'id = ?',
        whereArgs: [debtId],
      );

      final defaultNote = amountDiff != 0
          ? 'Total adjusted from ${formatEtb(debt.totalAmount, debtCurr)} to ${formatEtb(totalAmount, newCurrency)}'
          : 'Dube details updated';

      await txn.insert(tableHistory, {
        'debt_id': debtId,
        'action_type': HistoryAction.adjusted,
        'note': note?.trim().isNotEmpty == true ? note!.trim() : defaultNote,
        'amount_change': amountDiff != 0 ? amountDiff : null,
        'new_due_date': dueIso != debt.dueDate ? dueIso : null,
        'created_at': now,
      });

      return debt.copyWith(
        itemsDescription: itemsDescription.trim(),
        totalAmount: totalAmount,
        currency: newCurrency,
        dueDate: dueIso,
        status: nextStatus,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Shopkeeper Daily Notepad / Checklist Operations
  // ---------------------------------------------------------------------------

  Future<int> insertNote(ShopNote note) async {
    final db = await database;
    return db.insert(tableShopNotes, note.toMap());
  }

  Future<int> updateNote(ShopNote note) async {
    final db = await database;
    if (note.id == null) return 0;
    return db.update(
      tableShopNotes,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete(
      tableShopNotes,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleNotePinned(int id, bool isPinned) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return db.update(
      tableShopNotes,
      {'is_pinned': isPinned ? 1 : 0, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleNoteDone(int id, bool isDone) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return db.update(
      tableShopNotes,
      {'is_done': isDone ? 1 : 0, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ShopNote>> getAllNotes() async {
    final db = await database;
    final rows = await db.query(
      tableShopNotes,
      orderBy: 'is_pinned DESC, updated_at DESC',
    );
    return rows.map((r) => ShopNote.fromMap(r)).toList();
  }
}


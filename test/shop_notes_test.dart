import 'package:flutter_test/flutter_test.dart';
import 'package:dube/models/shop_note.dart';

void main() {
  group('ShopNote Model Tests', () {
    test('toMap and fromMap serialize properly', () {
      final now = DateTime(2026, 8, 26, 12, 0, 0);
      final note = ShopNote(
        id: 42,
        title: 'Order Oil',
        content: '5 crates from supplier Addis',
        isPinned: true,
        isTodo: true,
        isDone: false,
        createdAt: now,
        updatedAt: now,
      );

      final map = note.toMap();
      expect(map['id'], 42);
      expect(map['title'], 'Order Oil');
      expect(map['content'], '5 crates from supplier Addis');
      expect(map['is_pinned'], 1);
      expect(map['is_todo'], 1);
      expect(map['is_done'], 0);
      expect(map['created_at'], now.toIso8601String());

      final reconstructed = ShopNote.fromMap(map);
      expect(reconstructed.id, 42);
      expect(reconstructed.title, 'Order Oil');
      expect(reconstructed.content, '5 crates from supplier Addis');
      expect(reconstructed.isPinned, isTrue);
      expect(reconstructed.isTodo, isTrue);
      expect(reconstructed.isDone, isFalse);
      expect(reconstructed.createdAt, now);
    });

    test('copyWith updates specific fields correctly', () {
      final now = DateTime(2026, 8, 26, 12, 0, 0);
      final note = ShopNote(
        id: 1,
        title: 'Sugar delivery',
        content: 'Check price',
        createdAt: now,
        updatedAt: now,
      );

      final updated = note.copyWith(isDone: true, isPinned: true);
      expect(updated.id, 1);
      expect(updated.title, 'Sugar delivery');
      expect(updated.isDone, isTrue);
      expect(updated.isPinned, isTrue);
      expect(note.isDone, isFalse);
    });
  });
}

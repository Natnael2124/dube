import 'package:flutter/material.dart';

import 'package:dube/database/db_helper.dart';
import 'package:dube/l10n/app_localizations.dart';
import 'package:dube/models/shop_note.dart';
import 'package:dube/utils/formatters.dart';

enum _NoteFilter { all, pinned, todos }

class ShopNotesScreen extends StatefulWidget {
  const ShopNotesScreen({super.key});

  @override
  State<ShopNotesScreen> createState() => _ShopNotesScreenState();
}

class _ShopNotesScreenState extends State<ShopNotesScreen> {
  List<ShopNote> _notes = [];
  bool _loading = true;
  String _query = '';
  _NoteFilter _filter = _NoteFilter.all;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _loading = true);
    try {
      final notes = await DbHelper.instance.getAllNotes();
      if (!mounted) return;
      setState(() {
        _notes = notes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<ShopNote> get _filteredNotes {
    final q = _query.trim().toLowerCase();
    return _notes.where((note) {
      final matchesFilter = switch (_filter) {
        _NoteFilter.all => true,
        _NoteFilter.pinned => note.isPinned,
        _NoteFilter.todos => note.isTodo,
      };
      if (!matchesFilter) return false;
      if (q.isEmpty) return true;
      return note.title.toLowerCase().contains(q) ||
          note.content.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openAddEditNoteDialog([ShopNote? existing]) async {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController(text: existing?.title ?? '');
    final contentController =
        TextEditingController(text: existing?.content ?? '');
    bool isPinned = existing?.isPinned ?? false;
    bool isTodo = existing?.isTodo ?? false;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            final scheme = theme.colorScheme;

            return Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existing == null ? l10n.addNote : l10n.editNote,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: l10n.noteTitle,
                        hintText: 'e.g. Oil Supplier / Daily Tally',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      minLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: l10n.noteContent,
                        hintText:
                            'e.g. Order 5 crates of oil\nCheck sugar price tomorrow\nCash in drawer: 15,400',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      value: isTodo,
                      onChanged: (val) => setSheetState(() => isTodo = val),
                      title: Text(l10n.isTodoChecklist),
                      secondary: const Icon(Icons.checklist_rounded),
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile.adaptive(
                      value: isPinned,
                      onChanged: (val) => setSheetState(() => isPinned = val),
                      title: Text(l10n.pinToTop),
                      secondary: const Icon(Icons.push_pin_outlined),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        final content = contentController.text.trim();
                        final title = titleController.text.trim();
                        if (content.isEmpty && title.isEmpty) return;

                        final now = DateTime.now();
                        if (existing == null) {
                          final newNote = ShopNote(
                            title: title.isEmpty ? 'Note' : title,
                            content: content,
                            isPinned: isPinned,
                            isTodo: isTodo,
                            isDone: false,
                            createdAt: now,
                            updatedAt: now,
                          );
                          await DbHelper.instance.insertNote(newNote);
                        } else {
                          final updated = existing.copyWith(
                            title: title.isEmpty ? 'Note' : title,
                            content: content,
                            isPinned: isPinned,
                            isTodo: isTodo,
                            updatedAt: now,
                          );
                          await DbHelper.instance.updateNote(updated);
                        }
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop(true);
                        }
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.save,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (saved == true) {
      await _loadNotes();
    }
  }

  Future<void> _deleteNote(ShopNote note) async {
    if (note.id == null) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text('${l10n.delete}? "${note.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DbHelper.instance.deleteNote(note.id!);
      await _loadNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noteDeleted),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _togglePinned(ShopNote note) async {
    if (note.id == null) return;
    await DbHelper.instance.toggleNotePinned(note.id!, !note.isPinned);
    await _loadNotes();
  }

  Future<void> _toggleDone(ShopNote note) async {
    if (note.id == null) return;
    await DbHelper.instance.toggleNoteDone(note.id!, !note.isDone);
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final visibleNotes = _filteredNotes;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.dailyNotes,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotes,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SearchBar(
                hintText: l10n.searchHint,
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0),
                onChanged: (val) => setState(() => _query = val),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text(l10n.allNotes),
                    selected: _filter == _NoteFilter.all,
                    onSelected: (_) =>
                        setState(() => _filter = _NoteFilter.all),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.push_pin, size: 16),
                    label: Text(l10n.pinnedNotes),
                    selected: _filter == _NoteFilter.pinned,
                    onSelected: (_) =>
                        setState(() => _filter = _NoteFilter.pinned),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.checklist, size: 16),
                    label: Text(l10n.todosOnly),
                    selected: _filter == _NoteFilter.todos,
                    onSelected: (_) =>
                        setState(() => _filter = _NoteFilter.todos),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : visibleNotes.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.note_alt_outlined,
                                  size: 56,
                                  color: scheme.outlineVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.noNotesYet,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                          itemCount: visibleNotes.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final note = visibleNotes[index];
                            return _ShopNoteCard(
                              note: note,
                              onTap: () => _openAddEditNoteDialog(note),
                              onToggleDone: () => _toggleDone(note),
                              onTogglePin: () => _togglePinned(note),
                              onDelete: () => _deleteNote(note),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditNoteDialog(),
        icon: const Icon(Icons.edit_note_rounded),
        label: Text(l10n.addNote),
      ),
    );
  }
}

class _ShopNoteCard extends StatelessWidget {
  const _ShopNoteCard({
    required this.note,
    required this.onTap,
    required this.onToggleDone,
    required this.onTogglePin,
    required this.onDelete,
  });

  final ShopNote note;
  final VoidCallback onTap;
  final VoidCallback onToggleDone;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: note.isPinned
          ? const Color(0xFFFFF8E1)
          : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: note.isPinned
              ? const Color(0xFFFFB300)
              : scheme.outlineVariant.withValues(alpha: 0.5),
          width: note.isPinned ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (note.isTodo)
                    IconButton(
                      icon: Icon(
                        note.isDone
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: note.isDone
                            ? const Color(0xFF2E7D32)
                            : scheme.primary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onToggleDone,
                    )
                  else
                    Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: scheme.primary,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        decoration: (note.isTodo && note.isDone)
                            ? TextDecoration.lineThrough
                            : null,
                        color: (note.isTodo && note.isDone)
                            ? scheme.outline
                            : (note.isPinned
                                ? const Color(0xFF5D4037)
                                : scheme.onSurface),
                      ),
                    ),
                  ),
                  if (note.isPinned)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE082),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.push_pin,
                            size: 12,
                            color: Color(0xFFE65100),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.pinned,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    onSelected: (action) {
                      if (action == 'pin') {
                        onTogglePin();
                      } else if (action == 'edit') {
                        onTap();
                      } else if (action == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'pin',
                        child: Row(
                          children: [
                            Icon(
                              note.isPinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(note.isPinned ? l10n.unpin : l10n.pinToTop),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: scheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.delete,
                              style: TextStyle(color: scheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: EdgeInsets.only(left: note.isTodo ? 28 : 0),
                  child: Text(
                    note.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration: (note.isTodo && note.isDone)
                          ? TextDecoration.lineThrough
                          : null,
                      color: (note.isTodo && note.isDone)
                          ? scheme.outline
                          : (note.isPinned
                              ? const Color(0xFF4E342E)
                              : scheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    formatDateTime(note.updatedAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

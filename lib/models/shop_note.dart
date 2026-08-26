class ShopNote {
  const ShopNote({
    this.id,
    required this.title,
    required this.content,
    this.isPinned = false,
    this.isTodo = false,
    this.isDone = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String title;
  final String content;
  final bool isPinned;
  final bool isTodo;
  final bool isDone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'is_pinned': isPinned ? 1 : 0,
      'is_todo': isTodo ? 1 : 0,
      'is_done': isDone ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ShopNote.fromMap(Map<String, dynamic> map) {
    return ShopNote(
      id: map['id'] as int?,
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      isPinned: (map['is_pinned'] as int?) == 1,
      isTodo: (map['is_todo'] as int?) == 1,
      isDone: (map['is_done'] as int?) == 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  ShopNote copyWith({
    int? id,
    String? title,
    String? content,
    bool? isPinned,
    bool? isTodo,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShopNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      isTodo: isTodo ?? this.isTodo,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

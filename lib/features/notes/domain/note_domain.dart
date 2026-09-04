class Note {
  final String id;
  final String title;
  final String content;
  final bool pinned;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.pinned = false,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['\$id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      pinned: map['pinned'] as bool? ?? false,
    );
  }
}

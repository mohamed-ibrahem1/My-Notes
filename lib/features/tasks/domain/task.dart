class Task {
  final String id;
  final String content;
  final bool completed;

  const Task({
    required this.id,
    required this.content,
    required this.completed,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map[r'$id'] as String,
      content: map['content'] as String,
      completed: map['completed'] as bool,
    );
  }
}

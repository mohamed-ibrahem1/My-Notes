class WeekTask {
  final String id;
  final String content;
  final bool completed;

  const WeekTask({
    required this.id,
    required this.content,
    required this.completed,
  });

  factory WeekTask.fromMap(Map<String, dynamic> map) {
    return WeekTask(
      id: map['\$id'] as String,
      content: map['content'] as String,
      completed: map['completed'] as bool? ?? false,
    );
  }
}

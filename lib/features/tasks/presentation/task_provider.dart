import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/appwrite_provider.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(appwriteProvider));
});

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<Task>>(
  TasksNotifier.new,
);

class TasksNotifier extends AsyncNotifier<List<Task>> {
  TaskRepository get _repository {
    return ref.read(taskRepositoryProvider);
  }

  @override
  Future<List<Task>> build() {
    return _repository.getTasks();
  }

  Future<void> addTask({required String content}) async {
    await _repository.addTask(content: content);

    ref.invalidateSelf();
  }

  Future<void> toggleTask(Task task) async {
    await _repository.updateTaskCompletion(
      id: task.id,
      completed: !task.completed,
    );

    ref.invalidateSelf();
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);

    ref.invalidateSelf();
  }
}

import 'package:flutter/foundation.dart';
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

  Future<void> updateTaskContent({
    required String id,
    required String content,
  }) async {
    await _repository.updateTaskContent(id: id, content: content);

    ref.invalidateSelf();
  }

  Future<void> deleteTask(String id) async {
    final previousTasks = state.value ?? [];

    // Remove the task from the UI immediately.
    state = AsyncData(previousTasks.where((task) => task.id != id).toList());

    try {
      // Delete the task from Appwrite.
      await _repository.deleteTask(id);
    } catch (e, stackTrace) {
      // Restore the task if the Appwrite deletion fails.
      state = AsyncData(previousTasks);

      debugPrint('Failed to delete task: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

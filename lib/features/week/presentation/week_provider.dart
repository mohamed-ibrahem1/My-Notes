import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/appwrite_provider.dart';
import '../data/week_repository.dart';
import '../domain/week_task.dart';

final weekRepositoryProvider = Provider<WeekRepository>((ref) {
  return WeekRepository(ref.watch(appwriteProvider));
});

final weekProvider = AsyncNotifierProvider<WeekNotifier, List<WeekTask>>(
  WeekNotifier.new,
);

class WeekNotifier extends AsyncNotifier<List<WeekTask>> {
  WeekRepository get _repository {
    return ref.read(weekRepositoryProvider);
  }

  @override
  Future<List<WeekTask>> build() {
    return _repository.getTasks();
  }

  Future<void> addTask({required String content}) async {
    await _repository.addTask(content: content);

    ref.invalidateSelf();
  }

  Future<void> toggleTask(WeekTask task) async {
    await _repository.updateTaskCompletion(
      id: task.id,
      completed: !task.completed,
    );

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
      // Restore the task if deletion fails.
      state = AsyncData(previousTasks);

      debugPrint('Failed to delete week task: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/cards.dart';
import '../features/tasks/presentation/task_provider.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return tasksAsync.when(
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stackTrace) {
        return Center(
          child: Text(
            'Failed to load tasks:\n$error',
            textAlign: TextAlign.center,
          ),
        );
      },
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks for today'));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            return AdaptiveCard(
              key: ValueKey(task.id),
              title: task.content,
              isCompleted: task.completed,
              showCheckbox: true,
              onTap: () {
                ref.read(tasksProvider.notifier).toggleTask(task);
              },
              onDelete: () {
                ref.read(tasksProvider.notifier).deleteTask(task.id);
              },
            );
          },
        );
      },
    );
  }
}

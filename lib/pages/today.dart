import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/cards.dart';
import '../components/empty_state_view.dart';
import '../components/error_state_view.dart';
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
        return ErrorStateView(
          error: error,
          onRetry: () => ref.invalidate(tasksProvider),
        );
      },
      data: (tasks) {
        if (tasks.isEmpty) {
          return const EmptyStateView(
            icon: Icons.today_outlined,
            title: 'No tasks for today',
            subtitle: 'Tap + to add your first task.',
          );
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

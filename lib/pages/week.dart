import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/cards.dart';
import '../components/empty_state_view.dart';
import '../components/error_state_view.dart';
import '../features/week/presentation/week_provider.dart';

class WeekPage extends ConsumerWidget {
  const WeekPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(weekProvider);

    return tasksAsync.when(
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stackTrace) {
        return ErrorStateView(
          error: error,
          onRetry: () => ref.invalidate(weekProvider),
        );
      },
      data: (tasks) {
        if (tasks.isEmpty) {
          return const EmptyStateView(
            icon: Icons.calendar_view_week_outlined,
            title: 'No tasks for this week',
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
                ref.read(weekProvider.notifier).toggleTask(task);
              },
              onDelete: () {
                ref.read(weekProvider.notifier).deleteTask(task.id);
              },
            );
          },
        );
      },
    );
  }
}

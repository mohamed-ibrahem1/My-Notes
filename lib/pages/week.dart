import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/cards.dart';
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
        return Center(
          child: Text(
            'Failed to load week tasks:\n$error',
            textAlign: TextAlign.center,
          ),
        );
      },
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks for this week'));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            return AdaptiveCard(
              key: ValueKey(task.id),
              title: task.content,
              isCompleted: task.completed,
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

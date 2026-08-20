import 'package:flutter/material.dart';
import 'bottom_sheet.dart';

void showTaskBottomSheet(BuildContext context) {
  final controller = TextEditingController();

  showAppBottomSheet(
    context: context,
    title: 'Add Task',
    child: Column(
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Task',
            hintText: 'Enter task content',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),

        const SizedBox(height: 16),

        FilledButton(
          onPressed: () {
            final task = controller.text.trim();

            if (task.isEmpty) return;

            Navigator.pop(context);
          },
          child: const Text('Save Task'),
        ),
      ],
    ),
  );
}

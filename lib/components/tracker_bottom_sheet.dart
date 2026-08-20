import 'package:flutter/material.dart';
import 'bottom_sheet.dart';

void showTrackerBottomSheet(BuildContext context) {
  final controller = TextEditingController();

  showAppBottomSheet(
    context: context,
    title: 'Add Habit',
    child: Column(
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Habit',
            hintText: 'Enter habit title',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        FilledButton(
          onPressed: () {
            final habit = controller.text.trim();

            if (habit.isEmpty) return;

            Navigator.pop(context);
          },
          child: const Text('Save Habit'),
        ),
      ],
    ),
  );
}

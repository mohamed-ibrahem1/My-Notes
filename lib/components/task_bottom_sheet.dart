import 'package:flutter/material.dart';

void showTaskBottomSheet(
  BuildContext context, {
  required Future<void> Function(String content) onSave,
}) {
  final controller = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Task',
                hintText: 'Enter task content',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final content = controller.text.trim();

                  if (content.isEmpty) {
                    return;
                  }

                  await onSave(content);

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Task'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

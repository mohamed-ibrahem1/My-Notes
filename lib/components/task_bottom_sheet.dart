import 'package:flutter/material.dart';

void showTaskBottomSheet(
  BuildContext context, {
  String? initialContent,
  required Future<void> Function(String content) onSave,
}) {
  final isEditing = initialContent != null;
  final controller = TextEditingController(text: initialContent);

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
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditing ? 'Update task' : 'Save task',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

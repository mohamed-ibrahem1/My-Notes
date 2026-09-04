import 'package:flutter/material.dart';

import 'bottom_sheet.dart';

void showNoteBottomSheet(
  BuildContext context, {
  String? initialTitle,
  String? initialContent,
  required Future<void> Function(String title, String content) onSave,
}) {
  final isEditing = initialTitle != null;
  final titleController = TextEditingController(text: initialTitle);
  final contentController = TextEditingController(text: initialContent);

  showAppBottomSheet(
    context: context,
    title: isEditing ? 'Edit Note' : 'Add Note',
    child: Column(
      children: [
        TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: contentController,
          decoration: const InputDecoration(
            labelText: 'Content',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),

        const SizedBox(height: 16),

        FilledButton(
          onPressed: () async {
            final title = titleController.text.trim();
            final content = contentController.text.trim();

            if (title.isEmpty || content.isEmpty) return;

            await onSave(title, content);

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
            isEditing ? 'Update Note' : 'Save Note',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

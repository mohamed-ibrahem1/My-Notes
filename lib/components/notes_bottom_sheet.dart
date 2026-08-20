import 'package:flutter/material.dart';
import 'bottom_sheet.dart';

void showNoteBottomSheet(BuildContext context) {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  showAppBottomSheet(
    context: context,
    title: 'Add Note',
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
          onPressed: () {
            final title = titleController.text.trim();
            final content = contentController.text.trim();

            if (title.isEmpty || content.isEmpty) return;

            Navigator.pop(context);
          },
          child: const Text('Save Note'),
        ),
      ],
    ),
  );
}

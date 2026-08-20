import 'package:flutter/material.dart';
import 'package:my_notes/components/bottom_sheet.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10, // Example item count
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text('Note ${index + 1}'),
                    subtitle: const Text('This is a sample note.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAppBottomSheet(
            context: context,
            title: 'Add Today Item',
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.task),
                  title: const Text('Add Task'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.note),
                  title: const Text('Add Note'),
                  onTap: () {},
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

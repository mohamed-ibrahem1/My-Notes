import 'package:flutter/material.dart';
import 'package:my_notes/components/cards.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10, // Example item count
              itemBuilder: (context, index) {
                return AdaptiveCard(
                  title: 'Note ${index + 1}',
                  subtitle: 'This is a sample note.',
                  onDelete: () {
                    // Handle card delete
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

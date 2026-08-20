import 'package:flutter/material.dart';
import 'package:my_notes/components/cards.dart';

class TrackerPage extends StatelessWidget {
  const TrackerPage({super.key});

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
              itemCount: 5, // Example item count for tracker
              itemBuilder: (context, index) {
                return AdaptiveCard(
                  title: 'Tracker Item ${index + 1}',
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

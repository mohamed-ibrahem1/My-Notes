import 'package:flutter/material.dart';
import 'package:my_notes/components/cards.dart';

class WeekPage extends StatelessWidget {
  const WeekPage({super.key});

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
              itemCount: 7, // Example item count for a week
              itemBuilder: (context, index) {
                return AdaptiveCard(
                  title: 'Day ${index + 1}',

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

import 'package:flutter/material.dart';

/// Minimal, consistent placeholder shown when a list has no items yet.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyStateView({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

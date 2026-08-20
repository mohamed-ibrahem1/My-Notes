import 'package:flutter/material.dart';

class AdaptiveCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isCompleted;

  const AdaptiveCard({
    super.key,
    required this.title,
    this.subtitle,
    this.isCompleted = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key ?? ValueKey(title),
      direction: DismissDirection.horizontal,
      onDismissed: (_) {
        onDelete?.call();
      },
      background: _buildDeleteBackground(context, Alignment.centerLeft),
      secondaryBackground: _buildDeleteBackground(
        context,
        Alignment.centerRight,
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text(
            title,
            maxLines: subtitle == null ? null : null,
            overflow: TextOverflow.visible,
          ),
          subtitle: subtitle == null
              ? null
              : Text(subtitle!, maxLines: null, overflow: TextOverflow.visible),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildDeleteBackground(BuildContext context, Alignment alignment) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.delete_outline,
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
    );
  }
}

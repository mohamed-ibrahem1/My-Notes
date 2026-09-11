import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

enum ErrorKind { connectivity, appwriteConfig, appwriteLimit, unknown }

bool isConnectivityError(Object error) {
  if (error is SocketException || error is TimeoutException) {
    return true;
  }

  final message = error.toString().toLowerCase();

  const networkHints = [
    'socketexception',
    'failed host lookup',
    'network is unreachable',
    'connection failed',
    'connection refused',
    'connection timed out',
    'timeoutexception',
    'clientexception',
    'software caused connection abort',
  ];

  return networkHints.any(message.contains);
}

ErrorKind classifyError(Object error) {
  final message = error.toString().toLowerCase();

  if (isConnectivityError(error)) {
    return ErrorKind.connectivity;
  }

  if (message.contains('appwrite') &&
      (message.contains('not configured') ||
          message.contains('project') ||
          message.contains('database') ||
          message.contains('endpoint'))) {
    return ErrorKind.appwriteConfig;
  }

  if (message.contains('rate limit') ||
      message.contains('quota') ||
      message.contains('limit reached') ||
      message.contains('too many requests') ||
      message.contains('free plan')) {
    return ErrorKind.appwriteLimit;
  }

  return ErrorKind.unknown;
}

class ErrorStateView extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const ErrorStateView({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final kind = classifyError(error);

    String title;
    String subtitle;
    IconData icon;

    switch (kind) {
      case ErrorKind.connectivity:
        title = 'Connection problem';
        subtitle = 'Check your internet connection and try again.';
        icon = Icons.wifi_off_rounded;
        break;
      case ErrorKind.appwriteConfig:
        title = 'Appwrite configuration error';
        subtitle =
            'Appwrite is not configured correctly. Check the endpoint, project ID, and database ID.';
        icon = Icons.api_rounded;
        break;
      case ErrorKind.appwriteLimit:
        title = 'Appwrite service limit reached';
        subtitle =
            'The free plan may have reached its request or storage limit. Please wait and try again later or upgrade the plan.';
        icon = Icons.warning_amber_rounded;
        break;
      case ErrorKind.unknown:
        title = 'Something went wrong';
        subtitle = 'Please try again in a moment.';
        icon = Icons.error_outline_rounded;
        break;
    }

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
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

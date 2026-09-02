import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

/// Returns true if [error] looks like a network/connectivity failure
/// (no internet, DNS failure, timeout) rather than an application error.
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

/// Minimal, user-friendly placeholder shown instead of raw error text.
///
/// Shows a dedicated "no internet" message for connectivity failures, and a
/// generic message for anything else, so implementation details never leak
/// to the user.
class ErrorStateView extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const ErrorStateView({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isOffline = isConnectivityError(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 56,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              isOffline ? 'No internet connection' : 'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isOffline
                  ? 'Check your connection and try again.'
                  : 'Please try again in a moment.',
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

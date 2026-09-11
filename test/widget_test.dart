import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_notes/components/error_state_view.dart';

void main() {
  testWidgets('shows a clear Appwrite configuration message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ErrorStateView(
          error: StateError(
            'Appwrite is not configured. Pass APPWRITE_ENDPOINT and APPWRITE_PROJECT_ID using --dart-define.',
          ),
        ),
      ),
    );

    expect(find.text('Appwrite configuration error'), findsOneWidget);
    expect(find.textContaining('endpoint'), findsOneWidget);
  });

  testWidgets('shows a clear network message for connectivity errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const ErrorStateView(
          error: SocketException('Connection refused'),
        ),
      ),
    );

    expect(find.text('Connection problem'), findsOneWidget);
    expect(find.textContaining('internet'), findsOneWidget);
  });
}

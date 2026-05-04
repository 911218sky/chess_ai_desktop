import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_ai_desktop/src/app.dart';

void main() {
  testWidgets('renders chess project shell', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(child: ChessAIDesktopApp(autoInitialize: false)),
    );

    expect(find.text('Play Bots'), findsOneWidget);
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('Bots'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.byIcon(Icons.timer_rounded), findsNWidgets(2));
  });

  testWidgets('board sidebar stays within a short wide viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(900, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(child: ChessAIDesktopApp(autoInitialize: false)),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Play Bots'), findsOneWidget);
    expect(find.byIcon(Icons.timer_rounded), findsNWidgets(2));
  });
}

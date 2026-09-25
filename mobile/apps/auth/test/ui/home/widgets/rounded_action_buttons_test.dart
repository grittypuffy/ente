import 'package:ente_auth/ente_theme_data.dart';
import 'package:ente_auth/ui/home/widgets/rounded_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders an optional leading icon and remains tappable', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: lightThemeData,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              child: RoundedButton(
                label: 'Create account',
                onPressed: () => tapped = true,
                leading: const Icon(Icons.person_add_alt_1_outlined),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.person_add_alt_1_outlined), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(RoundedButton));
    expect(tapped, isTrue);
  });

  testWidgets('keeps a label-only button valid with large text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightThemeData,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 140,
                child: RoundedButton(label: 'Create account', onPressed: () {}),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Create account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

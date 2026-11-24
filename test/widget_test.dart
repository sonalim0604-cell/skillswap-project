import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/main.dart';

void main() {
  testWidgets('a newly added teaching skill appears immediately', (
    tester,
  ) async {
    final app = DemoState();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SkillsPage(app: app)),
      ),
    );
    await tester.ensureVisible(find.text('Add Teaching Skill'));
    await tester.tap(find.text('Add Teaching Skill'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Rust');
    await tester.tap(find.text('Add skill'));
    await tester.pumpAndSettle();

    expect(find.text('Rust'), findsOneWidget);
  });

  testWidgets('an empty skill name keeps the dialog open with an error', (
    tester,
  ) async {
    final app = DemoState();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SkillsPage(app: app)),
      ),
    );
    await tester.ensureVisible(find.text('Add Learning Skill'));
    await tester.tap(find.text('Add Learning Skill'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add skill'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a skill first.'), findsOneWidget);
    expect(find.text('Add a learning goal'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Login page inputs and navigation to ClientDashboard test', (WidgetTester tester) async {
    await tester.pumpWidget(const MediRoutineApp());

    // Verify Login Page elements
    expect(find.text('Client Login'), findsOneWidget);
    expect(find.text('ClientName'), findsOneWidget);
    expect(find.text('ClientAge'), findsOneWidget);
    expect(find.text('Enter'), findsOneWidget);

    // Enter details in text fields
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(2));

    await tester.enterText(textFields.at(0), 'John Doe');
    await tester.enterText(textFields.at(1), '45');
    await tester.pump();

    // Tap Enter button
    await tester.tap(find.text('Enter'));
    await tester.pumpAndSettle();

    // Verify ClientDashboard elements
    expect(find.text('John Doe'), findsWidgets);
    expect(find.text('Add Medicine'), findsOneWidget);
  });
}

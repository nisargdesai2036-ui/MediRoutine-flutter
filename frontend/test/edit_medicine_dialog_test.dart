import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/client_dashboard.dart';
import 'package:frontend/dialogs/edit_medicine_dialog.dart';
import 'package:frontend/Sessions/UserSession.dart';

void main() {
  setUp(() {
    UserSession.setUser(
      Userid: 1,
      Name: 'John Doe',
      Email: 'john@example.com',
    );
  });

  tearDown(() {
    UserSession.unrestUser();
  });

  testWidgets('Edit medicine dialog opens and displays current medicine info', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ClientDashboard(
          userId: 1,
          clientName: 'John Doe',
          clientAge: 35,
          clientEmail: 'john@example.com',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Add Medicine button exists
    expect(find.text('Add Medicine'), findsOneWidget);

    // Open add dialog to create a routine
    await tester.tap(find.text('Add Medicine'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Medicine Name *'), 'Aspirin 100mg');
    await tester.pump();

    await tester.tap(find.byKey(const Key('dialog_add_medicine_button')));
    await tester.pumpAndSettle();

    // Aspirin 100mg should now be in the list
    expect(find.text('Aspirin 100mg'), findsOneWidget);

    // Tap on the edit button for this medicine
    final editBtn = find.byTooltip('Edit Medicine & Schedule');
    expect(editBtn, findsOneWidget);
    await tester.tap(editBtn);
    await tester.pumpAndSettle();

    // Check Medicine Details Dialog is open
    expect(find.text('Medicine Details'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Aspirin 100mg'), findsOneWidget);

    // Edit the medicine name
    await tester.enterText(find.widgetWithText(TextField, 'Aspirin 100mg'), 'Aspirin 150mg Extra');
    await tester.pump();

    // Tap Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  });

  testWidgets('EditMedicineDialog directly renders and edits all routine fields', (WidgetTester tester) async {
    final routineData = {
      'medicineId': 5,
      'scheduleId': 10,
      'name': 'Ibuprofen 400mg',
      'description': 'Take after food',
      'dosage': '1 Tablet with water',
      'quantity': 2,
      'unit': 'Tablet',
      'time': '09:00 AM',
      'period': 'MORNING',
      'frequencyType': 'SPECIFIC_DAYS',
      'daysOfWeek': 'MON,WED,FRI',
      'startDate': '2026-10-06',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: ctx,
                  builder: (_) => EditMedicineDialog(routine: routineData),
                );
              },
              child: const Text('Open Edit'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Edit'));
    await tester.pumpAndSettle();

    // Verify all sections and initial values
    expect(find.text('Edit Medicine Routine'), findsOneWidget);
    expect(find.text('Medicine Details'), findsOneWidget);
    expect(find.text('Schedule & Timing'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Ibuprofen 400mg'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Take after food'), findsOneWidget);
    expect(find.widgetWithText(TextField, '1 Tablet with water'), findsOneWidget);
    expect(find.text('Change Time'), findsOneWidget);

    // Edit fields
    await tester.enterText(find.widgetWithText(TextField, 'Ibuprofen 400mg'), 'Ibuprofen 600mg Forte');
    await tester.enterText(find.widgetWithText(TextField, 'Take after food'), 'Take with large glass of milk');
    await tester.pump();

    // Verify Save button and tap
    final saveBtn = find.widgetWithText(ElevatedButton, 'Save');
    expect(saveBtn, findsOneWidget);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();
  });
}

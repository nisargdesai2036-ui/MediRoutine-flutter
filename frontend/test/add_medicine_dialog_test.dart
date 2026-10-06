import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/client_dashboard.dart';
import 'package:frontend/dialogs/add_medicine_dialog.dart';

void main() {
  testWidgets('Add Medicine popup dialog opens and renders all required fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ClientDashboard(
          clientName: 'Alice Test',
          clientAge: 29,
        ),
      ),
    );

    // Verify Add Medicine button exists on dashboard
    final addMedBtn = find.text('Add Medicine');
    expect(addMedBtn, findsOneWidget);

    // Tap Add Medicine button to trigger popup
    await tester.tap(addMedBtn);
    await tester.pumpAndSettle();

    // Verify AddMedicineDialog popup rendered in middle of screen
    expect(find.byType(AddMedicineDialog), findsOneWidget);
    expect(find.text('Add Medicine Routine'), findsOneWidget);
    expect(find.text('Medicine Details'), findsOneWidget);
    expect(find.text('Schedule & Timing'), findsOneWidget);

    // Verify scroll down / dropdown menus for Period and Frequency Type
    expect(find.text('Period *'), findsOneWidget);
    expect(find.text('Frequency Type *'), findsOneWidget);

    // Verify Add button is in the dialog
    expect(find.byKey(const Key('dialog_add_medicine_button')), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);

    // Enter medicine name and submit
    await tester.enterText(find.widgetWithText(TextFormField, 'Medicine Name *'), 'Metformin 500mg');
    await tester.pump();

    // Tap Add Medicine button in bottom right corner
    await tester.tap(find.byKey(const Key('dialog_add_medicine_button')));
    await tester.pumpAndSettle();

    // Dialog should be dismissed and new medicine should appear in the routine list
    expect(find.byType(AddMedicineDialog), findsNothing);
    expect(find.text('Metformin 500mg'), findsOneWidget);
  });
}

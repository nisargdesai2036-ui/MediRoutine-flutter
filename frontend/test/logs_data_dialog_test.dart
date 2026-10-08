import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/dialogs/logs_data_dialog.dart';

void main() {
  testWidgets('LogsDataDialog displays medicine info on left and roof square boxes on right',
      (WidgetTester tester) async {
    final sampleRoutine = {
      'id': 101,
      'name': 'DONOIOUS',
      'instruction': 'Take 1 Tablet',
      'dosage': '1 Tablet',
      'time': '08:30 AM',
      'period': 'Morning',
      'tag': 'Morning',
      'frequencyType': 'DAILY',
      'color': 0xFF4CAF50,
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => LogsDataDialog(routine: sampleRoutine, scheduleId: 1,),
                  );
                },
                child: const Text('Open Logs'),
              );
            },
          ),
        ),
      ),
    );

    // Tap to open dialog
    await tester.tap(find.text('Open Logs'));
    await tester.pumpAndSettle();

    // Verify dialog title
    expect(find.text('logs_data'), findsOneWidget);

    // Verify medicine info on the left side
    expect(find.text('DONOIOUS'), findsOneWidget);
    expect(find.text('Take 1 Tablet'), findsOneWidget);
    expect(find.text('08:30 AM'), findsWidgets);

    // Verify right-side square boxes with roof headers: TOTAL, TAKEN, MISSED
    expect(find.text('TOTAL'), findsOneWidget);
    expect(find.text('TAKEN'), findsWidgets); // May appear in roof and log items
    expect(find.text('MISSED'), findsWidgets);

    // Verify dummy counts
    expect(find.text('30'), findsOneWidget);
    expect(find.text('26'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    // Verify close button dismisses dialog
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('logs_data'), findsNothing);
  });
}

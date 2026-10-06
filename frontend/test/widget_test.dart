import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/client_dashboard.dart';
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

  testWidgets('ClientDashboard renders user header, routine section, and Add Medicine button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ClientDashboard(
          userId: 1,
          clientName: 'John Doe',
          clientAge: 45,
          clientEmail: 'john@example.com',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify user information in app bar and greeting banner
    expect(find.text('John Doe'), findsWidgets);
    expect(find.text("Today's Medicine Routine"), findsOneWidget);
    expect(find.text('Add Medicine'), findsOneWidget);
  });
}

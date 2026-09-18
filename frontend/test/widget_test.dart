import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediroutine/app.dart';
import 'package:mediroutine/features/auth/presentation/auth_screen.dart';
import 'package:mediroutine/features/auth/presentation/login_screen.dart';
import 'package:mediroutine/features/auth/presentation/signup_screen.dart';
import 'package:mediroutine/features/auth/presentation/splash_screen.dart';
import 'package:mediroutine/features/auth/widgets/auth_header.dart';
import 'package:mediroutine/shared/widgets/abstract_routine_visual.dart';
import 'package:mediroutine/shared/widgets/medi_button.dart';
import 'package:mediroutine/shared/widgets/medi_text_field.dart';

void main() {
  testWidgets('App renders splash screen initially', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MediRoutineApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('MediRoutine'), findsOneWidget);
  });

  testWidgets('AuthScreen renders desktop split layout on wide viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(AbstractRoutineVisual), findsOneWidget);
    expect(find.text('Your health, on routine.'), findsOneWidget);
    expect(find.byType(LoginForm), findsOneWidget);
  });

  testWidgets('AuthScreen toggles to SignUpForm when Sign up link is tapped', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(LoginForm), findsOneWidget);

    // Tap  Sign up
    await tester.tap(find.text('Sign up'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(SignUpForm), findsOneWidget);
    expect(find.text('Create your MediRoutine account'), findsOneWidget);
  });

  testWidgets('LoginScreen standalone renders header, inputs, and buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.byType(AuthHeader), findsOneWidget);
    expect(find.text('Welcome back 👋'), findsOneWidget);
    expect(find.byType(MediTextField), findsNWidgets(2));
    expect(find.byType(MediButton), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });

  testWidgets(
    'SignUpScreen standalone renders all required fields and trust badge',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

      expect(find.text('Create your MediRoutine account'), findsOneWidget);
      expect(find.byType(MediTextField), findsNWidgets(4));
      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Sign up with Google'), findsOneWidget);
      expect(find.text('Sign up with Apple'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
    },
  );

  testWidgets('LoginForm validates empty fields on submit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoginScreen())),
    );

    // Tap Login without filling inputs
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Email address is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_page.dart';
import 'screens/signup.dart';
import 'screens/profile_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Supabase.initialize(
  //   url: 'https://vmpzdwaeqjyfspqdrcix.supabase.co',
  //   anonKey: 'sb_publishable_inFK6JbPWnMQs4d-3yaf6Q_pgDzhI1K',
  // );

  runApp(const MediRoutineApp());
}

class MediRoutineApp extends StatelessWidget {
  const MediRoutineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediRoutine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077B6),
          primary: const Color(0xFF0077B6),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const SignUpPage(),
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/profilepage': (context) => const ProfilePage(),
      },
    );
  }
}

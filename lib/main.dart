import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_new_food_app/pages/login.dart';
import 'package:my_new_food_app/pages/onboard.dart';
import 'package:my_new_food_app/pages/settings.dart'; // Import settings
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'My New Food App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Default Light Theme
      darkTheme: ThemeData.dark(), // Dark Theme
      themeMode: themeProvider.themeMode, // Controls theme mode dynamically
      home: FirebaseAuth.instance.currentUser == null
          ? const Login()
          : const Onboard(),
      routes: {
        '/login': (context) => const Login(),
        '/onboard': (context) => const Onboard(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

/// 🌙 **Theme Provider for Global Theme Management**
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

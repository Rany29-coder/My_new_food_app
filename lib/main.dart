import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_new_food_app/pages/login.dart';
import 'package:my_new_food_app/pages/onboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures bindings are initialized
  await Firebase.initializeApp(); // Initializes Firebase before runApp
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      // Dynamically choose the initial route
      home: FirebaseAuth.instance.currentUser == null
          ? const Login()
          : const Onboard(),
      routes: {
        '/login': (context) => const Login(),
        '/onboard': (context) => const Onboard(),
      },
    );
  }
}

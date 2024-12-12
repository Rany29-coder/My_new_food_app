import 'package:flutter/material.dart';
import 'package:my_new_food_app/pages/seller/dashboard/store_dashboard.dart';

class RegisterStore extends StatelessWidget {
  const RegisterStore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Store'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your store registration form here
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StoreDashboard()),
                );
              },
              child: Text('Complete Registration'),
            ),
          ],
        ),
      ),
    );
  }
}

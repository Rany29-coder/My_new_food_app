import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Localization import
import 'package:my_new_food_app/pages/seller/dashboard/store_dashboard.dart';

class RegisterStore extends StatelessWidget {
  const RegisterStore({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.registerStore), // Localized title
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
              child: Text(locale.completeRegistration), // Localized button text
            ),
          ],
        ),
      ),
    );
  }
}

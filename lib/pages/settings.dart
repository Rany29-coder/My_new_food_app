import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:my_new_food_app/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _inviteFriends() {
    final locale = AppLocalizations.of(context)!;

    String message = locale.inviteMessage;

    Clipboard.setData(ClipboardData(text: message));
    Share.share(message);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(locale.inviteCopied)),
    );
  }

  void _showChangePasswordDialog() {
    final locale = AppLocalizations.of(context)!;

    TextEditingController emailController = TextEditingController();
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(locale.changePassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: locale.email),
              ),
              TextField(
                controller: oldPasswordController,
                decoration: InputDecoration(labelText: locale.oldPassword),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: locale.newPassword),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(locale.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential = await _auth
                      .signInWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: oldPasswordController.text.trim(),
                  );

                  await userCredential.user?.updatePassword(
                    newPasswordController.text.trim(),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(locale.passwordChanged)),
                  );

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${locale.error}: $e")),
                  );
                }
              },
              child: Text(locale.update),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    final locale = AppLocalizations.of(context)!;
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${locale.logoutError}: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.settings),
        backgroundColor: const Color(0xFF8B5E3C),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          /// 🌙 Dark Mode Toggle
          SwitchListTile(
            title: Text(locale.darkMode),
            subtitle: Text(
              themeProvider.themeMode == ThemeMode.dark
                  ? locale.darkModeEnabled
                  : locale.lightModeEnabled,
            ),
            secondary: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) => themeProvider.toggleTheme(),
          ),

          const Divider(),

          /// 🔗 Invite Friends
          ListTile(
            leading: const Icon(Icons.share, color: Colors.blue),
            title: Text(locale.inviteFriends),
            subtitle: Text(locale.inviteSubtitle),
            onTap: _inviteFriends,
          ),

          const Divider(),

          /// 🔒 Change Password
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.orange),
            title: Text(locale.changePassword),
            subtitle: Text(locale.changePasswordSubtitle),
            onTap: _showChangePasswordDialog,
          ),

          const Divider(),

          /// 🚪 Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(locale.logout, style: const TextStyle(color: Colors.red)),
            subtitle: Text(locale.logoutSubtitle),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}

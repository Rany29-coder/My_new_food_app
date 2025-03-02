import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:my_new_food_app/main.dart'; // Import ThemeProvider

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _inviteFriends() {
    String message =
        "🌱 Join me in making a difference! I'm using this app to save food & help the community. Download it now! 📲💚";
    
    Clipboard.setData(ClipboardData(text: message));
    Share.share(message);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invitation copied! Share it now 🎉")),
    );
  }

  void _showChangePasswordDialog() {
    TextEditingController emailController = TextEditingController();
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: oldPasswordController,
                decoration: const InputDecoration(labelText: "Old Password"),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: "New Password"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
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
                    const SnackBar(
                        content: Text("Password changed successfully!")),
                  );

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF8B5E3C),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          /// 🌙 Dark Mode Toggle
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: Text(
                themeProvider.themeMode == ThemeMode.dark
                    ? "Dark mode is enabled"
                    : "Light mode is enabled"),
            secondary: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),

          const Divider(),

          /// 🔗 Invite Friends
          ListTile(
            leading: const Icon(Icons.share, color: Colors.blue),
            title: const Text("Invite Friends"),
            subtitle: const Text("Spread the word and invite others!"),
            onTap: _inviteFriends,
          ),

          const Divider(),

          /// 🔒 Change Password
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.orange),
            title: const Text("Change Password"),
            subtitle: const Text("Update your password for security"),
            onTap: _showChangePasswordDialog,
          ),

          const Divider(),

          /// 🚪 Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            subtitle: const Text("Sign out of your account"),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}

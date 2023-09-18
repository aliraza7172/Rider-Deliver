import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'ProfileScreen.dart';

class PasswordChangeScreen extends StatefulWidget {
  final String id;

  const PasswordChangeScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _PasswordChangeScreenState createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _idController = TextEditingController();

  String _oldPasswordError = '';
  String _newPasswordError = '';
  String _confirmPasswordError = '';

  Future<void> updateUsePassword(
      String id, String oldPassword, String newPassword) async {
    var url = 'http://dev.codesisland.com/api/updateriderpassword/$id';
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'id': id,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
          (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Failed to change password. Please try again later. Your Old Password Not Matched'),
      ));
    }
  }

  void initState() {
    super.initState();
    // Initialize the text field values with the existing user data
    _idController.text = widget.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true, // This centers the title horizontally.
        title: Row(
          children: <Widget>[
            Image.asset(
              'image/riderlogo.png', // Replace 'assets/logo.png' with the path to your logo image.
              width: 75, // Adjust the width as needed.
              height: 70, // Adjust the height as needed.
            ),
            const SizedBox(
                width: 8), // Add some spacing between the logo and the title.
            Spacer(), // This will push the text to the right.

            const Text(
              'Change Password',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.yellow),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Old Password',
                errorText:
                    _oldPasswordError.isNotEmpty ? _oldPasswordError : null,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                errorText:
                    _newPasswordError.isNotEmpty ? _newPasswordError : null,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                errorText: _confirmPasswordError.isNotEmpty
                    ? _confirmPasswordError
                    : null,
              ),
            ),
            const SizedBox(height: 32.0),
            // TextField(
            //   controller: _idController,
            //   enabled: false,
            //   decoration: const InputDecoration(
            //     labelText: 'ID',
            //   ),
            // ),
            Container(
              color: Colors.green, // Set the background color
              child: ElevatedButton(
                onPressed: () {
                  String oldPassword = _oldPasswordController.text;
                  String newPassword = _newPasswordController.text;
                  String confirmPassword = _confirmPasswordController.text;
                  String id = widget.id;

                  setState(() {
                    _oldPasswordError = '';
                    _newPasswordError = '';
                    _confirmPasswordError = '';
                  });

                  if (oldPassword.isEmpty) {
                    setState(() {
                      _oldPasswordError = 'Please enter your old password.';
                    });
                  } else if (newPassword.length >= 6) {
                    if (newPassword == confirmPassword) {
                      // Passwords match, continue with password change
                      // Add your logic here to change the password
                      // Show a success message or navigate back to the profile screen
                      updateUsePassword(id, oldPassword, newPassword);

                      // Navigator.pop(context);
                    } else {
                      setState(() {
                        _confirmPasswordError = 'Passwords do not match.';
                      });
                    }
                  } else {
                    setState(() {
                      _newPasswordError =
                          'New password must be at least 6 characters.';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Set the button's background color
                ),
                child: const Text('Change Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

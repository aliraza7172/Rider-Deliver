import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freshpickup/home/login.dart';
import 'package:http/http.dart' as http;

class forgotPassword extends StatefulWidget {
  final String email;

  const forgotPassword({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  _PasswordChangeScreenState createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<forgotPassword> {
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  String _newPasswordError = '';
  String _confirmPasswordError = '';

  Future<void> updateUsePassword(String newPassword) async {
    var url =
        'http://dev.codesisland.com/api/forgetpassword/update/${widget.email}';
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Your pass word has been updated.'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to change password. Please try again.'),
      ));
    }
  }

  void initState() {
    super.initState();
    // Initialize the text field values with the existing user data
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
                  String newPassword = _newPasswordController.text;
                  String confirmPassword = _confirmPasswordController.text;

                  setState(() {
                    _newPasswordError = '';
                    _confirmPasswordError = '';
                  });

                  if (newPassword.length >= 6) {
                    if (newPassword == confirmPassword) {
                      // Passwords match, continue with password change
                      // Add your logic here to change the password
                      // Show a success message or navigate back to the profile screen
                      updateUsePassword(newPassword);

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

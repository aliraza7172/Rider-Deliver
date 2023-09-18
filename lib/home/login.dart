import 'package:flutter/material.dart';
import 'package:freshpickup/home/navbar.dart';
import 'package:freshpickup/home/registeration.dart';
import 'package:freshpickup/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import 'forgotemail.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController textEmail = TextEditingController();
  TextEditingController textpassword = TextEditingController();
  bool loading = false;

  void _loginUser() async {
    ApiResponse response =
        await login(context, textEmail.text, textpassword.text);
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Navbar()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(  
            image: DecorationImage(
          image: AssetImage("image/riderbg.jpg"),
          fit: BoxFit.cover,
        )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Image.asset('image/logo.png', height: 80), // Add a logo image
                const SizedBox(height: 32),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: textEmail,
                  validator: (val) =>
                      val!.isEmpty ? 'Invalid email address' : null,
                  decoration: kInputDecoration(
                    'Email',
                  ), // Add an icon to the email field
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: textpassword,
                  obscureText: true,
                  validator: (val) =>
                      val!.length < 6 ? 'Required at least 6 chars' : null,
                  decoration: kInputDecoration(
                    'Password',
                  ), // Add an icon to the password field
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment
                      .centerRight, // Align the password field to the right

                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnterEmailScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.green, // Customize the text color
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                loading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromRGBO(102, 165, 19,
                                1))) // Improve the loading indicator
                    : ElevatedButton(
                        onPressed: () {
                          if (formkey.currentState!.validate()) {
                            setState(() {
                              loading = true;
                              _loginUser();
                            });
                          }
                        },
                        child: const Text('Login'),
                        style: ElevatedButton.styleFrom(
                          // Create a custom button style
                          primary: Color.fromRGBO(102, 165, 19, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
                        ),
                      ),
                const SizedBox(
                  height: 10,
                ),
                kLoginRegisterHint('Do not have an account?', 'Register', () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const Register()),
                      (route) => false);
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freshpickup/home/login.dart';
import 'package:freshpickup/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../constant.dart';
import '../../models/api_response.dart';
import '../../models/user.dart';
import 'otpScreen.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool loading = false;
  TextEditingController nameController = TextEditingController(),
      emailController = TextEditingController(),
      phoneController = TextEditingController(),
      passwordController = TextEditingController(),
      passwordConfirmController = TextEditingController();

  // void _registerUser() async {
  //   ApiResponse response = await register(nameController.text,
  //       emailController.text, passwordController.text, phoneController.text);
  //   if (response.error == null) {
  //     _saveAndRedirectToHome(response.data as User);
  //   } else {
  //     setState(() {
  //       loading = false;
  //     });
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('${response.error}')));
  //   }
  // }

 Future<void> _registerAndNavigateToOTP() async {
    // print(nameController.text);

    var url = 'http://dev.codesisland.com/api/customerotp';
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String updated_at = responseData['otp']['updated_at'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP has sended. Check your email'),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            email: emailController.text,
            phone:phoneController.text,
            password: passwordController.text,
            name: nameController.text,
            updated_at: updated_at,
          ),
        ),
      );

      setState(() {
        loading = false;
      });
    } else if (response.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Email is alredy Exist'),
      ));
      setState(() {
        loading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error to ganter Api '),
      ));
      setState(() {
        loading = false;
      });
    }
  }


  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()), (route) => false);
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
        child: Form(
          key: formkey,
          child: ListView(
            padding: const EdgeInsets.all(40),
            children: [
              const SizedBox(height: 140),
              Image.asset('image/logo.png', height: 80), // Add a logo image
              const SizedBox(height: 32),
              TextFormField(
                  controller: nameController,
                  validator: (val) => val!.isEmpty ? 'Invalide Name' : null,
                  // This Function is call fron constant class
                  decoration: kInputDecoration('Name')),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  validator: (val) =>
                      val!.isEmpty ? 'Invalide email address' : null,
                  // This Function is call fron constant class
                  decoration: kInputDecoration('Email')),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  validator: (val) =>
                      val!.isEmpty ? 'Invalide phone number' : null,
                  // This Function is call fron constant class
                  decoration: kInputDecoration('Phone Number')),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (val) =>
                      val!.length < 6 ? 'Required at least 6 chars' : null,
                  // This Function is call fron constant class
                  decoration: kInputDecoration('Password')),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                  controller: passwordConfirmController,
                  obscureText: true,
                  validator: (val) => val != passwordController.text
                      ? 'Confirm password dose not match'
                      : null,
                  // This Function is call fron constant class
                  decoration: kInputDecoration('Confirm Password')),

              const SizedBox(
                height: 10,
              ),
              //Loading
              loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : kTextButton('Register', () {
                      if (formkey.currentState!.validate()) {
                        setState(() {
                          // loading = !loading;
                          loading = true;
                          //_registerUser();
                          // _registerAndNavigateToOTP();
                        });
                        _registerAndNavigateToOTP();
                      }
                    }),


              const SizedBox(
                height: 10,
              ),
              kLoginRegisterHint('Dont have an account?', 'Login', () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Login()),
                    (route) => false);
              })
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:freshpickup/home/navbar.dart';
// import 'package:freshpickup/services/user_service.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../constant.dart';
// import '../models/api_response.dart';
// import '../models/user.dart';
// import 'login.dart';

// class Register extends StatefulWidget {
//   const Register({Key? key}) : super(key: key);

//   @override
//   State<Register> createState() => _RegisterState();
// }

// class _RegisterState extends State<Register> {
//   GlobalKey<FormState> formkey = GlobalKey<FormState>();
//   bool loading = false;
//   TextEditingController nameController = TextEditingController(),
//       emailController = TextEditingController(),
//       passwordController = TextEditingController(),
//       passwordConfirmController = TextEditingController();

//   void _registerUser() async {
//     ApiResponse response = await register(
//         nameController.text, emailController.text, passwordController.text);
//     if (response.error == null) {
//       _saveAndRedirectToHome(response.data as User);
//     } else {
//       setState(() {
//         loading = false;
//       });
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('${response.error}')));
//     }
//   }

//   void _saveAndRedirectToHome(User user) async {
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     await pref.setString('token', user.token ?? '');
//     await pref.setInt('userId', user.id ?? 0);
//     Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => Navbar()),
//         (route) => false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//             image: DecorationImage(
//           image: AssetImage("image/loginPic.png"),
//           fit: BoxFit.cover,
//         )),
//         child: Form(
//           key: formkey,
//           child: ListView(
//             padding: const EdgeInsets.all(40),
//             children: [
//               const SizedBox(height: 140),
//               Image.asset('image/logo.png', height: 80), // Add a logo image
//               const SizedBox(height: 32),
//               TextFormField(
//                   controller: nameController,
//                   validator: (val) => val!.isEmpty ? 'Invalide Name' : null,
//                   // This Function is call fron constant class
//                   decoration: kInputDecoration('Name')),
//               const SizedBox(
//                 height: 10,
//               ),
//               TextFormField(
//                   keyboardType: TextInputType.emailAddress,
//                   controller: emailController,
//                   validator: (val) =>
//                       val!.isEmpty ? 'Invalide email address' : null,
//                   // This Function is call fron constant class
//                   decoration: kInputDecoration('Email')),
//               const SizedBox(
//                 height: 10,
//               ),
//               TextFormField(
//                   controller: passwordController,
//                   obscureText: true,
//                   validator: (val) =>
//                       val!.length < 6 ? 'Required at least 6 chars' : null,
//                   // This Function is call fron constant class
//                   decoration: kInputDecoration('Password')),
//               const SizedBox(
//                 height: 10,
//               ),
//               TextFormField(
//                   controller: passwordConfirmController,
//                   obscureText: true,
//                   validator: (val) => val != passwordController.text
//                       ? 'Confirm password dose not match'
//                       : null,
//                   // This Function is call fron constant class
//                   decoration: kInputDecoration('Confirm Password')),

//               const SizedBox(
//                 height: 10,
//               ),
//               //Loading
//               loading
//                   ? const Center(
//                       child: CircularProgressIndicator(),
//                     )
//                   : kTextButton('Register', () {
//                       if (formkey.currentState!.validate()) {
//                         setState(() {
//                           loading = !loading;
//                           _registerUser();
//                         });
//                       }
//                     }),

//               const SizedBox(
//                 height: 10,
//               ),
//               kLoginRegisterHint('Dont have an account?', 'Login', () {
//                 Navigator.of(context).pushAndRemoveUntil(
//                     MaterialPageRoute(builder: (context) => const Login()),
//                     (route) => false);
//               })
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

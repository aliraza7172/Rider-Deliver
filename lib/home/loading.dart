import 'package:flutter/material.dart';

import '../constant.dart';
import '../models/api_response.dart';
import '../services/user_service.dart';
import 'login.dart';
import 'navbar.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void _lodeUserInfo() async {
    String token = await getToken();
    print(token);
    if (token == '') {
      print("object");
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) =>  Navbar()),
          (route) => false);
      // ApiResponse response = await getUserDetail();
      // print(response);
      // if (response.error == null) {
      //   Navigator.of(context).pushAndRemoveUntil(
      //       MaterialPageRoute(builder: (context) => Navbar()),
      //       (route) => false);
      // } else if (response.error == unauthorized) {
      //   Navigator.of(context).pushAndRemoveUntil(
      //       MaterialPageRoute(builder: (context) => const Login()),
      //       (route) => false);
      // } else {
      //   ScaffoldMessenger.of(context)
      //       .showSnackBar(SnackBar(content: Text('${response.error}')));
      // }
    }
  }

  @override
  void initState() {
    _lodeUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Color.fromARGB(255, 248, 248, 248),
    );
  }
}

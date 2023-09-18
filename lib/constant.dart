import 'package:flutter/material.dart';

const baseUrl = 'http://dev.codesisland.com/api';
const loginUrl = baseUrl + '/loginrider';
const registerUrl = baseUrl + '/riderregistration';
const logoutUrl = baseUrl + '/logout';
const userUrl = baseUrl + '/user';

//error
const serverError = 'Server Error';
const unauthorized = 'Unauthorized';
const somethingwentWrong = 'SomeThing went worng, Try again!';

// Input Decroation
InputDecoration kInputDecoration(String lable, [IconData? email_outlined]) {
  return InputDecoration(
      labelText: lable,
      contentPadding: const EdgeInsets.all(10),
      border: const OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Colors.black)));
}

// Text Button

TextButton kTextButton(String lable, Function onPressed) {
  return TextButton(
    child: Text(
      lable,
      style: const TextStyle(color: Colors.white),
    ),
    style: ButtonStyle(
        backgroundColor:
            MaterialStateColor.resolveWith((states) => Colors.blue),
        padding: MaterialStateProperty.resolveWith(
            (states) => const EdgeInsets.symmetric(vertical: 10))),
    onPressed: () => onPressed(),
  );
}

// login Register Hint

Row kLoginRegisterHint(String text, String lable, Function onTop) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(text),
      GestureDetector(
        child: Text(
          lable,
          style: const TextStyle(color: Colors.blue),
        ),
        onTap: () => onTop(),
      )
    ],
  );
}

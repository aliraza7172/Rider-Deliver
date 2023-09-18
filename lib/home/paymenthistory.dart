import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class PaymentHistory extends StatefulWidget {
  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistory> {
  User? _user;
  Map<String, dynamic>? paymentDetails;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getUserInfo();

    // Start a timer to refresh the page every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _getUserInfo();
    });
  }

  void _getUserInfo() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        _user = response.data as User?;
      });

      var riderResponse = await http.get(
        Uri.parse('http://dev.codesisland.com/api/riderprofile/${_user?.id}'),
      );
      var jsonResponse = jsonDecode(riderResponse.body);
      var r_p_id = jsonResponse['rider']['id'];
      var todayDetailResponse = await http.get(
        Uri.parse('http://dev.codesisland.com/api/todaydetailforrider/$r_p_id'),
      );
      print(todayDetailResponse.body);
      setState(() {
        paymentDetails = jsonDecode(todayDetailResponse.body);
      });
    } else {
      // Handle error here
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
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
            const Spacer(), // This will push the text to the right.

            const Text(
              'Payment  History',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.yellow),
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          if (paymentDetails != null) _buildPaymentDetailsCard(),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text(
                'Total Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Text(
                '${paymentDetails?['order_count']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Customize color
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Text(
                '\Rs ${paymentDetails?['totalamount']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Customize color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

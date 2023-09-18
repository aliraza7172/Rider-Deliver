import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _Order_detailState();
}

class _Order_detailState extends State<OrderHistoryScreen> {
  late int v_p_id;
  User? _user;
  List<dynamic> _orders = [];
  bool _isLoading = true;

  //fetching orders
  Future<void> fetchVendorOrders() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        _user = response.data as User?;
      });

      var vendorResponse = await http.get(
        Uri.parse('http://dev.codesisland.com/api/riderprofile/${_user?.id}'),
      );
      var jsonResponse = jsonDecode(vendorResponse.body);

      v_p_id = jsonResponse['rider']['id'];

      var orderResponse = await http.get(
        Uri.parse('http://dev.codesisland.com/api/todayriderorder/${v_p_id}'),
      );
      var orderJsonResponse = jsonDecode(orderResponse.body);
      print(orderJsonResponse);

      List<dynamic> orders = orderJsonResponse['v_order'].toList();

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVendorOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
              'Today History',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.yellow),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green), // Set the color to green
              ),
            )
          : _orders.isNotEmpty
              ? ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    return Container(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.shopping_cart),
                                title: Text(
                                  'Order#${_orders[index]['id']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order Status:   ${_orders[index]['status']}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Total Price:   Rs ${_orders[index]['total_amount']}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Date:    ${DateFormat('dd/MM/yyyy').format(DateTime.parse(_orders[index]['date']).toLocal())}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Address: ${_orders[index]['address']}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                                // trailing: const Icon(Icons.arrow_forward),
                              ),
                              const SizedBox(height: 8.0),

                              // Add spacing

                              // Row for Cancel and Accept buttons
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    'No orders histroy found',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
    );
  }
}

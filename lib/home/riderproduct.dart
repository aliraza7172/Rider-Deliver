import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'customermap.dart';
import 'orderdetailpage.dart';

class Order_detail extends StatefulWidget {
  const Order_detail({Key? key}) : super(key: key);

  @override
  State<Order_detail> createState() => _Order_detailState();
}

class _Order_detailState extends State<Order_detail> {
  late int v_p_id;
  User? _user;
  List<dynamic> _orders = [];
  bool _isLoading = true;
  Timer? _timer;

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
        Uri.parse('http://dev.codesisland.com/api/riderorder/${v_p_id}'),
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

// Function to handle accepting the order
  Future<void> acceptOrder(int orderId) async {
    String url =
        'http://dev.codesisland.com/api/acceptorderstatusrider/$orderId';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
        body: {'status': 'Accept'},
      );

      print(response.body);
      if (response.statusCode == 200) {
        // Request successful
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Order accept successfully'),
        ));
      } else {
        // Request failed
        print('Failed to update order status. Error: ${response.statusCode}');
      }
    } catch (e) {
      // Exception occurred
      print('Exception occurred while updating order status: $e');
    }
  }

  // Function to handle canceling the order
  Future<void> cancelOrder(int orderId) async {
    String url =
        'http://dev.codesisland.com/api/cancleorderstatusrider/$orderId';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
        body: {'status': 'Cancel'},
      );

      print(response.body);
      if (response.statusCode == 200) {
        // Request successful
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Order cenceled successfully'),
        ));
      } else {
        // Request failed
        print('Failed to update order status. Error: ${response.statusCode}');
      }
    } catch (e) {
      // Exception occurred
      print('Exception occurred while updating order status: $e');
    }
  }

  // Oder Done
  Future<void> doneOrder(int orderId) async {
    String url = 'http://dev.codesisland.com/api/doneorderstatusrider/$orderId';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
        body: {
          'status': 'Done',
          'Date': DateTime.now().toString(),
        },
      );

      print(response.body);
      if (response.statusCode == 200) {
        // Request successful
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Order Done successfully'),
        ));
      } else {
        // Request failed
        print('Failed to update order status. Error: ${response.statusCode}');
      }
    } catch (e) {
      // Exception occurred
      print('Exception occurred while updating order status: $e');
    }
  }

// void _launchPhoneDialer(String phoneNumber) async {
//   final Uri phoneLaunchUri = Uri(scheme: 'tel', path: phoneNumber);
//   print('Phone URI: $phoneLaunchUri'); // Debugging line
//   if (await canLaunch(phoneLaunchUri.toString())) {
//     await launch(phoneLaunchUri.toString());
//   } else {
//     print('Could not launch $phoneLaunchUri');
//   }
// }

  void _launchPhoneDialer(String phoneNumber) async {
    final String url = 'tel:$phoneNumber';
    try {
      await launch(url);
    } catch (e) {
      print('Error launching phone dialer: $e');
    }
  }

  Future<void> _requestPhonePermission() async {
    final status = await Permission.phone.request();
    if (status.isGranted) {
      // Permission granted, you can now make phone calls
      _launchPhoneDialer("03471119814");
    } else {
      // Permission denied
      print("Phone permission denied");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVendorOrders();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      fetchVendorOrders();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
              'Orders',
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
                    return GestureDetector(
                      onTap: () {
                        if (_orders[index]['status'] == 'Accept') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailPage(
                                order: _orders[index]['id'],
                                orderStatus: _orders[index]['status'],
                                totalAmount: _orders[index]['total_amount'],
                                date: _orders[index]['date'],
                                customerContact: _orders[index]
                                    ['customer_contact'],
                                address: _orders[index]['address'],
                                vendor_id: _orders[index]['vendor_id'],
                                rider_id: _orders[index]['rider_id'].toString(),
                              ),
                            ),
                          );
                        }
                      },
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
                              // leading: const Icon(Icons.shopping_cart),
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
                                    'Contact: ${_orders[index]['customer_contact']}',
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
                              trailing: const Icon(Icons.arrow_forward),
                            ),
                            const SizedBox(height: 8.0),
                            if (_orders[index]['status'] == "Order Pickup")
                              GestureDetector(
                                onTap: () {
                                  // Handle location button press
                                  // You can add your code to open the location or perform any desired action
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => custmermap(
                                        // Convert the latitude and longitude from string to double
                                        customerLongitude: double.parse(
                                            _orders[index]['longitude']),
                                        customerLatitude: double.parse(
                                            _orders[index]['latitude']),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 200.0, // Set the desired width
                                  height: 50.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: const [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 4.0),
                                      Flexible(
                                        child: Text(
                                          'Customer Location',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis, // This line allows the text to truncate with "..." if it overflows
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16.0), // Add spacing

                            // Row for Cancel and Accept buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (_orders[index]['status'] != "Accept" &&
                                    _orders[index]['status'] !=
                                        "Order Pickup" &&
                                    _orders[index]['status'] != "Done")
                                  ElevatedButton(
                                    onPressed: () {
                                      cancelOrder(_orders[index]['id']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                if (_orders[index]['status'] != "Accept" &&
                                    _orders[index]['status'] !=
                                        "Order Pickup" &&
                                    _orders[index]['status'] != "Done")
                                  ElevatedButton(
                                    onPressed: () {
                                      String customerContact =
                                          _orders[index]['customer_contact'];
                                      _launchPhoneDialer(customerContact);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('Call'),
                                  ),
                                if (_orders[index]['status'] !=
                                        "Order Pickup" &&
                                    _orders[index]['status'] != "Done")
                                  ElevatedButton(
                                    onPressed: () {
                                      acceptOrder(_orders[index]['id']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('Accept'),
                                  ),
                                if (_orders[index]['status'] == "Order Pickup")
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        doneOrder(_orders[index]['id']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Text('Done'),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    'No orders Found',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
    );
  }
}

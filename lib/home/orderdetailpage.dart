import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'location.dart';
import 'riderproduct.dart';

class OrderDetailPage extends StatefulWidget {
  final int order;
  final String orderStatus;
  final String totalAmount;
  final String date;
  final String address;
  final String vendor_id;
  final String rider_id;

  OrderDetailPage({
    required this.order,
    required this.orderStatus,
    required this.totalAmount,
    required this.date,
    required this.address,
    required this.vendor_id,
    required this.rider_id,
    required customerContact,
  });

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  List<dynamic> _orderDetails = [];
  bool _isLoading = true;
  Timer? _timer;

  void fetchOrderDetails() async {
    try {
      var orderResponse = await http.get(
        Uri.parse(
          'http://dev.codesisland.com/api/riderorderdetali/${widget.order}/${widget.rider_id}',
        ),
      );
      var orderJsonResponse = jsonDecode(orderResponse.body);
      print("ok");
      setState(() {
        var riderDetail = orderJsonResponse['rider_dteail'];
        if (riderDetail is List) {
          _orderDetails = riderDetail;
        } else if (riderDetail is Map) {
          _orderDetails = riderDetail.values.toList();
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching order details: $e');
    }
  }

  void markOrderAsPicked() async {
    String url =
        'http://dev.codesisland.com/api/updateorderstatusrider/${widget.order}';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
        body: {'status': 'Order Pickup'},
      );

      print(widget.orderStatus);
      if (response.statusCode == 200) {
        // Request successful
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Order Pickedup successfully'),
        ));
              Navigator.of(context).pop(); // Navigate back to the previous page

      } else {
        // Request failed
        print('Failed to update order status. Error: ${response.statusCode}');
      }
    } catch (e) {
      // Exception occurred
      print('Exception occurred while updating order status: $e');
    }
  }

  Future<dynamic> fetchVendorInfo(String vendorId) async {
    try {
      var vendorResponse = await http.get(
        Uri.parse('http://dev.codesisland.com/api/ordervendorid/$vendorId'),
      );
      var vendorJsonResponse = jsonDecode(vendorResponse.body);
      print(vendorResponse.body);
      return vendorJsonResponse['vendor'];
    } catch (e) {
      print('Error fetching vendor info: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchOrderDetails();
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
              'Order Details',
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
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _orderDetails.length,
                    itemBuilder: (context, index) {
                      final orderItem = _orderDetails[index];
                      final productName =
                          orderItem['product_name'] as String? ?? 'N/A';
                      final quantity = orderItem['qty'] as String? ?? 'N/A';
                      final rate = orderItem['rate'] as String? ?? 'N/A';
                      final vendorId = orderItem['vendor_id']
                          .toString(); // Convert to String

                      return FutureBuilder(
                        future: fetchVendorInfo(vendorId),
                        builder: (context, snapshot) {
                          // if (snapshot.connectionState == ConnectionState.waiting) {
                          // return const CircularProgressIndicator();
                          // } else
                          if (snapshot.hasError) {
                            return const Text('Error fetching vendor info');
                          } else if (snapshot.hasData) {
                            final vendorInfo = snapshot.data;
                            final vendorName =
                                vendorInfo['name'] as String? ?? '';
                            final vendorEmail =
                                vendorInfo['email'] as String? ?? '';
                            final vendorLongitude = double.tryParse(
                                    vendorInfo['longitude'] as String) ??
                                0.0;
                            final vendorLatitude = double.tryParse(
                                    vendorInfo['latitude'] as String) ??
                                0.0;

                            return ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(productName),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MapScreen(
                                            // vendorName: vendorName,
                                            vendorLongitude: vendorLongitude,
                                            vendorLatitude: vendorLatitude,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Icon(Icons.location_pin),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Quantity: $quantity'),
                                  Text('Rate: $rate'),
                                  Text('Vendor: $vendorName'),
                                  Text('Vendor Email: $vendorEmail'),
                                  const Divider(),
                                ],
                              ),
                            );
                          } else {
                            return const Text('No vendor info available');
                          }
                        },
                      );
                    },
                  ),
                ),
                if (widget.orderStatus != 'Order Pickup')
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        markOrderAsPicked();
                      },
                      style: ElevatedButton.styleFrom(
                        primary:
                            Colors.green, // Set the background color to green
                      ),
                      child: const Text('Order Picked'),
                    ),
                  ),
              ],
            ),
    );
  }
}

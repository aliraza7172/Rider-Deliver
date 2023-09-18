import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:freshpickup/home/ProfileScreen.dart';
import 'package:freshpickup/home/paymenthistory.dart';
import 'package:freshpickup/home/riderhisory.dart';
import 'package:freshpickup/home/riderproduct.dart';

TextStyle textStyle = const TextStyle(
  fontSize: 40,
  fontWeight: FontWeight.bold,
  letterSpacing: 2,
  fontStyle: FontStyle.italic,
);

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int currentIndex = 0;

  List<Widget> pages = [
    const Order_detail(),
    PaymentHistory(),
    const OrderHistoryScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: pages[currentIndex],
      ),
      bottomNavigationBar: ConvexAppBar(
        
        backgroundColor: Colors.green,
        items: const [
          TabItem(icon: Icons.home_outlined, title: 'Home'),
          TabItem(icon: Icons.payment_outlined, title: 'Payment'),
          TabItem(icon: Icons.history_outlined, title: 'History'),
          TabItem(icon: Icons.person_outlined, title: 'Profile'),
        ],
        initialActiveIndex: currentIndex,
        onTap: (int newIndex) {
          setState(() {
            currentIndex = newIndex;
          });
        },
      ),
    );
  }
}

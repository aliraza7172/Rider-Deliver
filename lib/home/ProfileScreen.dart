import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freshpickup/home/updateLocationMap.dart';
import 'package:freshpickup/home/viewFeedback.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'aboutus.dart';
import 'editprofile.dart';
import 'login.dart';
import 'orderHistory.dart';
import 'passwordchange.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  var r_p_id = 0;
  LocationData? _currentLocation;
  bool _locationUpdated = false;
// Track the location update status
  // get vendorJsonResponse => null;
  bool isSwitched = false; // Declare and initialize isSwitched
  bool _locationButtonVisible = true;

  @override
  void initState() {
    _getUserInfo();
    getStars();
    super.initState();
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
      r_p_id = jsonResponse['rider']['id'];

      int currentStatus = int.parse(jsonResponse['rider']['current_status']);
      setState(() {
        isSwitched = currentStatus == 0; // Reverse the logic here
      });

      print(jsonResponse);
      setState(() {
        riderJsonResponse = jsonResponse;
        _locationUpdated = true;
      });
    } else {
      // Handle error here
    }
  }

  Future<void> toggleStatus(int riderId) async {
    // Determine the new status based on the current status
    int newStatus = isSwitched ? 0 : 1;
    // print(newStatus);
    // print(riderId);

    try {
      var response = await http.post(
        Uri.parse('http://dev.codesisland.com/api/riderCurrentStatus/$riderId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'current_status': newStatus}),
      );
      print(response.body);
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Status updated successfully
        // Update the switch based on the 'current_status' field from the API response
        if (jsonResponse['success']['current_status'] == 0) {
          setState(() {
            isSwitched = true; // Set the switch to ON when status is 0
          });
        } else {
          setState(() {
            isSwitched = false; // Set the switch to OFF when status is 1
          });
        }
        print('Status updated successfully to $newStatus');
      } else {
        // Handle error here, e.g., show an error message
        print(
            'Failed to update status. HTTP Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error while updating status: $e');
    }
  }

  void getStars() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        _user = response.data as User?;
      });

      var rsp = await http.get(
        Uri.parse('http://dev.codesisland.com/api/riderprofile/${_user?.id}'),
      );
      var jsonResponse = jsonDecode(rsp.body);
      r_p_id = jsonResponse['rider']['id'];

      // print(jsonResponse);
      // print(r_p_id);
      var riderResponse = await http.get(
        Uri.parse('http://dev.codesisland.com/api/riderFeedback/$r_p_id'),
      );
      var jstar = jsonDecode(riderResponse.body);

      setState(() {
        riderjr = jstar;
      });
    } else {
      // Handle error here
    }
  }

  Future<void> _updateRiderLocation(
      double latitude, double longitude, LocationData locationData) async {
    print(r_p_id);
    String url = 'http://dev.codesisland.com/api/updateriderlocation/$r_p_id';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
        body: {
          "latitude": latitude.toString(),
          "longitude": longitude.toString()
        },
      );
      print(response.body);
      // Update the _currentLocation and set locationUpdated to true
      setState(() {
        _currentLocation = locationData;
        _locationUpdated = true;
      });
    } catch (e) {
      // Exception occurred
      print('Exception occurred while updating order status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 80),
        children: [
          Center(
            child: CircleAvatar(
              radius: 70,
              child: Image.asset('image/profilePic.jpg'),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display the star icon and rating number below the name
                Text(
                  '${riderJsonResponse != null ? riderJsonResponse["rider"]["name"] : " "}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                    height:
                        8), // Add spacing between the name and the star/rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Rating  ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      // riderjr
                      '${riderjr != null ? riderjr["avg"] : " "}',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    const Icon(
                      Icons.star,
                      color: Colors.yellow, // You can customize the star color
                      size: 28, // You can adjust the size of the star icon
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ListTile(
              leading: Icon(Icons.switch_left_outlined),
              title: Text('Current Status'),
              trailing: Switch(
                value: isSwitched, // Replace isSwitched with your own variable
                onChanged: (value) {
                  setState(() {
                    isSwitched =
                        value; // Update the state when the switch is toggled
                  });
                  toggleStatus(r_p_id);
                },
                activeTrackColor: Colors
                    .green, // Change the track color when the switch is ON
                activeColor: Colors
                    .green, // Change the thumb color when the switch is ON
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    name: riderJsonResponse != null &&
                            riderJsonResponse["rider"]["name"] != null
                        ? riderJsonResponse["rider"]["name"]
                        : '',
                    address: riderJsonResponse != null &&
                            riderJsonResponse["rider"]["address"] != null
                        ? riderJsonResponse["rider"]["address"]
                        : '',
                    email: riderJsonResponse != null &&
                            riderJsonResponse["rider"]["email"] != null
                        ? riderJsonResponse["rider"]["email"]
                        : '',
                    phone: riderJsonResponse != null &&
                            riderJsonResponse["rider"]["phone"] != null
                        ? riderJsonResponse["rider"]["phone"]
                        : '',
                    id: riderJsonResponse != null &&
                            riderJsonResponse["rider"]["id"] != null
                        ? riderJsonResponse["rider"]["id"].toString()
                        : '',
                  ),
                ),
              );
            },
            child: const Card(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('Edit Profile'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Orderhistory(),
                  ),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.history),
                title: Text('View Order History'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Visibility(
              visible:
                  _locationButtonVisible, // Show the button if _locationButtonVisible is true
              child: InkWell(
                onTap: () async {
                  var locationData = await Navigator.push<LocationData>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateLocationScreen(),
                    ),
                  );
                  if (locationData != null) {
                    double latitude = locationData.latitude!;
                    double longitude = locationData.longitude!;

                    print("Latitude: $latitude, Longitude: $longitude");

                    // Call the API to update the rider's location
                    _updateRiderLocation(latitude, longitude, locationData);

                    // Hide the button after tapping
                    setState(() {
                      _locationButtonVisible = false;
                    });
                  }
                },
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Update Location'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _currentLocation != null
                          ? Text(
                              "Lat: ${_currentLocation!.latitude}, Lng: ${_currentLocation!.longitude}",
                            )
                          : const Text("Tap to update location"),
                      _currentLocation != null
                          ? const Text("Location Updated")
                          : const SizedBox.shrink(),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
          ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewFeedbackPage(
                        id: riderJsonResponse != null &&
                                riderJsonResponse["rider"]["id"] != null
                            ? riderJsonResponse["rider"]["id"].toString()
                            : '',
                      ),
                    ),
                  );
                },
                child: const ListTile(
                  leading: Icon(Icons.feedback_outlined),
                  title: Text('View Feedback'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('About Us'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PasswordChangeScreen(
                      id: riderJsonResponse != null &&
                              riderJsonResponse["rider"]["id"] != null
                          ? riderJsonResponse["rider"]["id"].toString()
                          : '',
                    ),
                  ),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('Change Password'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: InkWell(
              onTap: () {
                logout().then((value) => {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                          (route) => false)
                    });
              },
              child: const ListTile(
                leading: Icon(Icons.logout),
                title: Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

dynamic riderJsonResponse;
dynamic riderjr;

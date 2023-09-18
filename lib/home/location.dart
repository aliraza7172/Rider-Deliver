import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  final double vendorLatitude;
  final double vendorLongitude;

  MapScreen({
    required this.vendorLatitude,
    required this.vendorLongitude,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LocationData? _currentLocation;
  List<LatLng> _routeCoordinates = [];
  double _totalDistance = 0.0;
  double _remainingDistance = 0.0;
  int _estimatedDuration = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) {
      if (_currentLocation != null) {
        _mapController.move(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          15.0,
        );
        _getRouteCoordinates();
      }
    });

    // Start a timer to automatically refresh the map every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      _getCurrentLocation().then((_) {
        if (_currentLocation != null) {
          _getRouteCoordinates();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    setState(() {
      _currentLocation = locationData;
    });
  }

  Future<void> _getRouteCoordinates() async {
    if (_currentLocation != null) {
      try {
        var apiUrl =
            'http://router.project-osrm.org/route/v1/driving/${_currentLocation!.longitude},${_currentLocation!.latitude};${widget.vendorLongitude},${widget.vendorLatitude}?overview=full&geometries=geojson';
        var response = await http.get(Uri.parse(apiUrl));
        var jsonResponse = jsonDecode(response.body);

        var routes = jsonResponse['routes'];
        if (routes != null && routes.length > 0) {
          var route = routes[0];
          var geometry = route['geometry']['coordinates'];
          var coordinates = geometry.map<LatLng>((coord) {
            return LatLng(coord[1], coord[0]);
          }).toList();

          setState(() {
            _routeCoordinates = coordinates;
            _totalDistance =
                route['distance'] / 1000.0; // convert to kilometers
            _remainingDistance = _totalDistance;
            _estimatedDuration = route['duration'] ~/ 60; // convert to minutes
          });

          // Fetch vendor details from API
          var vendorDetailsResponse = await http.get(Uri.parse(
              'http://dev.codesisland.com/api/vendor/${widget.vendorLatitude}/${widget.vendorLongitude}'));
          var vendorDetailsJsonResponse =
              jsonDecode(vendorDetailsResponse.body);

          var vendorName = vendorDetailsJsonResponse['vendor_name'];
          var vendorAddress = vendorDetailsJsonResponse['vendor_address'];

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Vendor Details'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: $vendorName'),
                  Text('Address: $vendorAddress'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        print('Error fetching route coordinates: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaflet Map'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation != null
                  ? LatLng(
                      _currentLocation!.latitude!, _currentLocation!.longitude!)
                  : LatLng(30.3753, 69.3451),
              zoom: 13.0,
            ),
            layers: [
              TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              PolylineLayerOptions(
                polylines: [
                  Polyline(
                    points: _routeCoordinates,
                    strokeWidth: 3.0,
                    color: Colors.blue,
                  ),
                ],
              ),
              if (_currentLocation != null)
                MarkerLayerOptions(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      ),
                      builder: (ctx) =>
                          const Icon(Icons.directions_bike, color: Colors.red),
                    ),
                  ],
                ),
              MarkerLayerOptions(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point:
                        LatLng(widget.vendorLatitude, widget.vendorLongitude),
                    builder: (ctx) => GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Vendor Details'),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Name: Vendor Name'), // Replace with the actual vendor name
                                Text(
                                    'Address: Vendor Address'), // Replace with the actual vendor address
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Icon(Icons.location_on, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total Distance:',
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_totalDistance.toStringAsFixed(2)} km',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Remaining Distance:',
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_remainingDistance.toStringAsFixed(2)} km',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Estimated Duration:',
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$_estimatedDuration min',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCurrentLocation,
        backgroundColor: Colors.green,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  void _goToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        15.0,
      );
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: MapScreen(
      vendorLatitude: 37.7749, // Replace with the vendor's latitude
      vendorLongitude: -122.4194, // Replace with the vendor's longitude
    ),
  ));
}

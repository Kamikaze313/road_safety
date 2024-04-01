import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:project_road_safety/api.dart';

class MapScreen extends StatefulWidget {
  final LatLng startCord;
  final LatLng endCord;

  const MapScreen({
    Key? key,
    required this.startCord,
    required this.endCord,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late List<dynamic> listOfPoints;
  late List<LatLng> points;
  late List<dynamic> listOfRoadConditions; // List to store road conditions data
  late LatLng currentLocation; // Variable to store current location

  @override
  void initState() {
    super.initState();
    listOfPoints = [];
    points = [];
    listOfRoadConditions = []; // Initialize listOfRoadConditions
    currentLocation = widget.startCord; // Initialize to startCord
    _fetchUserLocation(); // Start fetching user's location
    getCoordinates(); // Fetch coordinates when the page opens
  }

  // Function to fetch user's location every 500ms
  void _fetchUserLocation() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      _getUserLocation();
    });
  }

  // Function to get user's location
  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> getCoordinates() async {
    // Make the first API request to get route coordinates
    var routeResponse = await http.get(getRouteUrl(
      "${widget.startCord.longitude},${widget.startCord.latitude}",
      '${widget.endCord.longitude},${widget.endCord.latitude}',
    ));

    // Process the first API response
    setState(() {
      if (routeResponse.statusCode == 200) {
        var routeData = jsonDecode(routeResponse.body);
        listOfPoints = routeData['features'][0]['geometry']['coordinates'];
        points = listOfPoints
            .map((p) => LatLng(p[1].toDouble(), p[0].toDouble()))
            .toList();
      }
    });

    // Make the second API request for road conditions
    try {
      var roadConditionsResponse = await http.get(
        Uri.parse(
            'http://172.232.106.170:3000/roadConditions?latitude=${widget.startCord.latitude}&longitude=${widget.startCord.longitude}'),
      );

      // Process the second API response
      if (roadConditionsResponse.statusCode == 200) {
        var roadConditionsData = jsonDecode(roadConditionsResponse.body);

        // Initialize listofroadconditions
        List<dynamic> listofroadconditions = [];

        // Assuming road conditions data is in the same format as the provided example
        for (var feature in roadConditionsData) {
          var coordinates = feature['geometry']['coordinates'];
          var type = feature['properties']['type'];

          // Add road conditions data to listofroadconditions
          listofroadconditions.add({
            'coordinates': coordinates,
            'type': type,
          });
        }

        // Update the UI
        setState(() {
          // Assign listofroadconditions to the state variable
          listOfRoadConditions = listofroadconditions;
        });
      } else {
        // Handle the error or unexpected response
        print(
            'Failed to fetch road conditions. Status code: ${roadConditionsResponse.statusCode}');
      }
    } catch (error) {
      // Handle any exceptions that occurred during the request
      print('Error fetching road conditions: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(zoom: 14, center: currentLocation),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
          PolylineLayer(
            polylineCulling: false,
            polylines: [
              Polyline(
                points: points,
                color: Color.fromARGB(255, 44, 44, 44),
                strokeWidth: 7,
              ),
              Polyline(
                points: points,
                color: Color.fromARGB(255, 189, 60, 60),
                strokeWidth: 2,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: widget.endCord,
                width: 80,
                height: 80,
                child: IconButton(
                  onPressed: () {
                    print('End Marker tapped!');
                  },
                  icon: const Icon(Icons.location_on),
                  color: Colors.red,
                  iconSize: 45,
                ),
              ),
              Marker(
                point: currentLocation, // Use currentLocation as the point
                width: 80,
                height: 80,
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: Color.fromARGB(255, 26, 57, 83),
                  size: 45,
                ),
              ),
              // Add markers for each road condition
              for (var feature in listOfRoadConditions)
                Marker(
                  point: LatLng(
                    feature['coordinates'][1].toDouble(),
                    feature['coordinates'][0].toDouble(),
                  ),
                  width: 80,
                  height: 80,
                  child: _buildMarkerIcon(feature['type']),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper function to build marker icon based on the type
  Widget _buildMarkerIcon(String type) {
    // Determine marker icon based on the type
    String assetName;
    if (type == 'pothole') {
      assetName = 'assets/pothole.png';
    } else if (type == 'speed_breaker') {
      assetName = 'assets/speed_breaker.png';
    } else {
      // Default icon
      assetName = 'assets/default_icon.png'; // Path to a default icon
    }

    return Image.asset(
      assetName,
      width: 45,
      height: 45,
    );
  }
}

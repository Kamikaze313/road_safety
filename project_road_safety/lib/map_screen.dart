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
  late LatLng currentLocation; // Variable to store current location

  @override
  void initState() {
    super.initState();
    listOfPoints = [];
    points = [];
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
    var response = await http.get(getRouteUrl(
      "${widget.startCord.longitude},${widget.startCord.latitude}",
      '${widget.endCord.longitude},${widget.endCord.latitude}',
    ));
    setState(() {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        listOfPoints = data['features'][0]['geometry']['coordinates'];
        points = listOfPoints
            .map((p) => LatLng(p[1].toDouble(), p[0].toDouble()))
            .toList();
        print(listOfPoints);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Color.fromARGB(255, 158, 8, 207).withOpacity(1.0), // Keep hue and brightness constant
          BlendMode.saturation,
        ),
        child: FlutterMap(
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
              
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}

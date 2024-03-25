import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'map_screen.dart';

class NavigatePage extends StatefulWidget {
  const NavigatePage({Key? key}) : super(key: key);

  @override
  _NavigatePageState createState() => _NavigatePageState();
}

class _NavigatePageState extends State<NavigatePage> {
  late LatLng startCord = LatLng(0.0, 0.0); // Initialize with a default value
  late TextEditingController placeNameController;

  @override
  void initState() {
    super.initState();
    placeNameController = TextEditingController();
    // Get the current location as start coordinate
    getCurrentLocation();
  }

  @override
  void dispose() {
    placeNameController.dispose();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    // Check if location permission is granted
    PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus == PermissionStatus.granted) {
      try {
        // Get current position
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          startCord = LatLng(position.latitude, position.longitude);
        });
      } catch (e) {
        print('Error getting current location: $e');
      }
    } else {
      print('Location permission not granted');
    }
  }

  Future<LatLng?> getCoordinatesFromPlaceName(String placeName) async {
    final apiKey = '65f976fec927b426363553glq455095';
    final apiUrl = 'https://geocode.maps.co/search?q=$placeName&api_key=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final place = data.first;
          final lat = double.parse(place['lat']);
          final lon = double.parse(place['lon']);
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      print('Error fetching coordinates: $e');
    }

    return null;
  }

  void navigate(BuildContext context) async {
    final placeName = placeNameController.text;
    if (placeName.isNotEmpty) {
      final LatLng? endCord = await getCoordinatesFromPlaceName(placeName);
      if (endCord != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(startCord: startCord, endCord: endCord),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to find coordinates for the specified place.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please enter a place name.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter your destination', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: Container(
        color: Color(0xFF713C5D),
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFF3D9D8),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextField(
                controller: placeNameController,
                decoration: InputDecoration(
                  labelText: 'Place Name',
                  hintText: 'Enter the name of the place',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => navigate(context),
              child: Text(
                'Lets GO!',
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA97D8D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

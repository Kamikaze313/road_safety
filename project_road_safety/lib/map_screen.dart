import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List listOfPoints = [];
  List<LatLng> points = [];
  LatLng startCord = LatLng(6.145332, 1.243344); // Start coordinate
  LatLng endCord =
      LatLng(6.125231015668568, 1.2160116523406839); // End coordinate

  getCoordinates() async {
    var response = await http.get(getRouteUrl(
        "${startCord.longitude},${startCord.latitude}",
        '${endCord.longitude},${endCord.latitude}'));
    setState(() {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        listOfPoints = data['features'][0]['geometry']['coordinates'];
        points = listOfPoints
            .map((p) => LatLng(p[1].toDouble(), p[0].toDouble()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(zoom: 15, center: LatLng(6.131015, 1.223898)),
        children: [
          // Layer that adds the map
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
          // Layer that adds points the map
          MarkerLayer(
            markers: [
              // First Marker
              Marker(
                point: startCord,
                width: 80,
                height: 80,
                child: IconButton(
                  // Use 'child' instead of 'builder'
                  onPressed: () {
                    print('Start Marker tapped!');
                    // Add your custom logic here
                  },
                  icon: const Icon(Icons.location_on),
                  color: Colors.green,
                  iconSize: 45,
                ),
              ),

              // Second Marker
              Marker(
                point: endCord,
                width: 80,
                height: 80,
                child: IconButton(
                  onPressed: () {
                    print('End Marker tapped!');
                    // Add your custom logic here
                  },
                  icon: const Icon(Icons.location_on),
                  color: Colors.red,
                  iconSize: 45,
                ),
              ),
            ],
          ),

          // Polylines layer
          PolylineLayer(
            polylineCulling: false,
            polylines: [
              Polyline(points: points, color: Colors.black, strokeWidth: 5),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => getCoordinates(),
        child: const Icon(
          Icons.route,
          color: Colors.white,
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:project_road_safety/api.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:uuid/uuid.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'dart:typed_data';
import 'package:project_road_safety/navigate_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

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
  MapController mapController = MapController();
  late IO.Socket socket;
  final player = AudioPlayer();
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  mongo.Db? db;
  Timer? _timer;
  bool isTracking = true;
  bool isDialogShowing = false;
  bool isBlListening = false;

  Future<void> playAlertSound() async {
    final player = AudioPlayer();
    player.play(AssetSource('sounds/alert.mp3'));
  }

  Future<void> playAlertSound2() async {
    final player = AudioPlayer();
    player.play(AssetSource('sounds/alert2.mp3'));
  }

  @override
  void initState() {
    // isBlListening = false;
    super.initState();
    _initBluetooth();
    _initMongoDB();
    // startListening();
    listOfPoints = [];
    points = [];
    listOfRoadConditions = []; // Initialize listOfRoadConditions
    currentLocation = widget.startCord; // Initialize to startCord
    _fetchUserLocation(); // Start fetching user's location
    getCoordinates(); // Fetch coordinates when the page opens

    // Initialize and connect the SocketIO client
    socket = IO.io('http://98.70.74.211:3001', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.onConnect((_) {
      print('connected to server');
    });

    socket.connect();
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  // Function to fetch user's location every 500ms
  void _fetchUserLocation() {
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      _getUserLocation();
    });
  }

  // Function to get user's location
  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      if (isTracking) {
        mapController.move(currentLocation, 17.6); // 17.6 is the zoom level
      }
      socket.emit('getRoadConditions',
          {'latitude': position.latitude, 'longitude': position.longitude});
      var socketResponse = socket.on('roadConditions', (data) {
        // print('data is: $data');
        List<Map<String, dynamic>> jsonData = data.cast<Map<String, dynamic>>();
        print("json data is: $jsonData");
        for (var item in jsonData) {
          Map<String, dynamic> properties = item['properties'];
          String type = properties['type'];
          print(isDialogShowing);
          if (type == 'pothole' && !isDialogShowing) {
            isDialogShowing = true;
            playAlertSound();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Pothole Alert'),
                  content: Text('There is a pothole ahead. Drive carefully!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else if (type == 'speed_breaker' && !isDialogShowing) {
            isDialogShowing = true;
            // Handle speed breaker alert
            playAlertSound2();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Speed Breaker Alert'),
                  content:
                      Text('There is a speed breaker ahead. Drive carefully!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else if (jsonData == "[]") {
            print('No road conditions ahead');
            isDialogShowing = false;
          } else {
            print('else condition');
          }
        }
      });
    });
  }

  void _initBluetooth() async {
    // Request permission to use Bluetooth
    await _bluetooth.requestEnable();
    if (await Permission.bluetooth.request().isGranted &&
        await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      print('Bluetooth permission granted');
    } else {
      print('Bluetooth permission not granted');
    }

    try {
      _connection = await BluetoothConnection.toAddress('00:20:10:08:F7:C6');
      print('Connected to the device');
      _listenForBluetoothData();
      // isBlListening = false;
    } catch (e) {
      print('Could not connect to the bluetooth device due to exception: $e');
    }
  }

  void _initMongoDB() async {
    db = mongo.Db(
        "mongodb://jaanprjt:V4zh4th0pp3@ac-abzhbjl-shard-00-00.hpnvxpe.mongodb.net:27017,ac-abzhbjl-shard-00-01.hpnvxpe.mongodb.net:27017,ac-abzhbjl-shard-00-02.hpnvxpe.mongodb.net:27017/road_data?ssl=true&replicaSet=atlas-zzhu3n-shard-0&authSource=admin&retryWrites=true&w=majority&appName=Cluster0");
    await db?.open();
    print("Connected to MongoDB");

    test();
  }

  Future<void> test() async {
    var faker = Faker();
    var uuid = Uuid();
    var id = faker.guid.guid();
    var reporter = faker.person.name();
    var latitude = faker.randomGenerator.decimal();
    var longitude = faker.randomGenerator.decimal();
    var collection = db!.collection('pothump');
    // print last 3 documents inserted into the collection
    var result = await collection.find().toList();
    print("mongo result : $result");
    try {
      mongo.WriteResult res = await collection.insertOne({
        "_id": uuid.v4(),
        "type": "Feature",
        "properties": {
          "id": id,
          "type": "pothole",
          "reporter": reporter,
        },
        "geometry": {
          "type": "Point",
          "coordinates": [latitude, longitude]
        },
      });

      print('Insertion acknowledged: ${res.isAcknowledged}');
      print('Number of documents inserted: ${res.nInserted}');
    } catch (e) {
      print('Error during insertion: $e');
    }
  }
  // void startListening() {
  //   _timer = Timer.periodic(
  //       Duration(seconds: 1), (Timer t) => _listenForBluetoothData());
  // }

  void _listenForBluetoothData() {
    try {
      // if (!isBlListening) {
      print("initializing bluetooth listening");
      _connection?.input?.asBroadcastStream().listen((Uint8List data) async {
        String receivedData = String.fromCharCodes(data);
        //split lines on new line, remove the second part and take the first part
        receivedData = receivedData.split('\n')[0];
        print("received data is: $receivedData");
        if (receivedData.contains('hole:1')) {
          print("inserting into MongoDB");
          Future.delayed(const Duration(seconds: 5), () async {
            print("detecting pothole succesfully");
            await _insertIntoMongoDB(receivedData);
            print('Delaying for 5 seconds');
            //alert the user that pothole is added to the map with a pop up
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Pothole Alert'),
                  content: Text('Pothole added to the map!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          });
        }
      });
      // isBlListening = true;
      // }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> _insertIntoMongoDB(String data) async {
    List<String> parts = data.split(',');
    print("list elemtns : $parts");
    double latitude = double.parse(parts[2].split(':')[1]);
    double longitude = double.parse(parts[3].split(':')[1]);
    print("lat $latitude, long $longitude");

    var uuid = Uuid();
    String id = Random().nextInt(9999).toString().padLeft(4, '0');
    User? user = FirebaseAuth.instance.currentUser;
    String reporter = user != null ? user.email!.split('@')[0] : "";

    mongo.DbCollection collection = db!.collection('pothump');
    //print last 3 documents inserted into the collection
    // var result = await collection.find().toList();
    // print("mongo result : $result");
    var res = await collection.insert({
      "_id": uuid.v4(),
      "type": "Feature",
      "properties": {
        "id": id,
        "type": "pothole",
        "reporter": reporter,
      },
      "geometry": {
        "type": "Point",
        "coordinates": [latitude, longitude]
      }
    });
    print("insertion complete, res : $res");
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
            'http://98.70.74.211:3000/roadConditions?latitude=${widget.startCord.latitude}&longitude=${widget.startCord.longitude}'),
      );

      // Process the second API response
      if (roadConditionsResponse.statusCode == 200) {
        var roadConditionsData = jsonDecode(roadConditionsResponse.body);
        print(roadConditionsData);
        // Initialize listofroadconditions
        List<dynamic> listofroadconditions = [];

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NavigatePage()),
            );
          },
        ),
        title: Text('Map Screen'),
      ),
      body: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: mapController,
            options: MapOptions(zoom: 17.6, center: currentLocation),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.thunderforest.com/Mobile-Atlas/{z}/{x}/{y}.png?apikey=d9865cc563c44d0588dd256f83599bc3",
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
              PolylineLayer(
                polylineCulling: false,
                polylines: [
                  Polyline(
                    points: points,
                    color: Color.fromARGB(255, 44, 44, 44),
                    strokeWidth: 14,
                  ),
                  Polyline(
                    points: points,
                    color: Color(0xFF713C5D),
                    strokeWidth: 10,
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
                    width: 180.0,
                    height: 180.0,
                    point: currentLocation,
                    child: Icon(
                      Icons.directions_car,
                      size: 45,
                    ),
                  ),
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
          Positioned(
            bottom: 16,
            right: 16,
            child: ToggleButtons(
              children: <Widget>[
                Icon(Icons.track_changes),
              ],
              onPressed: (int index) {
                setState(() {
                  isTracking = !isTracking;
                });
              },
              isSelected: [isTracking],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build marker icon based on the type
  Widget _buildMarkerIcon(String type) {
    // Determine marker icon based on the type
    String assetName;
    double iconSize = 10;
    if (type == 'pothole') {
      assetName = 'assets/pothole.png';
      iconSize = 5;
    } else if (type == 'speed_breaker') {
      assetName = 'assets/speed_breaker.png';
      iconSize = 5;
    } else {
      // Default icon
      assetName = 'assets/default_icon.png'; // Path to a default icon
    }

    return Container(
      width: iconSize,
      height: iconSize,
      child: Image.asset(
        assetName,
        fit: BoxFit.cover,
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:hive/hive.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'history_page.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   Completer<GoogleMapController> _googleMapController = Completer();
//   CameraPosition? _cameraPosition;
//   Location? _location;
//   LocationData? _currentLocation;
//   Set<Polyline> _polylines = {};
//   List<LatLng> _routeCoordinates = [];
//   Set<Marker> _markers = {};
//   bool _isTracking = false;
//   int _polylineCounter = 0;
//   late Box routeHistoryBox;
//
//   @override
//   void initState() {
//     super.initState();
//     init();
//     _setupConnectivityListener();
//   }
//
//   init() async {
//     _location = Location();
//     routeHistoryBox = Hive.box('routeHistoryBox');
//     _cameraPosition = CameraPosition(target: LatLng(0, 0), zoom: 15);
//     await _initLocation();
//   }
//
//   Future<void> _initLocation() async {
//     _currentLocation = await _location?.getLocation();
//     if (_currentLocation != null) {
//       LatLng currentLatLng = LatLng(
//         _currentLocation!.latitude!,
//         _currentLocation!.longitude!,
//       );
//       moveToPosition(currentLatLng);
//     }
//     _location?.onLocationChanged.listen((newLocation) {
//       if (_isTracking) {
//         _currentLocation = newLocation;
//         LatLng currentLatLng = LatLng(
//           _currentLocation!.latitude!,
//           _currentLocation!.longitude!,
//         );
//         moveToPosition(currentLatLng);
//         _routeCoordinates.add(currentLatLng);
//         _createPolylines();
//       }
//     });
//   }
//
//   void _createPolylines() {
//     setState(() {
//       _polylines.add(
//         Polyline(
//           polylineId: PolylineId("route_$_polylineCounter"),
//           color: Colors.blue,
//           points: List.from(_routeCoordinates),
//           width: 5,
//         ),
//       );
//     });
//   }
//
//   void _addStartMarker(LatLng position, int routeIndex) {
//     setState(() {
//       _markers.add(
//         Marker(
//           markerId: MarkerId("start_$routeIndex"),
//           position: position,
//           infoWindow: InfoWindow(title: "Start of Route $routeIndex"),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//         ),
//       );
//     });
//   }
//
//   void _addStopMarker(LatLng position, int routeIndex) {
//     setState(() {
//       _markers.add(
//         Marker(
//           markerId: MarkerId("stop_$routeIndex"),
//           position: position,
//           infoWindow: InfoWindow(title: "End of Route $routeIndex"),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ),
//       );
//     });
//   }
//
//   moveToPosition(LatLng latLng) async {
//     GoogleMapController mapController = await _googleMapController.future;
//     mapController.animateCamera(CameraUpdate.newCameraPosition(
//         CameraPosition(target: latLng, zoom: 15)));
//   }
//
//   /// Save route to Hive
//   void _saveRouteToHistory() {
//     if (_routeCoordinates.isNotEmpty) {
//       routeHistoryBox.add({
//         'coordinates': _routeCoordinates.map((latLng) => {
//           'lat': latLng.latitude,
//           'lng': latLng.longitude,
//         }).toList(),
//         'timestamp': DateTime.now().toIso8601String(),
//       });
//     }
//   }
//
//   /// Sync data to API when online
//   Future<void> _syncDataToApi() async {
//     if (routeHistoryBox.isNotEmpty) {
//       List<Map<String, dynamic>> historyData = routeHistoryBox.values.cast<Map<String, dynamic>>().toList();
//       print("Syncing ${historyData.length} routes to API...");
//       await Future.delayed(Duration(seconds: 2)); // Simulate API call
//       print("Data synced successfully!");
//       await routeHistoryBox.clear(); // Clear after syncing
//     }
//   }
//
//   /// Listen for connectivity changes
//   void _setupConnectivityListener() {
//     Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
//       if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
//         _syncDataToApi();
//       }
//     });
//   }
//
//   void showToast(String message) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.black,
//       textColor: Colors.white,
//       fontSize: 20.0,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Route Tracker')),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: _cameraPosition!,
//             mapType: MapType.normal,
//             polylines: _polylines,
//             markers: _markers,
//             myLocationEnabled: true,
//             onMapCreated: (GoogleMapController controller) {
//               _googleMapController.complete(controller);
//             },
//           ),
//           Positioned(
//             bottom: 20,
//             right: 20,
//             child: ElevatedButton(
//               onPressed: () async {
//                 if (_isTracking) {
//                   _isTracking = false;
//                   if (_routeCoordinates.isNotEmpty) {
//                     _addStopMarker(_routeCoordinates.last, _polylineCounter);
//                     _saveRouteToHistory();
//                     showToast("Tracking stopped");
//                     _routeCoordinates.clear();
//                   }
//                 } else {
//                   _isTracking = true;
//                   _polylineCounter++;
//                   showToast("Tracking started");
//                 }
//                 setState(() {});
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _isTracking ? Colors.red : Colors.green,
//               ),
//               child: Text(_isTracking ? 'Stop' : 'Start'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'history_page.dart'; // Import your existing HistoryPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  Location? _location;
  LocationData? _currentLocation;
  Set<Polyline> _polylines = {};
  List<LatLng> _routeCoordinates = [];
  List<Map<String, dynamic>> routeHistory = [];
  Set<Marker> _markers = {};
  bool _isTracking = false;
  int _polylineCounter = 0;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    _location = Location();
    _cameraPosition = CameraPosition(
      target: LatLng(0, 0),
      zoom: 15,
    );
    _initLocation();
  }

  _initLocation() async {
    _currentLocation = await _location?.getLocation();
    if (_currentLocation != null) {
      LatLng currentLatLng = LatLng(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
      );
      moveToPosition(currentLatLng);
    }
    _location?.onLocationChanged.listen((newLocation) {
      if (_isTracking) {
        _currentLocation = newLocation;
        LatLng currentLatLng = LatLng(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        );
        moveToPosition(currentLatLng);
        _routeCoordinates.add(currentLatLng);
        _createPolylines();
      }
    });
  }

  void _createPolylines() {
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId("route_${_polylineCounter}"),
          color: Colors.blue,
          points: List.from(_routeCoordinates),
          width: 5,
        ),
      );
    });
  }

  void _addStartMarker(LatLng position, int routeIndex) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("start_$routeIndex"),
          position: position,
          infoWindow: InfoWindow(title: "Start of Route $routeIndex"),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    });
  }

  void _addStopMarker(LatLng position, int routeIndex) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("stop_$routeIndex"),
          position: position,
          infoWindow: InfoWindow(title: "End of Route $routeIndex"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  moveToPosition(LatLng latLng) async {
    GoogleMapController mapController = await _googleMapController.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15)));
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 20.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Route Tracker',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
        body: _buildBody());
  }

  Widget _buildBody() {
    return _getMap();
  }

  Widget _getMap() {
    return SafeArea(
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _cameraPosition!,
            mapType: MapType.normal,
            polylines: _polylines,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              if (!_googleMapController.isCompleted) {
                _googleMapController.complete(controller);
              }
            },
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 40,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0, 3),
                        spreadRadius: 4,
                        blurRadius: 6)
                  ],
                ),
                child: ClipOval(child: Image.asset("assets/download.jpeg")),
              ),
            ),
          ),
          // Location Button
          Positioned(
            bottom: 100,
            right: 10,
            child: FloatingActionButton(
              onPressed: () async {
                _currentLocation = await _location?.getLocation();
                if (_currentLocation != null) {
                  LatLng currentLatLng = LatLng(
                    _currentLocation!.latitude!,
                    _currentLocation!.longitude!,
                  );
                  moveToPosition(currentLatLng);
                }
              },
              child: Icon(Icons.my_location),
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
            ),
          ),
          // History Button
          Positioned(
            top: 20, // Aligns the button to the top
            right: 20, // Aligns the button to the right
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HistoryPage(routeHistory)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text('History'),
            ),
          ),
          // Start/Stop Tracking Button
          Positioned(
            bottom: 20,
            right: 150,
            child: ElevatedButton(
              onPressed: () async {
                if (_isTracking) {
                  setState(() {
                    _isTracking = false;
                    if (_routeCoordinates.isNotEmpty) {
                      LatLng stopLatLng = _routeCoordinates.last;
                      _addStopMarker(stopLatLng, _polylineCounter);
                      routeHistory.add({
                        'coordinates': List<LatLng>.from(_routeCoordinates),
                      });
                      _routeCoordinates = [];
                    }
                  });
                  showToast("Tracking is stopped");
                } else {
                  showToast("Tracking has started");
                  setState(() {
                    _isTracking = true;
                    _polylineCounter++;
                    _routeCoordinates = [];
                  });
                  _currentLocation = await _location?.getLocation();
                  if (_currentLocation != null) {
                    LatLng startLatLng = LatLng(
                      _currentLocation!.latitude!,
                      _currentLocation!.longitude!,
                    );
                    _routeCoordinates.add(startLatLng);
                    _addStartMarker(startLatLng, _polylineCounter);
                    moveToPosition(startLatLng);
                    _createPolylines();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTracking ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(_isTracking ? 'Stop' : 'Start'),
            ),
          ),
        ],
      ),
    );
  }
}

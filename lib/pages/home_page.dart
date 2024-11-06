import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'history_page.dart'; // Import HistoryPage

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

  moveToPosition(LatLng latLng) async {
    GoogleMapController mapController = await _googleMapController.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15)));
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return _getMap();
  }

  Widget _getMarker() {
    return Container(
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
    );
  }

  Widget _getMap() {
    return SafeArea(
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _cameraPosition!,
            mapType: MapType.normal,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled:
                false, // Disable default My Location button
            onMapCreated: (GoogleMapController controller) {
              if (!_googleMapController.isCompleted) {
                _googleMapController.complete(controller);
              }
            },
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: _getMarker(),
            ),
          ),
          // Custom My Location Button
          Positioned(
            bottom: 100, // Adjust to position above the zoom controls
            right: 10,
            child: FloatingActionButton(
              onPressed: () async {
                // Get the current location and move the camera
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
              mini: true, // Smaller size button
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
            ),
          ),
          // Start and Stop tracking buttons
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isTracking = true;
                      _polylineCounter++;
                      _routeCoordinates = [];
                    });
                    _currentLocation = await _location?.getLocation();
                    if (_currentLocation != null) {
                      LatLng currentLatLng = LatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      );
                      _routeCoordinates.add(currentLatLng);
                      moveToPosition(currentLatLng);
                      _createPolylines();
                    }
                  },
                  child: Text('Start'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(
                      () {
                        _isTracking = false;
                        if (_routeCoordinates.isNotEmpty) {
                          routeHistory.add({
                            'coordinates': List<LatLng>.from(_routeCoordinates),
                          });
                          _routeCoordinates =
                              []; // Clear route after saving to history
                        }
                      },
                    );
                  },
                  child: Text('Stop'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoryPage(routeHistory)),
                    );
                  },
                  child: Text('History'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

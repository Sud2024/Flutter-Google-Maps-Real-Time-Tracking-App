import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_tracker/pages/view_history.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart'; // Required for Clipboard functionality

class HistoryPage extends StatefulWidget {
  final List<Map<String, dynamic>> routeHistory;

  const HistoryPage(this.routeHistory, {Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  double _calculateDistance(List<LatLng> routeCoordinates) {
    double totalDistance = 0.0;
    for (int i = 0; i < routeCoordinates.length - 1; i++) {
      totalDistance += _getDistanceBetweenPoints(
        routeCoordinates[i],
        routeCoordinates[i + 1],
      );
    }
    return totalDistance;
  }

  double _getDistanceBetweenPoints(LatLng start, LatLng end) {
    const double earthRadiusKm = 6371.0;
    final double dLat = (end.latitude - start.latitude) * (pi / 180.0);
    final double dLon = (end.longitude - start.longitude) * (pi / 180.0);
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(start.latitude * (pi / 180.0)) *
            cos(end.latitude * (pi / 180.0)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _calculateTotalDistance() {
    double totalDistance = 0.0;
    for (var routeData in widget.routeHistory) {
      final routeCoordinates = routeData['coordinates'] as List<LatLng>;
      totalDistance += _calculateDistance(routeCoordinates);
    }
    return totalDistance;
  }

  Future<String> _getPlaceName(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return '${placemark.name}, ${placemark.locality}';
      }
    } catch (e) {
      print('Error fetching place name: $e');
    }
    return 'Unknown Location';
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
    final totalDistanceKm = _calculateTotalDistance();
    return Scaffold(
      appBar: AppBar(title: Text('Route History')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.routeHistory.length,
              itemBuilder: (context, index) {
                final routeData = widget.routeHistory[index];
                final routeCoordinates =
                routeData['coordinates'] as List<LatLng>;
                final distanceKm = _calculateDistance(routeCoordinates);

                return ListTile(
                  title: Text('Route ${index + 1}'),
                  subtitle: FutureBuilder(
                    future: Future.wait([
                      _getPlaceName(routeCoordinates.first),
                      _getPlaceName(routeCoordinates.last),
                    ]),
                    builder: (context, AsyncSnapshot<List<String>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Fetching locations...');
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return Text('Unable to fetch locations');
                      } else {
                        final startName = snapshot.data![0];
                        final endName = snapshot.data![1];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start Position: $startName'),
                            Text('End Position: $endName'),
                            Text(
                              'Distance: ${distanceKm.toStringAsFixed(2)} km',
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text('View Coordinates'),
                                items: [
                                  ...routeCoordinates.take(5).map(
                                        (coord) => DropdownMenuItem<String>(
                                      value:
                                      '(${coord.latitude.toStringAsFixed(5)}, ${coord.longitude.toStringAsFixed(5)})',
                                      child: Text(
                                        '(${coord.latitude.toStringAsFixed(5)}, ${coord.longitude.toStringAsFixed(5)})',
                                      ),
                                    ),
                                  ),
                                  if (routeCoordinates.length > 5)
                                    DropdownMenuItem<String>(
                                      value: '...',
                                      child: Text('...'),
                                    ),
                                  DropdownMenuItem<String>(
                                    value: 'copy',
                                    child: Text('Copy All Coordinates'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == 'copy') {
                                    // Copy all coordinates to clipboard
                                    String coordinatesString = routeCoordinates
                                        .map((e) =>
                                    '(${e.latitude.toStringAsFixed(5)}, ${e.longitude.toStringAsFixed(5)})')
                                        .join(', ');
                                    Clipboard.setData(
                                        ClipboardData(text: coordinatesString));
                                    showToast("All Co-ordinates are copied");
                                  } else {
                                    print('Selected: $value');
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ViewHistory(routeCoordinates: routeCoordinates),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: Colors.blueAccent,
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Distance Travelled: ${totalDistanceKm.toStringAsFixed(2)} kilometers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

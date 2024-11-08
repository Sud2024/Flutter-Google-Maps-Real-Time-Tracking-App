import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_tracker/pages/view_history.dart';

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> routeHistory;

  const HistoryPage(this.routeHistory, {Key? key}) : super(key: key);

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
    final double dLat =
        (end.latitude - start.latitude) * (3.141592653589793 / 180.0);
    final double dLon =
        (end.longitude - start.longitude) * (3.141592653589793 / 180.0);
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(start.latitude * (3.141592653589793 / 180.0)) *
            cos(end.latitude * (3.141592653589793 / 180.0)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Route History')),
      body: ListView.builder(
        itemCount: routeHistory.length,
        itemBuilder: (context, index) {
          final routeData = routeHistory[index];
          final routeCoordinates = routeData['coordinates'] as List<LatLng>;
          final distanceKm = _calculateDistance(routeCoordinates);
          return ListTile(
            title: Text('Route ${index + 1}'),
            subtitle: Text('Distance: ${distanceKm.toStringAsFixed(2)} km'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ViewHistory()));
            },
          );
        },
      ),
    );
  }
}

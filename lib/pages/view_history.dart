import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewHistory extends StatelessWidget {
  final List<LatLng> routeCoordinates;

  const ViewHistory({Key? key, required this.routeCoordinates}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Route')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: routeCoordinates.isNotEmpty ? routeCoordinates[0] : LatLng(0, 0),
          zoom: 14,
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId("route"),
            points: routeCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        },
        markers: {
          if (routeCoordinates.isNotEmpty)
            Marker(
              markerId: MarkerId("start"),
              position: routeCoordinates.first,
              infoWindow: InfoWindow(title: "Start"),
            ),
          if (routeCoordinates.length > 1)
            Marker(
              markerId: MarkerId("end"),
              position: routeCoordinates.last,
              infoWindow: InfoWindow(title: "End"),
            ),
        },
      ),
    );
  }
}

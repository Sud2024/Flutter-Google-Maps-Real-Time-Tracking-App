import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewHistory extends StatefulWidget {
  final List<LatLng> routeCoordinates;

  const ViewHistory({Key? key, required this.routeCoordinates})
      : super(key: key);

  @override
  State<ViewHistory> createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {

  MapType _currentMapType = MapType.normal;

  void _changeMapType(MapType mapType) {
    setState(() {
      _currentMapType = mapType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Route', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          PopupMenuButton<MapType>(
            icon: Icon(Icons.map, color: Colors.white),
            onSelected: (MapType mapType) {
              _changeMapType(mapType);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: MapType.normal,
                child: Text('Normal'),
              ),
              PopupMenuItem(
                value: MapType.satellite,
                child: Text('Satellite'),
              ),
              PopupMenuItem(
                value: MapType.terrain,
                child: Text('Terrain'),
              ),
              PopupMenuItem(
                value: MapType.hybrid,
                child: Text('Hybrid'),
              ),
            ],
          ),
        ],
      ),
      body: GoogleMap(
        mapType: _currentMapType,
        initialCameraPosition: CameraPosition(
          target: widget.routeCoordinates.isNotEmpty
              ? widget.routeCoordinates[0]
              : LatLng(0, 0),
          zoom: 14,
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId("route"),
            points: widget.routeCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        },
        markers: {
          if (widget.routeCoordinates.isNotEmpty)
            Marker(
              markerId: MarkerId("start"),
              position: widget.routeCoordinates.first,
              infoWindow: InfoWindow(title: "Start"),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          if (widget.routeCoordinates.length > 1)
            Marker(
              markerId: MarkerId("end"),
              position: widget.routeCoordinates.last,
              infoWindow: InfoWindow(title: "End"),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
        },
      ),
    );
  }
}

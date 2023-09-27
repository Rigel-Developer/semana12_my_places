import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<CameraPosition> getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition();
    return CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material App Bar'),
      ),
      body: FutureBuilder(
        future: getCurrentPosition(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            CameraPosition cameraPosition = snapshot.data as CameraPosition;
            return GoogleMap(
              initialCameraPosition: cameraPosition,
              myLocationEnabled: true,
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

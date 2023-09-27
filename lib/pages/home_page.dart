import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:semana12_my_places/utils/map_styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  Position? lastPosition;

  Future<CameraPosition> getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition();
    return CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 16,
    );
  }

  Future<void> moveCamara() async {
    Position position = await Geolocator.getCurrentPosition();
    CameraUpdate cameraUpdate = CameraUpdate.newLatLng(
      LatLng(position.latitude, position.longitude),
    );
    googleMapController.animateCamera(cameraUpdate);
  }

  Future<Uint8List> imageToBytes(
    String path, {
    bool fromNetwork = false,
    double width = 100,
  }) async {
    late Uint8List bytes;
    if (fromNetwork) {
      File file = await DefaultCacheManager().getSingleFile(path);
      bytes = await file.readAsBytes();
    } else {
      ByteData byteData = await rootBundle.load(path);
      bytes = byteData.buffer.asUint8List();
    }

    final codec =
        await ui.instantiateImageCodec(bytes, targetWidth: width.toInt());
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  currentPosition() async {
    BitmapDescriptor defaultMarker = BitmapDescriptor.fromBytes(
      await imageToBytes(
        "https://freesvg.org/img/car_topview.png",
        fromNetwork: true,
      ),
    );

    Polyline polyline = Polyline(
      polylineId: const PolylineId("1"),
      color: Colors.redAccent,
      width: 5,
      points: polylineCoordinates,
    );
    polylines.add(polyline);

    Geolocator.getPositionStream().listen((Position position) {
      LatLng lastPositionLatLng = LatLng(
        position.latitude,
        position.longitude,
      );
      polylineCoordinates.add(lastPositionLatLng);

      CameraUpdate cameraUpdate = CameraUpdate.newLatLng(
        lastPositionLatLng,
      );
      googleMapController.animateCamera(cameraUpdate);

      double rotation = 0;
      if (lastPosition != null) {
        rotation = Geolocator.bearingBetween(
          lastPosition!.latitude,
          lastPosition!.longitude,
          lastPositionLatLng.latitude,
          lastPositionLatLng.longitude,
        );
      }

      Marker positionMarker = Marker(
        markerId: const MarkerId("position"),
        position: lastPositionLatLng,
        icon: defaultMarker,
        rotation: rotation,
      );
      markers.add(positionMarker);
      lastPosition = position;

      setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getCurrentPosition(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            CameraPosition cameraPosition = snapshot.data as CameraPosition;
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: cameraPosition,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController = controller;
                    googleMapController.setMapStyle(jsonEncode(mapStyle));
                  },
                  markers: markers,
                  polylines: polylines,
                  onTap: (LatLng position) async {
                    markers.add(
                      Marker(
                        markerId: MarkerId(position.toString()),
                        position: position,
                        draggable: true,
                        onDrag: (LatLng position) {
                          print(position);
                        },
                        onTap: () {
                          print("Tap");
                        },
                        // icon: await BitmapDescriptor.fromAssetImage(
                        //     ImageConfiguration.empty,
                        //     "assets/images/marker.png"),
                        icon: BitmapDescriptor.fromBytes(
                          await imageToBytes(
                            "assets/images/marker2.png",
                            width: 50,
                            fromNetwork: false,
                          ),
                        ),
                      ),
                    );
                    setState(() {});
                  },
                  // TODO : RETO POLYGON
                  // polygons:
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 20.0,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        moveCamara();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        "Mi ubicación",
                      ),
                    ),
                  ),
                ),
              ],
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

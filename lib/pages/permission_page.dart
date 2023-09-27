import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:semana12_my_places/pages/home_page.dart';

class PermissionPage extends StatelessWidget {
  const PermissionPage({super.key});

  checkPermission(PermissionStatus status, BuildContext context) async {
    switch (status) {
      case PermissionStatus.granted:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
        break;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        openAppSettings();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/images/location.svg",
                height: 140,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Permitir ubicación",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Necesitamos tu ubicación para continuar",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  // Navigator.pushNamed(context, "home");
                  PermissionStatus status = await Permission.location.request();
                  checkPermission(status, context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[500],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Permitir ubicación"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

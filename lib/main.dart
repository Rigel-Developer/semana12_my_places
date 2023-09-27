import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:semana12_my_places/pages/home_page.dart';
import 'package:semana12_my_places/pages/permission_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

//AIzaSyDz1FCcdy_De0G8IhTcr2EOrv_8J6kQ4pM
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: const PermissionPage(),
      theme: ThemeData(textTheme: GoogleFonts.manropeTextTheme()),
    );
  }
}

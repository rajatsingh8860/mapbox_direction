
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:track/constants/restaurants.dart';
import 'package:track/helpers/directions_handler.dart';
import 'package:track/main.dart';
import '../screens/home_management.dart';
import 'dart:convert';
import 'package:location/location.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    initializeLocationAndSave();
  }

  void initializeLocationAndSave() async {
    Location location = Location();
    bool? serviceEnabled;
    PermissionStatus? permissionStatus;

    serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    permissionStatus = await location.hasPermission();
    if (permissionStatus != PermissionStatus.granted) {
      permissionStatus = await location.requestPermission();
    }

    LocationData locationData = await location.getLocation();
    // LatLng currentLatLng =
    //     LatLng(locationData.latitude!, locationData.longitude!);

    LatLng currentLatLng =
        LatLng(37.33233141, -122.0312186);

    sharedPreferences.setDouble("latitude", 37.33233141);
    sharedPreferences.setDouble("longitude",-122.0312186);

    for(int i =0 ; i < restaurants.length ; i++){
      Map modifiedResponse = await getDirectionsAPIResponse(currentLatLng, i);
      saveDirectionsAPIResponse(i, json.encode(modifiedResponse));
    }

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeManagement()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Center(child: Image.asset('assets/image/splash.png')),
    );
  }
}

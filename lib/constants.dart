import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
const String google_api_key= "AIzaSyA-6Jgvw80gg2s21UR67f8T45MqbLy3OWE";
const Color primaryColor= Color(0xFF7B61ff);
const double defaultPadding= 16.0;
final LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100,
);
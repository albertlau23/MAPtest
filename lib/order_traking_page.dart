import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:untitled1/constants.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(-6.1915613, 106.8195175);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);
  Position? currLoc;
  Position? liveLoc;
  String titletext = "";
  List<LatLng> polylinesCoordinates = [];

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print("denied");
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    print("pass");
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void getCurrentLocation() async {
    _determinePosition().then((value) {
      setState(() {
        currLoc = value;
        print(value);
      });
    });
  }

  _latlngConverter(Position p) {
    return LatLng(p!.latitude!, p!.longitude!);
  }

  void getPolyPoints(p) async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(p.latitude, p.longitude));
    if (result.points.isNotEmpty) {
      result.points.forEach(
          (p) => polylinesCoordinates.add(LatLng(p.latitude, p.longitude)));
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    getCurrentLocation();
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      setState(() {
        liveLoc = position;

        LatLng p = _latlngConverter(position!);
        getPolyPoints(p);
        titletext = "langitude : " +
            p.latitude.toString() +
            "longitude: " +
            p.longitude.toString();
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text("Latitude: $titletext"),
        ),
        body: currLoc == null
            ? const Center(
                child: Text("Loading"),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Text(titletext),
                    Container(
                      height: size.height * 0.8,
                      width: size.width,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                            target: sourceLocation, zoom: 13.5),
                        polylines: {
                          Polyline(
                              polylineId: PolylineId("route"),
                              points: polylinesCoordinates,
                              color: primaryColor,
                              width: 6)
                        },
                        markers: {
                          // Marker(
                          //     markerId: MarkerId("curr"),
                          //     position: _latlngConverter(currLoc!)),
                          Marker(
                              markerId: MarkerId("source"),
                              position: sourceLocation),
                          Marker(
                              markerId: MarkerId("Live"),
                              position: _latlngConverter(liveLoc!)),
                          // Marker(markerId: MarkerId("Destination"), position: destination)
                        },
                      ),
                    )
                  ],
                ),
              ));
  }
}

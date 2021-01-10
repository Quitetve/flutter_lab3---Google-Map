import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _GoogleMapState createState() => _GoogleMapState();
}

class _GoogleMapState extends State<MyApp> {
  List cartList;
  double screenHeight, screenWidth;
  String _homeloc = "Get the address...";
  Position _currentPosition;
  double sizing = 11.5;
  String gmaploc = "";
  double latitude = 6.4676929;
  double longitude = 100.5067673;

  GoogleMapController gmcontroller;
  CameraPosition _home;
  MarkerId markerId1 = MarkerId("12");

  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(6.4676929, 100.5067673);

  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  Set<Marker> markers = Set();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          appBarTheme: AppBarTheme(
        color: Colors.blue,
        brightness: Brightness.light,
        textTheme: TextTheme(
          headline6: TextStyle(color: Colors.black, fontSize: 18),
        ),
      )),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Google Maps Location'),
          centerTitle: true,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 110, 0),
            ),
          ],
        ),
        body: Stack(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 160),
            child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 17,
                ),
                mapType: _currentMapType,
                markers: markers.toSet(),
                onCameraMove: _onCameraMove,
                onTap: (newLatLng) {
                  _loadLoc(newLatLng, setState);
                }),
          ),
          Positioned(
            top: 490,
            left: 50,
            width: 300,
            child: Text(
              _homeloc,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ),
          Positioned(
            top: 520,
            left: 50,
            width: 300,
            child: Text(
              ("Current Latitude      :  ") + (latitude).toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.green, fontSize: 13),
            ),
          ),
          Positioned(
            top: 540,
            left: 50,
            width: 300,
            child: Text(
              ("Current Longitude   :  ") + (longitude).toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
          Positioned(
            top: 460,
            left: 50,
            width: 300,
            child: Text(
              ("Updated Tap Address :"),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ]),
      ),
    );
  }

  void _loadLoc(LatLng loc, setState) async {
    setState(() {
      print("insetstate");
      markers.clear();
      latitude = loc.latitude;
      longitude = loc.longitude;
      _getLocationfromlatlng(latitude, longitude, setState);
      _home = CameraPosition(
        target: loc,
        zoom: 17,
      );
      markers.add(Marker(
        markerId: markerId1,
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: 'New Location',
          snippet: 'New Pinned Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    });
    CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 17,
    );
    _newhomeLocation();
  }

  _getLocationfromlatlng(double lat, double lng, setState) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final coordinates = new Coordinates(lat, lng);

    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    setState(() {
      _homeloc = first.addressLine;
      if (_homeloc != null) {
        latitude = lat;
        longitude = lng;
        return;
      }
    });
  }

  Future<void> _newhomeLocation() async {
    gmcontroller = await _controller.future;
    gmcontroller.animateCamera(CameraUpdate.newCameraPosition(_home));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  Future<void> _getLocation() async {
    try {
      setState(() {
        markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'New Location',
            snippet: 'New Pinned Location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
      });

      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) async {
        _currentPosition = position;
        if (_currentPosition != null) {
          final coordinates = new Coordinates(latitude, longitude);
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          setState(() {
            var first = addresses.first;
            _homeloc = first.addressLine;
            if (_homeloc != null) {
              latitude = latitude;
              longitude = longitude;

              return;
            }
          });
        }
      }).catchError((e) {
        print(e);
      });
    } catch (exception) {
      print(exception.toString());
    }
  }
}

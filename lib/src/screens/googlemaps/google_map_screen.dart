// ignore_for_file: no_logic_in_create_state, prefer_const_constructors, unnecessary_new
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:squirrel_main/models/cull_model.dart';
import 'package:squirrel_main/models/sighting_model.dart';
import 'package:squirrel_main/services/database.dart';
import 'package:squirrel_main/src/screens/googlemaps/position_services.dart';
import 'package:squirrel_main/utils/utils.dart';

class GoogleMapScreen extends StatefulWidget {
  final String uid;
  const GoogleMapScreen({required Key key, required this.uid})
      : super(key: key);

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  List<Marker> markers = [];
  Completer<GoogleMapController> _controller = Completer();
  Set<Polyline> _polylines = Set<Polyline>();

  late GoogleMapController newGoogleMapController;

  Future<void> _goCurrentPosition(double startLat, double startLng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(startLat, startLng), zoom: 17),
      ),
    );
  }

  Future<String> promptForGender(context) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Gender'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('male'),
                child: Text('Male'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('female'),
                child: Text('Female'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('unknown'),
                child: Text('Unknown'),
              ),
            ],
          );
        });
  }

  Future<String> promptForColour(context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Which species',
            ),
          ),
          actions: [
            Center(
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop('Ring Necked Parakeet'),
                    child: Text('Ring Necked Parakeet'),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop('grey'),
                      child: Text('Grey'),
                    ),
                  ),
                ),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop('red'),
                      child: Text('Red'),
                    ),
                  ),
                ),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop('pine marten'),
                      child: Text('pine marten'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static final CameraPosition england =
      CameraPosition(target: LatLng(54.3091267, -5.1172292), zoom: 6);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Google maps'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.75,
            child: GoogleMap(
              onTap: (tapped) {
                print('$tapped');
                Marker _newMarker = Marker(
                  markerId: MarkerId('markerId'),
                  position: LatLng(
                    tapped.latitude,
                    tapped.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: 'mark cull',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                );
                markers.add(_newMarker);

                setState(() {});
              },
              mapType: MapType.normal,
              initialCameraPosition: england,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: markers.map((e) => e).toSet(),
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: TextButton.icon(
                  onPressed: () async {
                    final _gender = await promptForGender(context);
                    Cull cull = Cull(
                        gender: _gender,
                        location: markers.last.position.toString(),
                        timestamp: Timestamp.fromDate(DateTime.now()),
                        uid: widget.uid);
                    DatabaseMethods.addCull(cull);
                    showSnackBar(
                      context,
                      'cull successfully added!',
                    );
                  },
                  icon: Icon(Icons.gps_fixed),
                  label: Text('Add cull record'),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: TextButton.icon(
                  onPressed: () async {
                    final colour = await promptForColour(context);
                    Sighting sighting = Sighting(
                        colour: colour,
                        uid: widget.uid,
                        timestamp: Timestamp.fromDate(
                          DateTime.now(),
                        ),
                        location: markers.last.position.toString());
                    DatabaseMethods.addSighting(sighting);
                    showSnackBar(
                      context,
                      'Sighting successfully added',
                    );
                  },
                  icon: Icon(Icons.remove_red_eye_sharp),
                  label: Text('Mark sighting'),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Position currentPosition =
              await PositionServices().getCurrentPosition();
          _goCurrentPosition(
              currentPosition.latitude, currentPosition.longitude);
        },
        label: Text('Get current location'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

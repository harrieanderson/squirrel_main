// ignore_for_file: no_logic_in_create_state, prefer_const_constructors, unnecessary_new, use_build_context_synchronously, unnecessary_null_comparison
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:squirrel_main/models/cull_model.dart';
import 'package:squirrel_main/models/sighting_model.dart';
import 'package:squirrel_main/services/database.dart';
import 'package:squirrel_main/src/screens/googlemaps/position_services.dart';
import 'package:squirrel_main/utils/constant.dart';
import 'package:squirrel_main/utils/utils.dart';

class GoogleMapScreen extends StatefulWidget {
  final String uid;
  const GoogleMapScreen({required Key key, required this.uid})
      : super(key: key);

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Location location = new Location();
  Geoflutterfire geo = Geoflutterfire();
  final Set<Marker> _markers = <Marker>{};
  late LatLng _tappedLocation;

  var isLoading = true;

  late GoogleMapController newGoogleMapController;

  Future<void> goToCurrentPosition(double startLat, double startLng,
      {double zoom = 17}) async {
    try {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(startLat, startLng), zoom: zoom),
        ),
      );
    } catch (error) {
      print('Error moving to current position: $error');
    }
  }

  Future<String> promptForCull(context) async {
    return await showDialog(
      context: context,
      barrierDismissible: true,
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
      },
    );
  }

  Future<String> promptForSighting(context) async {
    return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Which species',
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).pop('Ring Necked Parakeet'),
                child: Text('Ring Necked Parakeet'),
              ),
            ),
            ButtonBar(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop('grey'),
                  child: Text('Grey'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop('red'),
                  child: Text('Red'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop('pine marten'),
                  child: Text('pine marten'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void addMarkersToMap(List<DocumentSnapshot> documents, String recordType) {
    for (var document in documents) {
      if (recordType == 'cull') {
        // Create a new Cull object from the snapshot
        Cull cull = Cull.fromDoc(document);
        GeoPoint location = cull.location;
        Marker marker = Marker(
          markerId: MarkerId(document.id),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: 'Cull',
            snippet:
                'Cull: ${cull.gender}\nTimestamp: ${cull.timestamp.toDate()}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        );
        _markers.add(marker);
      } else if (recordType == 'sighting') {
        // Create a new Sighting object from the snapshot
        Sighting sighting = Sighting.fromDoc(document);
        GeoPoint location = sighting.location;
        Marker marker = Marker(
          markerId: MarkerId(document.id),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: 'Sighting',
            snippet:
                'Sighting: ${sighting.species}\nTimestamp: ${sighting.timestamp.toDate()}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        _markers.add(marker);
      }
    }
  }

  Future<void> addCullRecord() async {
    final gender = await promptForCull(context);
    if (gender == null) {
      // Display an error message if no gender is selected
      showSnackBar(context, 'Please select a gender');
      return;
    }
    if (_tappedLocation == null) {
      // Display an error message if no location is selected
      showSnackBar(context, 'Please tap on the map to select a location');
      return;
    }
    Cull cullObject = Cull(
        gender: gender,
        location: GeoPoint(_tappedLocation.latitude, _tappedLocation.longitude),
        timestamp: Timestamp.fromDate(DateTime.now()),
        uid: widget.uid);
    DatabaseMethods.addCull(cullObject);
    showSnackBar(
      context,
      'cull successfully added!',
    );
  }

  Future<void> addSightingRecord() async {
    final species = await promptForSighting(context);
    if (species == null) {
      // Display an error message if no gender is selected
      showSnackBar(context, 'Please select a gender');
      return;
    }
    if (_tappedLocation == null) {
      // Display an error message if no location is selected
      showSnackBar(context, 'Please tap on the map to select a location');
      return;
    }
    Sighting sightingObject = Sighting(
        species: species,
        location: GeoPoint(_tappedLocation.latitude, _tappedLocation.longitude),
        timestamp: Timestamp.fromDate(DateTime.now()),
        uid: widget.uid);
    DatabaseMethods.addSighting(sightingObject);
    showSnackBar(
      context,
      'sighting successfully added!',
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
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: england,
              myLocationEnabled: true,
              mapType: MapType.normal,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (LatLng location) {
                setState(() {
                  _tappedLocation = location;
                  _markers.add(
                    Marker(
                      markerId: MarkerId('tappedLocation'),
                      position: location,
                    ),
                  );
                });
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                cullsRef.doc(widget.uid).collection('userCulls').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Add the culls to the map
                addMarkersToMap(snapshot.data!.docs, 'cull');
              }
              return Container();
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: sightingsRef
                .doc(widget.uid)
                .collection('userSightings')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Add the sightings to the map
                addMarkersToMap(snapshot.data!.docs, 'sighting');
              }
              return Container();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 70),
                child: TextButton(
                  onPressed: () {
                    // Add a cull record to the database
                    addCullRecord();
                  },
                  child: Text('Add Cull'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 70),
                child: TextButton(
                  onPressed: () {
                    // Add a sighting record to the database
                    addSightingRecord();
                  },
                  child: Text('Add Sighting'),
                ),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Position currentPosition =
              await PositionServices().getCurrentPosition();
          goToCurrentPosition(
              currentPosition.latitude, currentPosition.longitude);
        },
        label: Text('Get current location'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:prjectcm/data/HospitalRepository.dart';
import 'package:provider/provider.dart';
import '../connectivity_module.dart';
import '../data/http_sns_datasource.dart';
import '../data/sqflite_sns_datasource.dart';
import '../models/hospital.dart';
import 'hospital_detail_page.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  final locationController = Location();
  GoogleMapController? _mapController;

  static const googlePlex = LatLng(38.7071, -9.13549);

  LatLng currentPosition = googlePlex;
  Future<List<Hospital>>? _futureHospitais;
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _loadHospitais();
  }
  Future<void> _loadHospitais() async {
    final local = context.read<SqfliteSnsDataSource>();
    final remote = context.read<HttpSnsDataSource>();
    final connectivity = context.read<ConnectivityModule>();

    final hospitalRepository = HospitalRepository(
      local: local,
      remote: remote,
      connectivityModule: connectivity,
    );

    setState(() {
      _futureHospitais = hospitalRepository.getAllHospitals();
    });
  }

  @override
  void dispose() {
    // Cancel the location subscription when the widget is disposed
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Hospital>>(
      future: _futureHospitais,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
              centerTitle: true,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              centerTitle: true,
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          List<Hospital> hospitals = snapshot.data!;
          Set<Marker> markers = {};

          // Add a marker for each Hospital
          for (Hospital hospital in hospitals) {
            double latitude =  hospital.latitude;
            double longitude =  hospital.longitude;
            markers.add(
              Marker(
                markerId: MarkerId( hospital.name),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                position: LatLng(latitude, longitude),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HospitalDetailPage(hospitalid:  hospital.id,),
                    ),
                  );
                },
              ),
            );
          }

          return Scaffold(
            body: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentPosition,
                zoom: 13,
              ),
              markers: markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
            floatingActionButton: Stack(
              children: [
                Positioned(
                  // Ensures FAB stays within screen bounds, even on wide screens
                  left: 20.0, // Adjust left margin as needed
                  bottom: 20.0, // Adjust bottom margin as needed
                  child: FloatingActionButton(
                    onPressed: () async {
                      final currentLocation = await locationController.getLocation();
                      if (currentLocation.latitude != null && currentLocation.longitude != null) {
                        final userLocation = LatLng(
                          currentLocation.latitude!,
                          currentLocation.longitude!,
                        );
                        if (mounted) {
                          setState(() {
                            currentPosition = userLocation;
                          });
                        }
                        _mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: userLocation,
                              zoom: 15,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription = locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        if (mounted) {
          setState(() {
            currentPosition = LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            );
          });
        }
        print(currentPosition);
      }
    });
  }
}
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart'; 


class RideState extends ChangeNotifier {


  String driverName = '';
  String cost = '0';
  String driverPhone = '';
  DateTime rideTime = DateTime.now();
  RideStatus status = RideStatus.initial;

  void updateDriverDetails(Map<String, dynamic> driverData) {


    driverName = driverData['name'] ?? '';
    driverPhone = driverData['phone'] ?? '';
    cost = driverData['cost']?.toString() ?? '0';
    notifyListeners();
  }
}

enum RideStatus { initial, finding, connecting, driverDetails }

class RideRequestScreen extends StatefulWidget {
  final String userId;
  final String token;
  final String email;

  const RideRequestScreen({
    required this.userId,
    required this.token,
    required this.email,
    super.key,
  });

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  late final Dio _dio;
  MapboxMap? mapboxMap;
  geoLocation.Position? currentLocation;  List<Map<String, dynamic>> nearbyDrivers = [];
  final Set<String> _driverSourceIds = {};
  Timer? _driverUpdateTimer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
      MapboxOptions.setAccessToken('pk.eyJ1IjoibnR3YXJpZmlhY3JlIiwiYSI6ImNtN2UzZjBpbDA1NWMybXM3NDc3bGJlOGYifQ.AXM-Vk9Vq7mzYyoQH5AnMw');
    _initializeDio();
    _startLocationAndDriverUpdates();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://easy-ride-backend-xl8m.onrender.com/api',
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    ));
  }

  void _startLocationAndDriverUpdates() {
    _getCurrentLocation();
    _driverUpdateTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadNearbyDrivers(),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      setState(() {
        currentLocation = position;
        isLoading = false;
      });
      _loadNearbyDrivers();
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Failed to get location');
    }
  }

  Future<void> _loadNearbyDrivers() async {
    if (currentLocation == null) return;

    try {
      final response = await _dio.get(
        '/rides/nearby',
        queryParameters: {
          'lat': currentLocation!.latitude,
          'lon': currentLocation!.longitude,
          'radius': 5.0
        },
      );
      
      if (response.statusCode == 200) {
        setState(() {
          nearbyDrivers = List<Map<String, dynamic>>.from(response.data['drivers']);
        });
        _updateDriverMarkers();
      }
    } catch (e) {
      _showError('Failed to fetch nearby drivers');
    }
  }

  void _onMapCreated(MapboxMap controller) {
    mapboxMap = controller;
    _updateDriverMarkers();
  }

  Future<void> _updateDriverMarkers() async {
    if (mapboxMap == null) return;

    // Clear existing markers
    for (String sourceId in _driverSourceIds) {
      await mapboxMap!.style.removeLayer("layer-$sourceId");
      await mapboxMap!.style.removeSource(sourceId);
    }
    _driverSourceIds.clear();

   
    for (var driver in nearbyDrivers) {
      final sourceId = "driver-${driver['id']}";
      _driverSourceIds.add(sourceId);

      final point = {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [driver['longitude'], driver['latitude']],
        },
        "properties": {
          "name": driver['name'],
          "rating": driver['rating']
        }
      };

      await mapboxMap!.style.addSource(
        GeoJsonSource(id: sourceId, data: jsonEncode(point)),
      );

      await mapboxMap!.style.addLayer(
        CircleLayer(
          id: "layer-$sourceId",
          sourceId: sourceId,
          circleColor: Colors.green.value,
          circleRadius: 8.0,
        ),
      );
    }
  }

  Future<void> _callDriver(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showError('Could not make phone call');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: 8,
        intensity: 0.65,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(driver['profileImage'] ?? ''),
                  radius: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${driver['vehicleModel']} - ${driver['licensePlate']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            ' ${driver['rating']} • ${driver['totalRides']} rides',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                NeumorphicButton(
                  onPressed: () => _callDriver(driver['phone']),
                  style: NeumorphicStyle(
                    color: Colors.amber,
                    boxShape: NeumorphicBoxShape.circle(),
                  ),
                  child: const Icon(Icons.phone, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            mapOptions: MapOptions(
              
              pixelRatio: MediaQuery.of(context).devicePixelRatio,
              //style: "mapbox://styles/mapbox/streets-v11",
            ),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(
                  currentLocation?.longitude ?? 30.0619,
                  currentLocation?.latitude ?? -1.9403,
                ),
              ),
              zoom: 15.0,
            ),
            onMapCreated: _onMapCreated,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: nearbyDrivers.length,
                        itemBuilder: (context, index) => _buildDriverCard(nearbyDrivers[index]),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _driverUpdateTimer?.cancel();
    mapboxMap?.dispose();
    super.dispose();
  }
}

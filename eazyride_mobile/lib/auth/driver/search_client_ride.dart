import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:async';

class PassengerRequestScreen extends StatefulWidget {
  final String driverId;
  final String token;

  const PassengerRequestScreen({
    required this.driverId,
    required this.token,
    super.key,
  });

  @override
  State<PassengerRequestScreen> createState() => _PassengerRequestScreenState();
}

class _PassengerRequestScreenState extends State<PassengerRequestScreen> {
  late final Dio _dio;
  MapboxMap? mapboxMap;
  List<Map<String, dynamic>> nearbyRides = [];
  Timer? _rideUpdateTimer;
  final Set<String> _rideSourceIds = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDio();
    MapboxOptions.setAccessToken('pk.eyJ1IjoibnR3YXJpZmlhY3JlIiwiYSI6ImNtN2UzZjBpbDA1NWMybXM3NDc3bGJlOGYifQ.AXM-Vk9Vq7mzYyoQH5AnMw');
    _startRideUpdates();
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

  void _startRideUpdates() {
    _fetchNearbyRides();
    _rideUpdateTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchNearbyRides(),
    );
  }

  Future<void> _fetchNearbyRides() async {
    try {
      final response = await _dio.get('/rides/nearby', 
        queryParameters: {'lat': -1.9403, 'lon': 30.0619, 'radius': 40}
      );
      
      if (response.statusCode == 200) {
        setState(() {
          nearbyRides = List<Map<String, dynamic>>.from(response.data['rides']);
          isLoading = false;
        });
        _updateRideMarkers();
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Failed to fetch nearby rides');
    }
  }

  void _onMapCreated(MapboxMap controller) {
    mapboxMap = controller;
    _updateRideMarkers();
  }

  Future<void> _updateRideMarkers() async {
    if (mapboxMap == null) return;

    // Clear existing markers
    for (String sourceId in _rideSourceIds) {
      await mapboxMap!.style.removeLayer("layer-$sourceId");
      await mapboxMap!.style.removeSource(sourceId);
    }
    _rideSourceIds.clear();

    // Add new markers
    for (var ride in nearbyRides) {
      final sourceId = "ride-${ride['id']}";
      _rideSourceIds.add(sourceId);

      final point = {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [ride['pickupLocation']['lon'], ride['pickupLocation']['lat']],
        },
        "properties": {"id": ride['id'], "price": ride['price']}
      };

      await mapboxMap!.style.addSource(
        GeoJsonSource(id: sourceId, data: jsonEncode(point)),
      );

      await mapboxMap!.style.addLayer(
        CircleLayer(
          id: "layer-$sourceId",
          sourceId: sourceId,
          circleColor: Colors.amber.value,
          circleRadius: 8.0,
        ),
      );
    }
  }

  Future<void> _acceptRide(String rideId) async {
    try {
      final response = await _dio.put(
        '/rides/accept',
        data: {
          'rideId': rideId,
          'driverId': widget.driverId,
        },
      );

      if (response.statusCode == 200) {
        _showSuccess('Ride accepted successfully');
        // Handle navigation after acceptance
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Failed to accept ride');
    }
  }

  Future<void> _callCustomer(String phone) async {
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Widget _buildRideRequestCard(Map<String, dynamic> ride) {
    return Neumorphic(
      margin: const EdgeInsets.all(8),
      style: NeumorphicStyle(
        depth: 8,
        intensity: 0.65,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup: ${ride['pickupAddress']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Dropoff: ${ride['dropoffAddress']}'),
                    const SizedBox(height: 4),
                    Text(
                      'Price: ${ride['price']} RWF',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                Column(
                  children: [
                    NeumorphicButton(
                      onPressed: () => _callCustomer(ride['customerPhone']),
                      style: NeumorphicStyle(
                        color: Colors.blue,
                        boxShape: NeumorphicBoxShape.circle(),
                      ),
                      child: const Icon(Icons.phone, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    NeumorphicButton(
                      onPressed: () => _acceptRide(ride['id']),
                      style: NeumorphicStyle(
                        color: Colors.green,
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
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
            resourceOptions: ResourceOptions(
              accessToken: 'pk.eyJ1IjoibnR3YXJpZmlhY3JlIiwiYSI6ImNtN2UzZjBpbDA1NWMybXM3NDc3bGJlOGYifQ.AXM-Vk9Vq7mzYyoQH5AnMw'
            ),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(30.0619, -1.9403)),
              zoom: 14.0,
            ),
            onMapCreated: _onMapCreated,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) => Container(
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
                      itemCount: nearbyRides.length,
                      itemBuilder: (context, index) => _buildRideRequestCard(nearbyRides[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rideUpdateTimer?.cancel();
    mapboxMap?.dispose();
    super.dispose();
  }
}

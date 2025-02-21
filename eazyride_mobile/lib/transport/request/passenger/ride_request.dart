import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class RideState extends ChangeNotifier {
  String driverName = 'David Jones';
  String cost = '2100';
  DateTime rideTime = DateTime.now();
  LatLng pickupLocation = const LatLng(37.7749, -122.4194);
  LatLng dropoffLocation = const LatLng(37.7849, -122.4294);
  RideStatus status = RideStatus.initial;

  void updateStatus(RideStatus newStatus) {
    status = newStatus;
    notifyListeners();
  }
}

enum RideStatus { initial, finding, connecting, driverDetails }

class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({super.key});

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  
  @override
  Widget build(BuildContext context) {
    final rideState = context.watch<RideState>();
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: rideState.pickupLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              mapController = controller;
              _updateMarkers(rideState);
            },
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          _buildBottomSheet(rideState),
        ],
      ),
    );
  }

  void _updateMarkers(RideState rideState) {
    setState(() {
      markers = {
        Marker(
          markerId: const MarkerId('pickup'),
          position: rideState.pickupLocation,
          infoWindow: const InfoWindow(title: 'Pickup Location'),
        ),
        Marker(
          markerId: const MarkerId('dropoff'),
          position: rideState.dropoffLocation,
          infoWindow: const InfoWindow(title: 'Dropoff Location'),
        ),
      };
    });
  }

  Widget _buildBottomSheet(RideState rideState) {
    switch (rideState.status) {
      case RideStatus.initial:
        return _buildFindingDriver(rideState);
      case RideStatus.finding:
        return _buildFindingRideWay(rideState);
      case RideStatus.connecting:
        return _buildConnectingToCustomer(rideState);
      case RideStatus.driverDetails:
        return _buildDriverDetails(rideState);
    }
  }

  Widget _buildFindingDriver(RideState rideState) {
    return _rideStatusCard(
      title: 'Finding the nearest RideWay...',
      showProgressBar: true,
      rideState: rideState,
    );
  }

  Widget _buildFindingRideWay(RideState rideState) {
    return _rideStatusCard(
      title: 'Connecting to the Customer...',
      showProgressBar: true,
      rideState: rideState,
    );
  }

  Widget _buildConnectingToCustomer(RideState rideState) {
    return _rideStatusCard(
      title: 'Connecting to the Customer...',
      showProgressBar: true,
      rideState: rideState,
    );
  }

  Widget _buildDriverDetails(RideState rideState) {
    return _driverInfoCard(rideState);
  }

  Widget _rideStatusCard({required String title, required bool showProgressBar, required RideState rideState}) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (showProgressBar)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
            ElevatedButton(
              onPressed: () => rideState.updateStatus(RideStatus.initial),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Cancel Ride'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _driverInfoCard(RideState rideState) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person),
              ),
              title: Text(rideState.driverName),
              subtitle: const Text('Toyota Avanza - 6MBV006'),
              trailing: IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {},
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Trip Security'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payment Details'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

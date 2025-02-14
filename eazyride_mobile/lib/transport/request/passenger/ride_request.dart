import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


class RideState extends ChangeNotifier {
  String driverName = 'John Smith';
  String cost = '\$2';
  DateTime rideTime = DateTime(2020, 12, 11, 9, 30);
  LatLng pickupLocation = const LatLng(37.7749, -122.4194);
  LatLng dropoffLocation = const LatLng(37.7849, -122.4294);
  RideStatus status = RideStatus.initial;

  void updateStatus(RideStatus newStatus) {
    status = newStatus;
    notifyListeners();
  }
}

enum RideStatus { initial, confirming, finding, connected }

 

class RideRequestP extends StatefulWidget {
  const RideRequestP({Key? key}) : super(key: key);

  @override
  State<RideRequestP> createState() => _RideRequestPState();
}

class _RideRequestPState extends State<RideRequestP> {
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
            onMapCreated: (GoogleMapController controller) {
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
        return _buildInitialBottomSheet(rideState);
      case RideStatus.confirming:
        return _buildConfirmingBottomSheet(rideState);
      case RideStatus.finding:
        return _buildFindingBottomSheet(rideState);
      case RideStatus.connected:
        return _buildConnectedBottomSheet(rideState);
    }
  }

  Widget _buildInitialBottomSheet(RideState rideState) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage('https://lh3.googleusercontent.com/a/ACg8ocKqZ19JHiBHYcQkmnwf3TK49KS6mmsZArQFFF3DNC59GNGyVwWo=s288-c-no'),
                ),
                title: Text(rideState.driverName),
                subtitle: const Text('5.0 ★'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  rideState.updateStatus(RideStatus.confirming);
                },
                child: const Text('Request Ride'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfirmingBottomSheet(RideState rideState) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              const Center(
                child: Text(
                  'Confirming your ride...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage('https://lh3.googleusercontent.com/a/ACg8ocKqZ19JHiBHYcQkmnwf3TK49KS6mmsZArQFFF3DNC59GNGyVwWo=s288-c-no'),
                ),
                title: Text(rideState.driverName),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => _showCancelDialog(rideState),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Cancel ride'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFindingBottomSheet(RideState rideState) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              const Center(
                child: Text(
                  'Finding the nearest driver...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => _showCancelDialog(rideState),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Cancel ride'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConnectedBottomSheet(RideState rideState) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              const Center(
                child: Text(
                  'Connecting to the Customer...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage('https://lh3.googleusercontent.com/a/ACg8ocKqZ19JHiBHYcQkmnwf3TK49KS6mmsZArQFFF3DNC59GNGyVwWo=s288-c-no'),
                ),
                title: Text(rideState.driverName),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cost: ${rideState.cost}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      ),
                      const SizedBox(height: 8),
                      Text('Date and Time: ${rideState.rideTime.toString()}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => _showCancelDialog(rideState),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Cancel ride'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelDialog(RideState rideState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text('Are you sure you want to cancel this ride?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              rideState.updateStatus(RideStatus.initial);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
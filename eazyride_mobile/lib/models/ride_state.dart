import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideState extends ChangeNotifier {
  String driverName = 'John Smith';
  String cost = '\$20';
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

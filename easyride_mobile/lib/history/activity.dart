import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String serverUrl = "https://server.com/activity";

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> activeRides = [];
  List<Map<String, dynamic>> completedRides = [];
  List<Map<String, dynamic>> canceledRides = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchRides();
  }

  Future<void> fetchRides() async {
    final response = await http.get(Uri.parse(serverUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        activeRides = List<Map<String, dynamic>>.from(data['active']);
        completedRides = List<Map<String, dynamic>>.from(data['completed']);
        canceledRides = List<Map<String, dynamic>>.from(data['canceled']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Activity"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Active"),
            Tab(text: "Completed"),
            Tab(text: "Canceled"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RideList(rides: activeRides, showMap: true),
          RideList(rides: completedRides, showMap: false),
          RideList(rides: canceledRides, showMap: false),
        ],
      ),
    );
  }
}

class RideList extends StatelessWidget {
  final List<Map<String, dynamic>> rides;
  final bool showMap;

  RideList({required this.rides, required this.showMap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rides.length,
      itemBuilder: (context, index) {
        final ride = rides[index];
        return ListTile(
          leading: Image.network(ride['carImage']),
          title: Text(ride['driverName']),
          subtitle: Text("Cost: ${ride['cost']} Rwf\nDate: ${ride['date']}"),
          trailing: showMap ? MapSnapshot(location: ride['location']) : null,
        );
      },
    );
  }
}

class MapSnapshot extends StatelessWidget {
  final Map<String, dynamic> location;

  MapSnapshot({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(location['lat'], location['lng']),
          zoom: 12,
        ),
        markers: {Marker(markerId: MarkerId("ride"), position: LatLng(location['lat'], location['lng']))},
      ),
    );
  }
}

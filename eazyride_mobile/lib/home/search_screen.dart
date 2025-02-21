import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;


const String serverUrl = "https://your-server.com/save-location";

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  FloatingSearchBarController searchBarController = FloatingSearchBarController();
  GoogleMapController? mapController;
  List<Map<String, dynamic>> searchResults = [];
  LatLng initialPosition = LatLng(1.9441, 30.0619);  

  Future<void> searchLocations(String query) async {
    if (query.isEmpty) return;
    
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=${dotenv.env['GOOGLE_API_KEY']}',
    );
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        searchResults = List<Map<String, dynamic>>.from(data['results']);
      });
    }
  }
  Future<void> sendLocationToServer(Map<String, dynamic> location) async {
    final response = await http.post(
      Uri.parse(serverUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(location),
    );
    
    if (response.statusCode == 200) {
      print("Location sent successfully");
    } else {
      print("Failed to send location");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 12,
            ),
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),
          buildFloatingSearchBar(),
        ],
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      controller: searchBarController,
      hint: 'Search places...',
      onQueryChanged: searchLocations,
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: searchResults.isEmpty
                  ? [Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No results found")))]
                  : searchResults.map((result) => ListTile(
                      title: Text(result['name'] ?? ''),
                      subtitle: Text(result['formatted_address'] ?? ''),
                      onTap: () {
                        final location = {
                          'name': result['name'],
                          'address': result['formatted_address'],
                          'lat': result['geometry']['location']['lat'],
                          'lng': result['geometry']['location']['lng'],
                        };
                        sendLocationToServer(location);
                        mapController?.animateCamera(
                          CameraUpdate.newLatLng(
                            LatLng(location['lat'], location['lng']),
                          ),
                        );
                        searchBarController.close();
                      },
                    )).toList(),
            ),
          ),
        );
      },
    );
  }
}

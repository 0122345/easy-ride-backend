//import 'package:eazyride_mobile/auth/welcm.dart';
import 'package:eazyride_mobile/components/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late AnimationController _animationController;
  // ignore: unused_field
  late Animation<double> _animation;
  // For storing the map controller
  MapController mapController = MapController();


  @override
  void initState() {
    // TODO: implement initState no animation for now
    // _animationController = AnimationController(
    //   vsync: true,
    //   duration: Duration(seconds: 1),  
    // )..repeat(reverse: true);  

    // _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
    //   CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    // );
    super.initState();
  }

@override
void dispose() {
  _animationController.dispose();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
                // center: LatLng(30.0444, -1.9441),
                // zoom: 12.0,
                ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(30.0444, -1.9441),
                    width: 80.0,
                    height: 80.0,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Center(
            child: Dialog(
              backgroundColor: Colors.white,
              shadowColor: Colors.green.shade900,
              child: SizedBox(
                width: 300,
                height: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // AnimatedBuilder(
                    //   animation: _animationController,
                    //   builder: (context, child) {
                    //     return Transform.scale(
                    //       scale: _animation.value,
                    //       child: Icon(
                    //         Icons.location_on,
                    //         color: Colors.amber,
                    //         size: 60.0,
                    //       ),
                    //     );
                    //   },
                    // ),

                    Image.asset("assets/images/location.png"),
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'Enable Your location',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            text: "Choose your location to start find the",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                            children: [
                              TextSpan(
                                text: "   request around you",
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement location permission request here
                          },
                          child: Container(
                            width: 250,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Use my location',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RoleSelectionScreen()));
                          },
                          child: const Text(
                            'Skip for now',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


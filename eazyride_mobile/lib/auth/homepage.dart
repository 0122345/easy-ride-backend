// import 'package:eazyride_mobile/auth/driver/home_map.dart';
// import 'package:eazyride_mobile/components/role.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// class _HomepageState extends State<Homepage> {
//   MapboxMap? mapboxMap;
//   Position? currentPosition;
//   bool locationPermissionGranted = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeLocation();
//   }

//   Future<void> _initializeLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) throw 'Location services are disabled';

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw 'Location permission denied';
//         }
//       }

//       currentPosition = await Geolocator.getCurrentPosition();
//       setState(() => locationPermissionGranted = true);
//       _initializeMapMarkers();
      
//     } catch (e) {
//       setState(() => locationPermissionGranted = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString()))
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           MapWidget(
//             key: const ValueKey("mapWidget"),
//             resourceOptions: ResourceOptions(
//               accessToken: 'pk.eyJ1IjoibnR3YXJpZmlhY3JlIiwiYSI6ImNtN2UzZjBpbDA1NWMybXM3NDc3bGJlOGYifQ.AXM-Vk9Vq7mzYyoQH5AnMw'
//             ),
//             styleUri: MapboxStyles.MAPBOX_STREETS,
//             cameraOptions: CameraOptions(
//               center: Point(
//                 coordinates: Position(
//                   currentPosition?.longitude ?? 30.0619,
//                   currentPosition?.latitude ?? -1.9403,
//                 ),
//               ),
//               zoom: 15.0,
//             ),
//             onMapCreated: _onMapCreated,
//           ),
//           GestureDetector(
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(                builder: (context) => HomeDriverWrapper(
//                   userId: userId,
//                   token: token,
//                   email: email,
//                 ),
//               ),
//             ),

//             child: Icon(Icons.home,
//              size: 30,
//              color: Colors.amber,
//             ),),
//           if (!locationPermissionGranted)
//             Center(
//               child: Dialog(
//                 backgroundColor: Colors.white,
//                 shadowColor: Colors.green.shade900,
//                 child: SizedBox(
//                   width: 300,
//                   height: 400,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Image.asset("assets/images/location.png"),
//                       Column(
//                         children: [
//                           const SizedBox(height: 10),
//                           const Text(
//                             'Enable Your location',
//                             style: TextStyle(fontSize: 20),
//                           ),
//                           const SizedBox(height: 10),
//                           Text.rich(
//                             TextSpan(
//                               text: "Choose your location to start find the",
//                               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                               children: [
//                                 TextSpan(
//                                   text: "   request around you",
//                                   style: TextStyle(
//                                     color: Colors.grey[600],
//                                     fontWeight: FontWeight.bold
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 10),
//                           GestureDetector(
//                             onTap: requestLocationPermission,
//                             child: Container(
//                               width: 250,
//                               height: 50,
//                               decoration: BoxDecoration(
//                                 color: Colors.yellow,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Center(
//                                 child: Text(
//                                   'Use my location',
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           GestureDetector(
//                             onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>  HomeDriverWrapper(),
//                               )
//                             ),
//                             child: const Text(
//                               'Skip for now',
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 40),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

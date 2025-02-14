//import 'package:eazyride_mobile/components/auth/change_password.dart';
import 'package:eazyride_mobile/components/profile.dart';
import 'package:eazyride_mobile/history/activity.dart';
import 'package:eazyride_mobile/history/home.dart';
import 'package:eazyride_mobile/licence/privacy.dart';
import 'package:eazyride_mobile/settings/home.dart';
import 'package:eazyride_mobile/theme/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';


class MyDrawerController extends GetxController {
  final zoomDrawerController = ZoomDrawerController();
  final _isDrawerOpen = false.obs;

  bool get isDrawerOpen => _isDrawerOpen.value;

  void toggleDrawer() {
    if (_isDrawerOpen.value) {
      zoomDrawerController.close?.call();
      _isDrawerOpen.value = false;
    } else {
      zoomDrawerController.open?.call();
      _isDrawerOpen.value = true;
    }
    update();
  }
}
class MenuScreen extends GetView<MyDrawerController> {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.find<MyDrawerController>().toggleDrawer();
                    },
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Back",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
           const SizedBox(height: 20),
           CircleAvatar(),
           const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text("Edit Profile"),
                  ],
                ),
                const SizedBox(height: 10),
                
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.local_activity , color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text("Activity"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeSettings(),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.settings_suggest_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text("Settings"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.history , color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text("History"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileEditScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.maps_ugc , color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text("Address"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacyPolicyScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.report, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text("Complain"),
                      //HomeSettings
                    ],
                  ),
                ),
                const SizedBox(height: 10),
               GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => ChangePasswordScreen(),
                  //     ),
                  //   );
                },
               child: const Row(
                  children: [
                    Icon(Icons.remove_from_queue , color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text("Referral"),
                  ],
                ),),
                const SizedBox(height: 10),
              ],
            ),
          ),
          // text as a divider()
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 12, left: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "About Us",
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 16, left: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.help, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text("Help and support"),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.logout , color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text("Logout"),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),

          //search functionality
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Container(
                  width: 120,
                  height: 45,
                  child: const TextField(
                    //TODO: i will do a controller function
                    decoration: InputDecoration(
                      labelText: "Search ",
                      // icon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                      ),
                    ),
                    //TODO: function and other input decoration
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 40,
                  decoration: BoxDecoration(
                    color: HexColor("#EDAE10"),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
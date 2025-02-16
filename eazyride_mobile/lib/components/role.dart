import 'package:eazyride_mobile/auth/driver/signup.dart';
import 'package:eazyride_mobile/auth/homepage.dart';
import 'package:eazyride_mobile/auth/passenger/login.dart';
import 'package:eazyride_mobile/transport/request/driver/ride_request.dart';
import 'package:eazyride_mobile/transport/request/passenger/ride_request.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoleSelectionScreen extends StatefulWidget {
  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool isDriver = false;
  bool isCustomer = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDriver = prefs.getBool('isDriver') ?? false;
    });
  }

  Future<void> _saveUserRole(bool role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDriver', role);
    await _syncUserRole(role);
  }

  Future<void> _syncUserRole(bool role) async {
    final response = await http.post(
      Uri.parse('https://backend.com/api/role'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'role': role ? 'driver' : 'customer'}),
    );
    if (response.statusCode == 200) {
      print('Role synced successfully');
    } else {
      print('Failed to sync role');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Customer',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Click On This Yellow Button',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              Neumorphic(
                style: NeumorphicStyle(
                  depth: 5,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                  color: Colors.white,
                ),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (details.primaryDelta! > 10) {
                      setState(() {
                        isDriver = true;
                        isCustomer = false;
                      });
                      _saveUserRole(true);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Homepage()));
                    } else if (details.primaryDelta! < -10) {
                      setState(() {
                        isDriver = false;
                        isCustomer = true;
                      });
                         Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Homepage()));
                      _saveUserRole(true);
                    }
                  },
                  child: Container(
                    width: 280,
                    height: 70,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          duration: Duration(milliseconds: 300),
                          alignment: isDriver
                              ? Alignment.centerRight
                              : isCustomer 
                                 ? Alignment.centerLeft
                                 :Alignment.center,
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              color: Colors.yellow,
                              shape: NeumorphicShape.convex,
                              boxShape: NeumorphicBoxShape.circle(),
                            ),
                            child: Container(
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Driver',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Slide To Join As Driver',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildBack(BuildContext context) {
  return Row(
    children: [
      Icon(Icons.arrow_back_ios_rounded),
      const SizedBox(width: 20),
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Text(
          "Back",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    ],
  );
}

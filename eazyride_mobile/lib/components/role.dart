import 'package:dio/dio.dart';
import 'package:eazyride_mobile/auth/passenger/home_map.dart';
import 'package:eazyride_mobile/auth/driver/home_map.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isDriver = false;
  bool isCustomer = false;
  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://easy-ride-backend-xl8m.onrender.com/api',
      headers: {'Content-Type': 'application/json'},
    ));
  }

  Future<void> _saveAuthData(String token, String userId, bool isDriver) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', userId);
    await prefs.setBool('isDriver', isDriver);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                      _saveAuthData('', '', true);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeDriverWrapper(
                            userId: '',
                            token: '',
                            email: '',
                          ),
                        ),
                      );
                    } else if (details.primaryDelta! < -10) {
                      setState(() {
                        isDriver = false;
                        isCustomer = true;
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeWrapper()));
                      _saveAuthData('', '', false);
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
                                  : Alignment.center,
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              color: Colors.yellow,
                              shape: NeumorphicShape.convex,
                              boxShape: NeumorphicBoxShape.circle(),
                            ),
                            child: SizedBox(
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

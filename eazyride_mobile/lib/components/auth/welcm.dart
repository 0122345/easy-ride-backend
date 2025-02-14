import 'package:eazyride_mobile/components/auth/login.dart';
import 'package:eazyride_mobile/components/auth/signup.dart';
import 'package:eazyride_mobile/theme/hex_color.dart';
import 'package:flutter/material.dart';

class WelcmScreen extends StatelessWidget {
  const WelcmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
           
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [
            Column(
              children: [
                Image.asset(
                  'assets/images/WelcomeScreen.png'
                  ),

                const SizedBox(height: 20.0),
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Have a better sharing experience',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 80),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUp()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: HexColor("#EDAE10"),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Create an account',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  // TODO: directing to enabling location
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: HexColor("#FFFFFF"),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: HexColor("#EDAE10"),
                          style: BorderStyle.solid,
                          strokeAlign: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            color: HexColor("#EDAE10"),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:eazyride_mobile/auth/homepage.dart';
import 'package:eazyride_mobile/theme/hex_color.dart';
import 'package:flutter/material.dart';
 
class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
        backgroundColor: HexColor("#EDAE10")
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Introduction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#EDAE10"),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'We value your privacy and are committed to protecting your personal information. This Privacy Policy outlines how we collect, use, and protect your data when you use our app.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 20),
              Text(
                '1. Information We Collect',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#EDAE10"),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'We may collect personal information such as your name, email address, and other relevant data that you provide to us when you use the app.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 20),
              Text(
                '2. How We Use Your Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#EDAE10"),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'We use your personal information to provide and improve the app’s services, including sending notifications and updates related to your activity within the app.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 20),
              Text(
                '3. Data Security',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#EDAE10"),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'We implement appropriate security measures to protect your data. However, no method of transmission over the internet is 100% secure, so we cannot guarantee the absolute security of your information.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 20),
              Text(
                '4. Third-Party Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#EDAE10"),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'We do not share your personal information with third parties without your consent, except where required by law or in connection with a service you have requested.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 20),
              Text(
                '5. Changes to this Privacy Policy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#EDAE10"),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'We may update this Privacy Policy from time to time. Any changes will be posted on this page with an updated revision date.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 30),
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#EDAE10"),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'If you have any questions or concerns regarding this Privacy Policy, please contact us at support@example.com.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),

              SizedBox(height: 23.0),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: GestureDetector(
                  onTap: () {
                     Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Homepage()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Forwad",
                       style: TextStyle(
                        fontSize: 18.0,
                       ),
                      ),
                      
                      SizedBox(width: 20),
                  
                      Container(
                        width: 50,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: HexColor("#EDAE10"),
                          border: Border.all(
                            color: HexColor("#FFFFFF"),
                            width: 1.0,    
                          ),
                        ),
                        child: Icon(Icons.arrow_forward_ios_outlined,
                        size: 30.0,
                        color: Colors.white,
                        )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

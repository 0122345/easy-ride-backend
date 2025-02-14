import 'package:flutter/material.dart';
import 'package:eazyride_mobile/theme/hex_color.dart';

class HomeSettings extends StatelessWidget {
  const HomeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#FFFFFF"),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildCard(context, "Change Password", "/resetpassworf"),
          _buildCard(context, "Change Language", "/translate"),
          _buildCard(context, "Privacy Policy", "/privacy"),
          _buildCard(context, "Contact Us", "/contact"),
          _buildCard(context, "Delete Account", "/deleteacc"),
          _buildCard(context, "Help and Support", "/help"),
        ],
      ),
    );
  }
}

 
AppBar _buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: HexColor("#FFFFFF"),
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
      onPressed: () => Navigator.pop(context),
    ),
    title: const Text(
      "Settings",
      style: TextStyle(color: Colors.black, fontSize: 20),
    ),
    centerTitle: true,
  );
}

 
Widget _buildCard(BuildContext context, String text, String link) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, link);
    },
    child: Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HexColor("#FEC400"),),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.arrow_forward_ios, color: HexColor("#000000")),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    ),
  );
}

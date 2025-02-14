import 'package:flutter/material.dart';
import 'package:eazyride_mobile/theme/hex_color.dart';

class HomeNotifications extends StatelessWidget {
  const HomeNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#F5F5F5"),
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: ListView(
          children: [
            _buildDateSection("Today", [
              NotificationCard(
                icon: Icons.payment,
                title: "Payment Successfully!",
                subtitle: "Lorem ipsum dolor sit amet consectetur.",
              ),
              NotificationCard(
                icon: Icons.local_offer,
                title: "30% Special Discount!",
                subtitle: "Lorem ipsum dolor sit amet consectetur.",
              ),
            ]),
            _buildDateSection("Yesterday", [
              NotificationCard(
                icon: Icons.payment,
                title: "Payment Successfully!",
                subtitle: "Lorem ipsum dolor sit amet consectetur.",
              ),
              NotificationCard(
                icon: Icons.credit_card,
                title: "Credit Card Added!",
                subtitle: "Lorem ipsum dolor sit amet consectetur.",
              ),
              NotificationCard(
                icon: Icons.account_balance_wallet,
                title: "Added Money Wallet Successfully!",
                subtitle: "Lorem ipsum dolor sit amet consectetur.",
              ),
              NotificationCard(
                icon: Icons.local_offer,
                title: "5% Special Discount!",
                subtitle: "Lorem ipsum dolor sit amet consectetur.",
              ),
            ]),
            _buildDateSection("May 27, 2023", [
              NotificationCard(
                icon: Icons.payment,
                title: "Payment Successfully!",
                subtitle: "Lorem ipsum dolor sit amet consectetur.",
              ),
            ]),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: HexColor("#F5F5F5"),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Notifications",
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
      centerTitle: true,
    );
  }

  Widget _buildDateSection(String date, List<Widget> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            date,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ...notifications,
      ],
    );
  }
}

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const NotificationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.black,
              radius: 22,
              child: Icon(icon, color: Colors.amber, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

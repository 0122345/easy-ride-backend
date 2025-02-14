import 'dart:ui';
import 'package:eazyride_mobile/theme/hex_color.dart';
import 'package:flutter/material.dart';

class RequestForRentScreen extends StatelessWidget {
  const RequestForRentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#FFFFFF"),
      body: Stack(
        children: [
          _buildBlurBackground(),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [ 
                        _buildBackButton(context),
                        const SizedBox(height: 60),
                        _buildLocationSection(),
                        const SizedBox(height: 10),
                        _buildVehicleDetails(),
                        const SizedBox(height: 10),
                        _buildChargeDetails(),
                        const SizedBox(height: 10),
                        _buildPaymentMethods(context),
                      ],
                    ),
                  ),
                ),
              ),
              _buildConfirmButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlurBackground() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(color: Colors.black.withOpacity(0.1)),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(width: 10),
        const Text(
          "Back",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 30),
        Text(
          "Request for Ride",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Current Location", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("221 Baker Street, London, UK"),
        SizedBox(height: 10),
        Text("Office", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("Mustang Shelby GT, 1.1km away"),
      ],
    );
  }

  Widget _buildVehicleDetails() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: HexColor("#FFFBE7"),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            strokeAlign: BorderSide.strokeAlignOutside,
            style: BorderStyle.solid,
            color: HexColor("#FEC400"),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
         // crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           Column(
            children: [
              Text("Toyota Hiace"),
              Text("⭐ 4.9 (321 reviews)"),
            ],
           ),
           const SizedBox(width: 30,),
           Image.asset('assets/images/cars/car.png'),
         ],
        ),
      ),
    );
  }


  Widget _buildChargeDetails() {
    return const Column(
      
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Charge", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("- Mustang Rent: \$200"),
        Text("- VAT 10%: \$20"),
        Text("- Promo Code: -\$5"),
      ],
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Payment Method",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (_, __, ___) => const PaymentMethodScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text("Visa **** 8970"),
              subtitle: const Text("Expires 12/25"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 26),
      child: Container(
        width: double.infinity,
        height: 50,
         decoration: BoxDecoration(
           color: HexColor("#EDAE10"),
           borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              strokeAlign: BorderSide.strokeAlignOutside,
              style: BorderStyle.solid,
              color: HexColor("#FEC400"),
            ),
         ),
         child: Center(
           child: Text("Confirm Ride",
           style: TextStyle(
             fontSize:20,
             color: Colors.white,
            ),
           ),
         ),
      ),
    );
  }
}

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Payment Method")),
      body: Column(
        children: [
          const ListTile(
              leading: Icon(Icons.credit_card), title: Text("Visa **** 8970")),
          const ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text("My Wallet")),
          const ListTile(leading: Icon(Icons.money), title: Text("Cash")),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50)),
        onPressed: () {},
        child: const Text("Confirm Ride"),
      ),
    );
  }
}

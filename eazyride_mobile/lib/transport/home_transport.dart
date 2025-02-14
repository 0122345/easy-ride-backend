import 'package:eazyride_mobile/theme/hex_color.dart';
import 'package:eazyride_mobile/transport/car/select_ride_car.dart';
import 'package:flutter/material.dart';

class HomeTransp extends StatelessWidget {
  const HomeTransp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#FFFFFF"),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 22.0),
        child: SafeArea(
          child: Center(
            child: Stack(
              children: [
                Positioned.fill(
                  top: 120,   
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        _buildCard( 
                          imagePath: "assets/images/Bike.png",
                          text: "Bike",
                        ),
                        GestureDetector(
                          onTap: (){
                             Navigator.push(
                              context, MaterialPageRoute(builder: (context) => SelectCarRide()));
                          },
                          child: _buildCard(
                            imagePath: "assets/images/Car.png",
                            text: "Car",
                          ),
                        ),
                        _buildCard(
                          imagePath: "assets/images/Cyclebicyle.png",
                          text: "Bicyle",
                        ),
                        _buildCard(
                          imagePath: "assets/images/Taxitaxi.png",
                          text: "Taxi",
                        ),
                      ],
                    ),
                  ),
                ), 
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildAppBar(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildCard({required String imagePath, required String text}) {
  return Card(
    elevation: 5.0,
    margin: EdgeInsets.all(10.0),
    child: ClipRect(
      child: Container(
        height: 540,
        width: 130.0,
        decoration: BoxDecoration(
          color: HexColor("#FFFBE7"),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: HexColor("#FED857"), width: 2),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Column(
              children: [ 
                Image.asset(
                  imagePath,
                  height: 40.0,  
                  fit: BoxFit.cover,
                ),  
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}


Widget _buildAppBar(BuildContext context) {
  return Row(
    children: [
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Row(
          children: [
            Icon(Icons.arrow_back_ios),
            Text("Back"),
          ],
        ),
      ),
      SizedBox(width: 30),
      Flexible(
        flex: 0,
        child: Text(
          "Select Your Transport",
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

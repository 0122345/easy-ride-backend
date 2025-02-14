import 'package:eazyride_mobile/home/home_map.dart';
import 'package:eazyride_mobile/theme/hex_color.dart';
import 'package:flutter/material.dart';

class CarDetail extends StatefulWidget {
  const CarDetail({Key? key}) : super(key: key);

  @override
  State<CarDetail> createState() => _CarDetailState();
}

class _CarDetailState extends State<CarDetail> {
  final List<Map<String, dynamic>> cars = [
    {
      'name': 'Toyota Hiace',
      'rating': 4.9,
      'reviews': 531,
      'image': 'assets/images/cars/car.png',
      'specs': {
        'Max. power': '250hp',
        'Fuel': '10km per litre',
        'Max. speed': '220km/h',
        '0-60mph': '25sec',
      },
      'features': {
        'Model': 'GT5000',
        'Capacity': '760hp',
        'Color': 'Red',
        'Gear type': 'Automatic',
      },
    },
    {
      'name': 'Ford Transit',
      'rating': 4.7,
      'reviews': 410,
      'image': 'assets/images/cars/Carvan.png',
      'specs': {
        'Max. power': '240hp',
        'Fuel': '9km per litre',
        'Max. speed': '210km/h',
        '0-60mph': '28sec',
      },
      'features': {
        'Model': 'EcoBoost',
        'Capacity': '700hp',
        'Color': 'Blue',
        'Gear type': 'Manual',
      },
    },
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    //final car = cars[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Back"),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final currentCar = cars[index];
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          currentCar['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: const Icon(Icons.star,
                                    color: Colors.amber)),
                            const SizedBox(width: 4),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${currentCar['rating']} (${currentCar['reviews']} reviews)',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Image.asset(
                        currentCar['image'],
                        height: 200,
                        width: 450,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Specifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .start, // Or MainAxisAlignment.spaceEvenly depending on your need
                          children:
                              currentCar['specs'].entries.map<Widget>((entry) {
                            return Container(
                              margin: const EdgeInsets.only(
                                  right:
                                      8.0), // Optional: to add space between containers
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: HexColor("#FED857"), width: 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 12.0),
                                child: Column(
                                  children: [
                                    Text(entry.key,
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.value,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Car Features',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children:
                            currentCar['features'].entries.map<Widget>((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: HexColor("#FED857"), width: 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key,
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 20, 20, 20))),
                                    Text(
                                      entry.value,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          OutlinedButtonTheme(
            data: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: BorderSide(
                  color: HexColor("#FED857"),
                  width: 2,
                ), // Border color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                textStyle: TextStyle(fontSize: 16.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: HexColor("#EDAE10"),
                  ),
                  child: Text("Book Later"),
                ),
                SizedBox(height: 70),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeWrapper()));
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: HexColor("#EDAE10"),
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Ride Now"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

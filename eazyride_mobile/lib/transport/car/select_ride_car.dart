import 'package:eazyride_mobile/transport/car/car_detail.dart';
import 'package:flutter/material.dart';

class SelectCarRide extends StatelessWidget {
  final List<Car> cars = [
    Car(
      name: 'Toyota Hiace',
      image: 'assets/images/cars/car.png',
      details: 'Automatic | 3 seats | Octane',
      distance: '800m (5mins away)',
    ),
    Car(
      name: 'Suzuki Alto',
      image: 'assets/images/cars/Carvan.png',
      details: 'Automatic | 3 seats | Octane',
      distance: '800m (5mins away)',
    ),
    Car(
      name: 'Toyota RAV4',
      image: 'assets/images/cars/image5.png',
      details: 'Automatic | 3 seats | Octane',
      distance: '800m (5mins away)',
    ),
    Car(
      name: 'Hyundai H1 Van',
      image: 'assets/images/cars/image6.png',
      details: 'Automatic | 3 seats | Octane',
      distance: '800m (5mins away)',
    ),
    Car(
      name: 'BMW',
      image: 'assets/images/cars/car.png',
      details: 'Automatic | 3 seats | Octane',
      distance: '800m (5mins away)',
    ),
  ];

  SelectCarRide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 20.0),
              _buildHeaderText(),
              const SizedBox(height: 20.0),
              Expanded(
                child: ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    return CarCard(car: cars[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Row(
        children: const [
          Icon(Icons.arrow_back_ios_new_outlined),
          SizedBox(width: 8.0),
          Text(
            "Back",
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Car Ride",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          "${cars.length} cars found",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class Car {
  final String name;
  final String image;
  final String details;
  final String distance;

  Car({
    required this.name,
    required this.image,
    required this.details,
    required this.distance,
  });
}

class CarCard extends StatelessWidget {
  final Car car;

  const CarCard({Key? key, required this.car}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.orange.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.name,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        car.details,
                        style: TextStyle(color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16.0,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4.0),
                          Flexible(
                            child: Text(
                              car.distance,
                              style: TextStyle(color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                Image.asset(
                  car.image,
                  height: 50,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
             context, MaterialPageRoute(builder: (context) => CarDetail()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'View car list',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:eazyride_mobile/licence/privacy.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
 

class OnboardingSc extends StatefulWidget {
  const OnboardingSc({super.key});

  @override
  State<OnboardingSc> createState() => _OnboardingScState();
}

class _OnboardingScState extends State<OnboardingSc> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => isLastPage = index == 2);
            },
            children: [
              buildPage(
                image: 'assets/onboard/truckone.png',
                title: "Anywhere you are",
                description: "Sell houses easily with the help of Listenary.",
              ),
              buildPage(
                image: 'assets/onboard/secondp.jpg',
                title: "At anytime",
                description: "Sell houses easily with the help of Listenary.",
              ),
              buildPage(
                image: 'assets/onboard/third.png',
                title: "Book your Motorbike, car, & lorry",
                description: "Sell houses easily with the help of Listenary.",
              ),
            ],
          ),
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () => _controller.jumpToPage(2),
              child: Text("Skip", style: TextStyle(fontSize: 16)),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 20,
            child: SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.yellow,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: isLastPage
                ? FloatingActionButton(
                    onPressed: () {
                       Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>  PrivacyPolicyScreen()));
                    },
                    backgroundColor: Colors.yellow,
                    child: Text("Go"),
                  )
                : GestureDetector(
                    onTap: () => _controller.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
                    child:  Icon(Icons.arrow_forward),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({required String image, required String title, required String description}) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 250),
          SizedBox(height: 20),
          Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
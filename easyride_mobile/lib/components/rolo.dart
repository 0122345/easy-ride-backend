//TODO: I will have to look for this logic later
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SlideButtonScreen extends StatefulWidget {
  @override
  _SlideButtonScreenState createState() => _SlideButtonScreenState();
}

class _SlideButtonScreenState extends State<SlideButtonScreen> {
  double _sliderValue = 0.0;
  bool _isDriver = false;

  void _onSlideChanged(double value) {
    setState(() {
      _sliderValue = value;
    });
  }

  void _onSlideEnd() {
    if (_sliderValue >= 0.8) {
      setState(() {
        _isDriver = true;
      });
      _sendDataToBackend();
    } else {
      setState(() {
        _sliderValue = 0.0;
      });
    }
  }

  Future<void> _sendDataToBackend() async {
    final url = Uri.parse('https://your-backend-api.com/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'role': _isDriver ? 'driver' : 'passenger'}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slide to Join'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeumorphicText(
              'Slide to Join as Driver',
              style: NeumorphicStyle(
                depth: 5,
                color: Colors.black,
              ),
              textStyle: NeumorphicTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Neumorphic(
              style: NeumorphicStyle(
                depth: -5,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
              ),
              child: Container(
                width: 300,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.yellow,
                ),
                child: Slider(
                  value: _sliderValue,
                  onChanged: _onSlideChanged,
                  onChangeEnd: (value) => _onSlideEnd(),
                  min: 0.0,
                  max: 1.0,
                  activeColor: Colors.transparent,
                  inactiveColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
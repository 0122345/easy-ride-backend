import 'package:eazyride_mobile/theme/hex_color.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#FFFFFF"),
      appBar: AppBar(
        title: const Text("History"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
                height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: HexColor("#FFFBE7"),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabButton("Upcoming", 0),
                  _buildTabButton("Completed", 1),
                  _buildTabButton("Cancelled", 2),
                ],
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                _buildListView("Upcoming"),
                _buildListView("Completed"),
                _buildListView("Cancelled"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: _selectedIndex == index ? Colors.amber : HexColor("#FFFBE7"),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _selectedIndex == index ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildListView(String status) {
    List<Map<String, String>> items = [
      {"name": "Note", "time": "Today at 09:20 am"},
      {"name": "Henry", "time": "Today at 10:20 am"},
      {"name": "William", "time": "Tomorrow at 09:20 am"},
    ];

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: HexColor("#FEC400"),
                style: BorderStyle.solid,
                strokeAlign: 1.0,
              ), 
              ),
            title: Text(items[index]["name"]!),
            subtitle: Text(items[index]["time"]!),
            trailing: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                status == "Upcoming"
                    ? ""
                    : status == "Completed"
                        ? "Done"
                        : "Cancel",
                key: ValueKey(status),
                style: TextStyle(
                  color: status == "Completed"
                      ? Colors.green
                      : status == "Cancelled"
                          ? Colors.red
                          : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

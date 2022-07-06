import 'package:flutter/material.dart';
import 'package:track/screens/restaurants_map.dart';
import 'package:track/screens/restaurants_table.dart';


class HomeManagement extends StatefulWidget {
  const HomeManagement({Key? key}) : super(key: key);

  @override
  State<HomeManagement> createState() => _HomeManagementState();
}

class _HomeManagementState extends State<HomeManagement> {
  final List<Widget> _pages = [
    const RestaurantsMap(),
    const RestaurantsTable()
  ];
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (selectedIndex) {
          setState(() {
            _index = selectedIndex;
          });
        },
        currentIndex: _index,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.map), label: 'Restaurant Maps'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fastfood), label: 'Restaurants Table'),
        ],
      ),
    );
  }
}

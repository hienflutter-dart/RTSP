import 'package:baitapfl/profile/profile.dart';
import 'package:baitapfl/scan/scanqr.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  final int userId;

  MenuPage({required this.userId});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();

    _pages.add(HomeScan());
    _pages.add(ProfilePage(userId: widget.userId));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Page'),
        backgroundColor: Colors.indigo,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'HomeScan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

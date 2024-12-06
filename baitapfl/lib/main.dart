import 'package:baitapfl/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? userId;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });
  }

  void _saveLoginStatus(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCAN QR APP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home:  FutureBuilder<int?>(
        future: _navigateToLogin(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            userId = snapshot.data;
            _saveLoginStatus(userId!);
            return MenuPage(userId: userId!);
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
  Future<int?> _navigateToLogin(BuildContext context) async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    return result;
  }
}

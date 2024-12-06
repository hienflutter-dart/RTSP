import 'package:baitapfl/signup.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import ' flutter_mysql_api/api.dart';
import 'menu.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool show = true;
  bool isLoginFailed = false;
  bool isLoading = false;
  final usrName = TextEditingController();
  final usrPassword = TextEditingController();

  Future<void> login() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
      isLoginFailed = false;
    });

    try {
      final response = await http.post(
        urllogin,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usrName': usrName.text,
          'usrPassword': usrPassword.text,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Đăng nhập thành công: ${data['message']}");
        final userId = data['user']['usrId'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuPage(userId: userId)),
        );
      } else {
        final error = jsonDecode(response.body);
        showAlertDialog(error['message']);
        setState(() {
          isLoginFailed = true;
        });
      }
    } catch (e) {
      print("Lỗi đăng nhập: $e");
      setState(() {
        isLoginFailed = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Thông báo"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Center(
          child: Text(
            'LOGIN',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w200,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 150),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 30, 30),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.boy_rounded),
                ),
              ),
              const Text(
                'HELLO\nWELCOME BACK',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usrName,
                decoration: const InputDecoration(
                  hintStyle: TextStyle(fontWeight: FontWeight.w400),
                  border: OutlineInputBorder(),
                  labelText: 'Nhập vào tên nè!',
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: AlignmentDirectional.centerEnd,
                children: <Widget>[
                  TextField(
                    obscureText: show,
                    controller: usrPassword,
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(fontWeight: FontWeight.w400),
                      border: OutlineInputBorder(),
                      labelText: 'Mật khẩu',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          show = !show;
                        });
                      },
                      icon: Icon(
                        show ? Icons.visibility_off : Icons.visibility,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isLoginFailed)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    "Mật khẩu hoặc tên đăng nhập không đúng.",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: login,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text('Đăng nhập'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text('NEW USER,'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ),
                          );
                        },
                        child: const Text('SIGN UP'),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('FORGOT PASSWORD'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

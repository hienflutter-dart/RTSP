import 'dart:convert';
import 'package:flutter/material.dart';
import ' flutter_mysql_api/api.dart';
import 'login.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController usrName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController usrPassword = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool showLoading = false;
  bool show = true;
  bool show2 = true;

  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> captureImage() async {
    final capturedFile = await _picker.pickImage(source: ImageSource.camera);
    if (capturedFile != null) {
      setState(() {
        _selectedImage = File(capturedFile.path);
      });
    }
  }

  Future<void> signUp() async {
    if (_selectedImage == null) {
      showAlertDialog("Vui lòng chọn hoặc chụp ảnh!");
      return;
    }

    setState(() {
      showLoading = true;
    });

    try {
      final bytes = File(_selectedImage!.path).readAsBytesSync();
      final base64Image = base64Encode(bytes);
      final response = await http.post(
        urlsignup,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usrName': usrName.text,
          'email': email.text,
          'usrPassword': usrPassword.text,
          'image': base64Image,
        }),
      );

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        showAlertDialog('Đăng ký thành công!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        print('Server error: ${response.statusCode} - ${response.body}');
        showAlertDialog('Đăng ký thất bại: ${response.body}');
      }
    } catch (e) {
      print("Đã xảy ra lỗi: $e");
      showAlertDialog("Đã xảy ra lỗi: $e");
    } finally {
      setState(() {
        showLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Center(
          child: Text(
            'SIGN UP',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w200, color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_selectedImage != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(_selectedImage!),
                )
              else
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text("Chọn ảnh"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: captureImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Chụp ảnh"),
                  ),
                ],
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
              TextField(
                controller: email,
                decoration: const InputDecoration(
                  hintStyle: TextStyle(fontWeight: FontWeight.w400),
                  border: OutlineInputBorder(),
                  labelText: 'Nhập vào email!',
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
              Stack(
                alignment: AlignmentDirectional.centerEnd,
                children: <Widget>[
                  TextField(
                    obscureText: show2,
                    controller: confirmPassword,
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
                          show2 = !show2;
                        });
                      },
                      icon: Icon(
                        show2 ? Icons.visibility_off : Icons.visibility,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: signUp,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: showLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text('Đăng kí'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

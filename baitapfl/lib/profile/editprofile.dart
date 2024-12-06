import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../menu.dart';

class EditProfilePage extends StatefulWidget {
  final int userId;

  const EditProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController usrName = TextEditingController();
  final TextEditingController email = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool showLoading = false;
  String? currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      showLoading = true;
    });

    try {
      final url = Uri.parse('http://192.168.209.136:3000/users/${widget.userId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          usrName.text = data['usrName'];
          email.text = data['email'];
          currentAvatarUrl = data['image'];
        });
      } else {
        showAlertDialog('Không thể tải thông tin người dùng!');
      }
    } catch (e) {
      showAlertDialog('Lỗi khi tải thông tin: $e');
    } finally {
      setState(() {
        showLoading = false;
      });
    }
  }

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

  Future<Uint8List> _loadImage(String base64String) async {
    try {
      String cleanedBase64String = base64String;
      if (base64String.startsWith('data:image/png;base64,')) {
        cleanedBase64String = base64String.replaceFirst('data:image/png;base64,', '');
      } else if (base64String.startsWith('data:image/jpeg;base64,')) {
        cleanedBase64String = base64String.replaceFirst('data:image/jpeg;base64,', '');
      }

      return base64Decode(cleanedBase64String);
    } catch (e) {
      print("Lỗi khi giải mã Base64: $e");
      rethrow;
    }
  }

  Future<void> updateProfile() async {
    setState(() {
      showLoading = true;
    });

    try {
      String? base64Image;

      if (_selectedImage != null) {
        final bytes = File(_selectedImage!.path).readAsBytesSync();
        base64Image = base64Encode(bytes);
      }

      final url = Uri.parse('http://192.168.209.136:3000/users/${widget.userId}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usrName': usrName.text,
          'email': email.text,
          'image': base64Image ?? currentAvatarUrl,
        }),
      );

      if (response.statusCode == 200) {
        showAlertDialog('Cập nhật thông tin thành công!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuPage(userId: widget.userId,)),
        );
      } else {
        showAlertDialog('Cập nhật thất bại: ${response.body}');
      }
    } catch (e) {
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
            'EDIT PROFILE',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w200, color: Colors.white),
          ),
        ),
      ),
      body: showLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_selectedImage != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(_selectedImage!),
                )
              else if (currentAvatarUrl != null)
                FutureBuilder<Uint8List>(
                  future: _loadImage(currentAvatarUrl!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasData) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundImage: MemoryImage(snapshot.data!),
                      );
                    } else {
                      return const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      );
                    }
                  },
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
                  border: OutlineInputBorder(),
                  labelText: 'Nhập tên mới của bạn!',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: email,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nhập email mới!',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateProfile,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Cập nhật thông tin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

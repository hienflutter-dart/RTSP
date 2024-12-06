import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'editprofile.dart';
import '../login.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String usrName = '';
  late String email = '';
  late String profileImageUrl = '';
  Uint8List? profileImageBytes;

  @override
  void initState() {
    super.initState();
    fetchUserProfile(widget.userId);
  }

  Future<Uint8List> _loadImage(String base64String) async {
    try {
      if (base64String.isEmpty) {
        throw Exception("Chuỗi Base64 trống.");
      }

      String cleanedBase64String = base64String;
      if (base64String.startsWith('data:image/png;base64,')) {
        cleanedBase64String = base64String.replaceFirst('data:image/png;base64,', '');
      } else if (base64String.startsWith('data:image/jpeg;base64,')) {
        cleanedBase64String = base64String.replaceFirst('data:image/jpeg;base64,', '');
      }

      if (cleanedBase64String.isEmpty) {
        throw Exception("Chuỗi Base64 sau khi làm sạch trống.");
      }

      Uint8List decodedBytes = base64Decode(cleanedBase64String);

      if (decodedBytes.isEmpty) {
        throw Exception("Byte sau khi giải mã là trống.");
      }

      return decodedBytes;
    } catch (e) {
      print("Lỗi khi giải mã Base64: $e");
      rethrow;
    }
  }

  Future<void> fetchUserProfile(int userId) async {
    final response = await http.get(
      Uri.parse('http://192.168.209.136:3000/users/$userId'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      setState(() {
        usrName = data['usrName'];
        email = data['email'];
        profileImageUrl = data['image'];
      });

      try {
        profileImageBytes = await _loadImage(profileImageUrl);
      } catch (e) {
        print("Lỗi khi tải ảnh: $e");
        profileImageBytes = null;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải thông tin người dùng!')),
      );
    }
  }


  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            profileImageBytes != null
                ? CircleAvatar(
              radius: 80,
              backgroundImage: MemoryImage(profileImageBytes!),
              backgroundColor: Colors.transparent,
            )
                : const CircleAvatar(
              radius: 80,
              child: Icon(Icons.person, size: 60),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                usrName.isNotEmpty ? usrName : "Tên người dùng không có",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                email.isNotEmpty ? email : "Email không có",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(userId: widget.userId),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.edit),
      ),
    );
  }
}

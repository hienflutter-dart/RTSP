import 'package:baitapfl/scan/scan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScan extends StatelessWidget {
  const HomeScan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                "QR Code",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: Container(
                padding: const EdgeInsets.all(50),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildFeatureButton(
                      context,
                      "Scan QR code",
                      Icons.qr_code,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QRScan()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildFeatureButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.all(15),
      height: 200,
      width: 250,
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(icon, size: 90, color: Colors.white),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

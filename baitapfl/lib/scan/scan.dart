import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class QRScan extends StatefulWidget {
  const QRScan({super.key});

  @override
  State<QRScan> createState() => _QRScanState();
}

class _QRScanState extends State<QRScan> {
  bool hasPermission = false;
  bool isFlashOn = false;

  late MobileScannerController ScannerController;

  @override
  void initState() {
    super.initState();
    ScannerController = MobileScannerController();
    _checkPermission();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      hasPermission = status.isGranted;
    });
    if (hasPermission) {
      ScannerController.start();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng cấp quyền camera để sử dụng tính năng này.")),
      );
    }
  }


  Future<void> _processScannedData(String? data) async {
    if (data == null) return;
    ScannerController.stop();
    String type = 'text';
    if (data.startsWith('http://') || data.startsWith('https://')) {
      type = 'url';
    }


    showModalBottomSheet(
      context: context,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.9,
        maxChildSize: 0.9,
        builder: (context, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                "Scanned Result:",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                "Type : ${type.toUpperCase()}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        data,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      if (type == 'url')
                        ElevatedButton.icon(
                          onPressed: () {
                            _launchURL(data!);
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text("Open URL"),
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScannerController.start();  // Bật lại camera khi đóng modal
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text("Scan Again"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể mở URL")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        title: const Text('Scanner'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
                ScannerController.toggleTorch();
              });
            },
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: ScannerController,
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              if (barcode.rawValue != null) {
                final String code = barcode.rawValue!;
                _processScannedData(code);
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

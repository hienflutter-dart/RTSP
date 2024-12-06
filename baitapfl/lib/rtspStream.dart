import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class RTSPCameraPlayer extends StatefulWidget {
  @override
  _RTSPCameraPlayerState createState() => _RTSPCameraPlayerState();
}

class _RTSPCameraPlayerState extends State<RTSPCameraPlayer> {
  late VlcPlayerController _vlcPlayerController;
  final String rtspUrl = 'rtsp://admin:kimdong789@kdkids.ddns.net:554/cam/realmonitor?channel=1&subtype=1'; // Thay đổi URL của bạn

  @override
  void initState() {
    super.initState();
    _vlcPlayerController = VlcPlayerController.network(
      rtspUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
    );
  }

  @override
  void dispose() {
    _vlcPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RTSP Camera Player'),
      ),
      body: Center(
        child: VlcPlayer(
          controller: _vlcPlayerController,
          aspectRatio: 16 / 9,
          placeholder: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RTSPCameraPlayer(),
  ));
}

import 'package:camera_app/screen/camera.dart';
import 'package:flutter/material.dart';

class Openscreen extends StatelessWidget {
  const Openscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Photo Capture App', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
          icon: const Icon(Icons.camera_alt, color: Colors.black),
          label: const Text(
            'Open Camera',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}

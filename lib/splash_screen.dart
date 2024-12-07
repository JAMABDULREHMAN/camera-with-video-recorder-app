import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'camera_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CameraScreen()),
      );
    });

    return Scaffold(
      body: Center(
        child: const Text(
          "Video Recorder App",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ).animate().fadeIn(duration: 1500.ms),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  String? _videoPath;
  VideoPlayerController? _videoPlayerController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize the camera and request permissions
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameras = cameras;
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController!.initialize();
    setState(() {});
  }

  // Request camera and microphone permissions
  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  // Start recording video
  Future<void> _startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
    await _cameraController!.startVideoRecording();
    setState(() {
      _isRecording = true;
      _videoPath = filePath;
    });
  }

  // Stop recording video
  Future<void> _stopRecording() async {
    await _cameraController!.stopVideoRecording();
    setState(() {
      _isRecording = false;
    });
    _playVideo();
  }

  // Play recorded video
  void _playVideo() {
    if (_videoPath != null) {
      _videoPlayerController = VideoPlayerController.file(File(_videoPath!))
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController!.play();
          setState(() {
            _isPlaying = true;
          });
        });
    }
  }

  // Stop video playback
  void _stopVideoPlayback() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Recorder'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Positioned(
            bottom: 50,
            left: 100,
            child: Column(
              children: [
                // Record/Stop Button with animation
                AnimatedOpacity(
                  opacity: _isRecording ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: FloatingActionButton(
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                    backgroundColor: _isRecording ? Colors.red : Colors.blue,
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Play Video Button
                _videoPath != null
                    ? FloatingActionButton(
                        onPressed: _playVideo,
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.play_arrow),
                      )
                    : Container(),
                // Stop Playback Button
                _isPlaying
                    ? FloatingActionButton(
                        onPressed: _stopVideoPlayback,
                        backgroundColor: Colors.grey,
                        child: const Icon(Icons.pause),
                      )
                    : Container(),
              ],
            ).animate().slideY(begin: 1).fadeIn(duration: 500.ms),
          ),
        ],
      ),
    );
  }
}

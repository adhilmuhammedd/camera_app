import 'package:camera/camera.dart';
import 'package:camera_app/screen/fullScreen.dart';
import 'package:camera_app/screen/gallery.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  CameraController? cameraController;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;
  List<File> capturedImages = [];
  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _setupCameraController();
    _loadSavedImages();
  }

  Future<void> _setupCameraController() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        await _initializeCamera(selectedCameraIndex);
      } else {
        _showSnackBar('No cameras found');
      }
    } catch (e) {
      _showSnackBar('Camera error: $e');
    }
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    try {
      await cameraController?.dispose();
      cameraController = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.high,
      );
      await cameraController!.initialize();

      if (cameras[cameraIndex].lensDirection == CameraLensDirection.front) {
      isFlashOn = false;
    }

      if (mounted) setState(() {});
    } catch (e) {
      _showSnackBar('Failed to init camera: $e');
    }
  }

  void _switchCamera() async {
    if (cameras.length < 2) {
      _showSnackBar('No secondary camera available');
      return;
    }
    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;
    await _initializeCamera(selectedCameraIndex);
  }

  Future<void> _captureImage() async {
    try {
      final xFile = await cameraController!.takePicture();
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(xFile.path);
      final savedImage = await File(
        xFile.path,
      ).copy('${appDir.path}/$fileName');

      setState(() {
        capturedImages.insert(0, savedImage);
      });
    } catch (e) {
      _showSnackBar('Capture failed: $e');
    }
  }

  Future<void> _loadSavedImages() async {
    final appDir = await getApplicationDocumentsDirectory();
    final files = appDir.listSync();

    List<File> loadedImages = files
        .where(
          (file) => file.path.endsWith('.jpg') || file.path.endsWith('.png'),
        )
        .map((file) => File(file.path))
        .toList();

    setState(() {
      capturedImages = loadedImages;
      capturedImages.sort((a, b) => b.path.compareTo(a.path));
    });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openGallery() async {
    if (capturedImages.isEmpty) {
      _showSnackBar('No images captured yet');
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GalleryScreen(images: capturedImages)),
    );

    if (result != null && result is List<File>) {
      setState(() {
        capturedImages = result;
      });
    }

    await _loadSavedImages();
  }

  Future<void> _openFullScreen(File imageFile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullImageScreen(imageFile: imageFile)),
    );

    if (result == true) {
      await _loadSavedImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (cameraController !=null &&
          cameraController!.description.lensDirection == CameraLensDirection.back)
          IconButton(
            onPressed: () async {
              setState(() {
                isFlashOn = !isFlashOn;
              });

              if (cameraController != null) {
                await cameraController!.setFlashMode(
                  isFlashOn ? FlashMode.torch : FlashMode.off,
                );
              }
            },
            icon: Icon(
              isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: 625,
              width: 390,
              child: CameraPreview(cameraController!)),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: ElevatedButton(
                        onPressed: _switchCamera,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: Colors.white.withOpacity(0.7),
                        ),
                        child: const Icon(
                          Icons.switch_camera,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _captureImage,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.white.withOpacity(0.7),
                      ),
                      child: const Icon(
                        Icons.camera,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await _openGallery();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: Colors.white.withOpacity(0.7),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (capturedImages.isNotEmpty)
              Positioned(
                bottom: 120,
                right: 16,
                child: GestureDetector(
                  onTap: () async {
                    await _openFullScreen(capturedImages.first);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(capturedImages.first),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}

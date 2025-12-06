import 'dart:typed_data';
import 'package:aurion_hotel/_components/color.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class PassportCameraView extends StatefulWidget {
  final Function(Uint8List imageBytes) onCaptured;
  final bool uploading;

  const PassportCameraView({
    super.key,
    required this.onCaptured,
    this.uploading = false,
  });

  @override
  State<PassportCameraView> createState() => _PassportCameraViewState();
}

class _PassportCameraViewState extends State<PassportCameraView> {
  late CameraController _controller;
  bool _isReady = false;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller.initialize();
    if (!mounted) return;
    setState(() => _isReady = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Center(
        child: CircularProgressIndicator(color: auxColor),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CameraPreview(_controller),
        ),
        if (widget.uploading)
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: auxColor, strokeWidth: 3),
            ),
          ),
        Positioned(
          bottom: 20,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: auxColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            onPressed: widget.uploading
                ? null
                : () async {
                    final picture = await _controller.takePicture();
                    final bytes = await picture.readAsBytes();
                    widget.onCaptured(bytes);
                  },
            child: const Text(
              "Capture Photo",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

// import 'dart:typed_data';
// import 'package:aurion_hotel/_components/color.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// class PassportCameraView extends StatefulWidget {
//   final Function(Uint8List imageBytes) onCaptured;

//   const PassportCameraView({super.key, required this.onCaptured});

//   @override
//   State<PassportCameraView> createState() => _PassportCameraViewState();
// }

// class _PassportCameraViewState extends State<PassportCameraView> {
//   late CameraController _controller;
//   bool _isReady = false;
//   List<CameraDescription> _cameras = [];

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }

//   Future<void> _initCamera() async {
//     _cameras = await availableCameras();
//     _controller = CameraController(
//       _cameras.first,
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );
//     await _controller.initialize();
//     if (!mounted) return;
//     setState(() => _isReady = true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isReady) return const Center(child: CircularProgressIndicator(color: auxColor,));

//     return Column(
//       children: [
//         Expanded(child: CameraPreview(_controller)),
//         const SizedBox(height: 10),
//         ElevatedButton(
//           onPressed: () async {
//             final picture = await _controller.takePicture();
//             final bytes = await picture.readAsBytes();
//             widget.onCaptured(bytes);
//           },
//           child: const Text("Capture Photo"),
//         ),
//       ],
//     );
//   }
// }

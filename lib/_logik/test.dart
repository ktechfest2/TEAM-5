import 'dart:convert';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:html' as html; // NOTE: web-only
import 'package:aurion_hotel/_components/color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  String? selectedIdType;
  String? uploadedFileUrl;
  bool isUploading = false;
  bool extracted = false;
  Map<String, dynamic> extractedData = {};

  Uint8List? droppedBytes;
  String? droppedFilename;

  bool isHovering = false; // hover state for dropzone

  final List<String> nigeriaIdTypes = [
    'National ID (NIN Slip)',
    'International Passport',
    "Driver's License",
    "Voter's Card (PVC)",
  ];

  late final html.EventListener _dropListener;
  late final html.EventListener _dragOverListener;
  late final html.EventListener _dragLeaveListener;

  @override
  void initState() {
    super.initState();

    // Register global drop listeners for web so native file drops are captured.
    // We keep these listeners simple: if the user drops files anywhere we try to handle them.
    // This is intentionally permissive for hackathon use. You can scope to a specific element later.
    if (kIsWeb) {
      _dragOverListener = (event) {
        // prevent default to allow drop
        event.preventDefault();
        setState(() => isHovering = true);
      };
      _dragLeaveListener = (event) {
        event.preventDefault();
        setState(() => isHovering = false);
      };
      _dropListener = (event) {
        event.preventDefault();
        setState(() => isHovering = false);

        final ev = event as html.MouseEvent;
        final dt = (event as dynamic).dataTransfer;
        if (dt == null) return;

        final files = dt.files;
        if (files == null || files.isEmpty) return;

        // Only take the first file for now
        final file = files[0];
        _handlePickedHtmlFile(file);
      };

      html.document.addEventListener('dragover', _dragOverListener);
      html.document.addEventListener('dragleave', _dragLeaveListener);
      html.document.addEventListener('drop', _dropListener);
    }
  }

  @override
  void dispose() {
    // remove listeners if web
    if (kIsWeb) {
      html.document.removeEventListener('dragover', _dragOverListener);
      html.document.removeEventListener('dragleave', _dragLeaveListener);
      html.document.removeEventListener('drop', _dropListener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          final double cardWidth =
              constraints.maxWidth < 700 ? constraints.maxWidth * 0.95 : 720;
          return Card(
            color: auxColor3,
            elevation: 20,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: cardWidth,
              padding: const EdgeInsets.all(28),
              child: Stack(
                children: [
                  // MAIN COLUMN
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Identity Verification",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: mainColor),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "Upload a valid Nigerian government-issued ID for verification.",
                        style: TextStyle(
                            fontSize: 16, color: mainColor.withOpacity(0.75)),
                      ),
                      const SizedBox(height: 20),

                      // ID Type dropdown — the only thing visible initially
                      DropdownButtonFormField<String>(
                        value: selectedIdType,
                        items: nigeriaIdTypes
                            .map((x) => DropdownMenuItem(
                                  value: x,
                                  child: Text(x,
                                      style:
                                          const TextStyle(color: Colors.black)),
                                ))
                            .toList(),
                        decoration: InputDecoration(
                          labelText: "Select ID Type",
                          labelStyle: const TextStyle(color: Colors.black54),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: auxColor)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueGrey)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: auxColor, width: 2)),
                          fillColor: auxColor3,
                          filled: true,
                        ),
                        dropdownColor: auxColor3,
                        onChanged: (v) {
                          setState(() {
                            selectedIdType = v;
                            // reset previous states when user changes the id type
                            uploadedFileUrl = null;
                            extracted = false;
                            droppedBytes = null;
                            droppedFilename = null;
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      // Conditionally show drop area & button only AFTER ID type is chosen
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: selectedIdType == null
                            ? const SizedBox.shrink()
                            : Column(
                                key: const ValueKey('upload-area'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Drop zone + overlay (stacked)
                                  _buildDropZoneWithOverlay(context),

                                  const SizedBox(height: 12),

                                  // Upload button (file picker) — behavior: pick then auto-upload
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: auxColor,
                                        foregroundColor: Colors.white,
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                      ),
                                      onPressed: isUploading
                                          ? null
                                          : () => _openFilePicker(),
                                      child: isUploading
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text("Uploading...")
                                              ],
                                            )
                                          : const Text("Upload ID Document"),
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 24),

                      // Extracted preview
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: extracted ? 1.0 : 0.0,
                        child: extracted
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Extracted Information",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: mainColor),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPreviewField("Full Legal Name",
                                      extractedData['name'] ?? "-"),
                                  _buildPreviewField(
                                      "Phone", extractedData['phone'] ?? "-"),
                                  _buildPreviewField("Country",
                                      extractedData['country'] ?? "-"),
                                  _buildPreviewField(
                                      "State", extractedData['state'] ?? "-"),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: mainColor,
                                        foregroundColor: Colors.white,
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                      ),
                                      onPressed: () {
                                        // TODO: Save extracted info to Firebase
                                      },
                                      child: const Text("Confirm & Save"),
                                    ),
                                  )
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),

                  // Upload overlay (frosted blur + dark tint + centered loader) when uploading
                  if (isUploading) _buildUploadingOverlay(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDropZoneWithOverlay(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isHovering ? auxColor : auxColor2,
            width: isHovering ? 3 : 2),
        color: auxColor3.withOpacity(0.9),
      ),
      child: InkWell(
        onTap: () {
          // Helpful hint: clicking the drop zone opens the file picker too.
          if (!isUploading) _openFilePicker();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Content of drop zone
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload,
                      size: 42, color: mainColor.withOpacity(0.8)),
                  const SizedBox(height: 8),
                  Text(
                    droppedFilename == null
                        ? "Drop document here (or click to choose)"
                        : "Selected: $droppedFilename",
                    style: TextStyle(
                        color: mainColor.withOpacity(0.9), fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // subtle hover highlight
            if (isHovering)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: auxColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadingOverlay() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            color: Colors.black.withOpacity(0.35),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                      strokeWidth: 4.0, color: Colors.white),
                ),
                SizedBox(height: 12),
                Text(
                  "Uploading…",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: auxColor2.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(10),
        color: auxColor3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  TextStyle(fontSize: 13, color: mainColor.withOpacity(0.6))),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --------------------------
  // File picking & handling
  // --------------------------

  Future<void> _openFilePicker() async {
    // web-only file picker using dart:html
    if (!kIsWeb) return;

    final input = html.FileUploadInputElement()
      ..accept = "*/*" // accept all - we'll filter out video files
      ..multiple = false;

    input.click();

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) return;
      final file = files[0];

      // BLOCK VIDEO FILES
      if (file.type.startsWith("video/")) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Video files are not allowed.")));
        return;
      }

      _handlePickedHtmlFile(file);
    });
  }

  Future<void> _handlePickedHtmlFile(html.File file) async {
    final reader = html.FileReader();

    reader.onLoadStart.listen((e) {
      // optional: do something when starting read
    });

    reader.onProgress.listen((event) {
      // optional: progress updates
    });

    reader.onLoadEnd.listen((event) async {
      final result = reader.result;
      if (result == null) return;

      // `result` is an ArrayBuffer - convert to Uint8List
      final bytes =
          result is Uint8List ? result : Uint8List.view((result as ByteBuffer));

      setState(() {
        droppedBytes = bytes;
        droppedFilename = file.name;
      });

      // Immediately upload on drop/pick
      await _startUploadSequence();
    });

    reader.readAsArrayBuffer(file);
  }

  Future<void> _startUploadSequence() async {
    if (droppedBytes == null || droppedFilename == null) return;

    setState(() {
      isUploading = true;
      extracted = false;
    });

    // upload to cloudinary
    final url = await uploadFileToCloudinary(droppedBytes!, droppedFilename!);

    if (url != null) {
      // simulate extraction result for now — replace with actual AI call after
      setState(() {
        uploadedFileUrl = url;
        extracted = true;
        extractedData = {
          "name": "Auto Extracted Name",
          "country": "Nigeria",
          "state": "Lagos",
          "phone": "+2348012345678",
        };
      });
    } else {
      // upload failed
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload failed. Try again.")));
    }

    setState(() {
      isUploading = false;
    });
  }
}

// --------------------------
// Cloudinary upload (raw/upload)
// --------------------------
Future<String?> uploadFileToCloudinary(Uint8List bytes, String filename) async {
  try {
    final cloudName = 'dujehbdln';
    final uploadPreset = 'videoApi_unsigned'; // update to your preset

    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files
          .add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final jsonData = jsonDecode(body);

    if (response.statusCode == 200 && jsonData['secure_url'] != null) {
      final originalUrl = jsonData['secure_url'] as String;

      // optional: compressed delivery URL (useful for images/video)
      final compressedUrl =
          originalUrl.replaceFirst('/upload/', '/upload/q_auto:eco/');

      debugPrint("✅ Cloudinary uploaded: $originalUrl");
      return compressedUrl;
    } else {
      debugPrint("❌ Cloudinary upload failed: ${response.statusCode} -> $body");
    }
  } catch (e) {
    debugPrint("🔥 upload exception: $e");
  }
  return null;
}

// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'passport_camera_view.dart';

// class CaptureScreen extends StatelessWidget {
//   const CaptureScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Take Passport Photo")),
//       body: PassportCameraView(
//         onCaptured: (Uint8List imageBytes) {
//           // Example: show captured image in a dialog
//           showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//               title: const Text("Captured Photo"),
//               content: Image.memory(imageBytes),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Close"),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

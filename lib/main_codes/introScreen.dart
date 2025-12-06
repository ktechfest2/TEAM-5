import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:aurion_hotel/_logik/Ui_bridges/splash_screen_to.dart';
import 'package:aurion_hotel/_logik/passport_camera_view.dart';
import 'package:aurion_hotel/main_codes/onboarding_screens/onboardingview.dart';
import 'package:aurion_hotel/main_codes/preference_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aurion_hotel/_components/color.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class VerificationFlowScreen extends StatefulWidget {
  const VerificationFlowScreen({super.key});

  @override
  State<VerificationFlowScreen> createState() => _VerificationFlowScreenState();
}

class _VerificationFlowScreenState extends State<VerificationFlowScreen> {
  int currentStep = 0;

  Uint8List? selfieBytes;
  String? selfieUrl;
  bool selfieUploading = false;
  bool isHovering = false; // hover state for dropzone

  Uint8List? docBytes;
  String? docUrl;
  bool docUploading = false;
  String? selectedIdType;

  Uint8List? droppedBytes;
  String? droppedFilename;

  bool extracted = false;
  Map<String, dynamic> extractedData = {};

  final List<String> nigeriaIdTypes = [
    'National ID (NIN Slip)',
    'International Passport',
    "Driver's License",
    "Voter's Card (PVC)",
  ];

  final int totalSteps = 3;

  // -----------------------
  // File picker for document
  // -----------------------

  // -----------------------
  // Stepper dots
  // -----------------------
  Widget _buildStepDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final active = index == currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 12 : 8,
          height: active ? 12 : 8,
          decoration: BoxDecoration(
            color: active ? auxColor : auxColor2.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    Widget lottie;
    switch (currentStep) {
      case 0:
        lottie = Lottie.asset('assets/animation/camera.json', height: 100);
        break;
      case 1:
        lottie = Lottie.asset('assets/animation/docs.json', height: 100);
        break;
      case 2:
        lottie = Lottie.asset('assets/animation/profile.json', height: 100);
        break;
      default:
        lottie = const SizedBox.shrink();
    }

    Widget content;
    switch (currentStep) {
      case 0:
        content = PassportCameraView(
          onCaptured: (bytes) {
            setState(() => selfieBytes = bytes);
            _uploadSelfie();
          },
          uploading: selfieUploading,
        );
        break;
      case 1:
        content = _buildDocumentStep();
        break;
      case 2:
      case 2:
        content = SingleChildScrollView(
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Details",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // ---------- Personal Info ----------
                Text(
                  "Personal Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),

                _buildFormField(
                    "Full Legal Name", extractedData['name'] ?? "-"),
                if (extractedData['dob'] != null)
                  _buildFormField("Date of Birth", extractedData['dob']),
                if (extractedData['id_type'] != null)
                  _buildFormField("ID Type", extractedData['id_type']),

                const SizedBox(height: 20),

                // ---------- Contact Info ----------
                Text(
                  "Contact Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),

                _buildFormField("Phone", extractedData['phone'] ?? "-"),
                _buildFormField("Country", extractedData['country'] ?? "-"),
                _buildFormField("State", extractedData['state'] ?? "-"),

                const SizedBox(height: 20),

                // ---------- Address ----------
                if (extractedData['address'] != null) ...[
                  Text(
                    "Address",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFormField("Address", extractedData['address']!),
                  const SizedBox(height: 20),
                ],

// ---------- Confirm Button ----------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: docUrl != null && extractedData.isNotEmpty
                        ? () async {
                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null)
                                throw Exception("User not signed in");

                              final docRef = FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(user.uid);

                              // Prepare Firestore data
                              final data = {
                                "legalName": extractedData['name'] ?? "",
                                "phone": extractedData['phone'] ?? "",
                                "idType": selectedIdType ?? "",
                                "idDocumentUrl": docUrl ?? "",
                                "verified": true,
                                "fraudScore":
                                    0, // placeholder for future AI scoring
                                "churnRisk":
                                    0.0, // placeholder for future integration
                                "country":
                                    extractedData['country'] ?? "Nigeria",
                                "state": extractedData['state'] ?? "",
                                "verifiedAt": FieldValue.serverTimestamp(),
                              };

                              // Update Firestore
                              await docRef.set(data, SetOptions(merge: true));

                              // Navigate to next page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SplashScreenTo(
                                          screen: //prefence screen
                                              PreferencesScreen(),
                                        )),
                              );
                            } catch (e) {
                              _showErrorSnackbar(
                                  "Failed to save verification: ${e.toString()}");
                            }
                          }
                        : null, // disable if no doc uploaded or no extracted data
                    style: ElevatedButton.styleFrom(
                      backgroundColor: auxColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 6,
                    ),
                    child: const Text(
                      "Confirm & Save",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        break;

      default:
        content = const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            lottie,
            _buildStepDots(),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(child: content),
      ],
    );
  }

  Widget _buildFormField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
        ],
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

  // Inside your VerificationFlowScreen, replace the document step (Step 1) content
// with this modern dropzone approach:

  Widget _buildDocumentStep() {
    return Center(
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
            height: constraints.maxHeight * 0.85,
            padding: const EdgeInsets.all(28),
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
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
                            docBytes = null;
                            docUrl = null;
                            extracted = false;
                            extractedData = {};
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: selectedIdType == null
                            ? const SizedBox.shrink()
                            : Column(
                                key: const ValueKey('upload-area'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDropZoneWithOverlay(context),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: auxColor,
                                        foregroundColor: Colors.white,
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                      ),
                                      onPressed: docUploading
                                          ? null
                                          : () => _openFilePicker(),
                                      child: docUploading
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
                    ],
                  ),
                ),
                if (docUploading) _buildUploadingOverlay(),
              ],
            ),
          ),
        );
      }),
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

  // Widget _buildDropZoneWithOverlay(BuildContext context) {
  //   return MouseRegion(
  //     onEnter: (_) => setState(() => isHovering = true),
  //     onExit: (_) => setState(() => isHovering = false),
  //     child: Builder(builder: (context) {
  //       // Only for web
  //       if (kIsWeb) {
  //         return HtmlElementView(viewType: 'drop-zone');
  //       }

  //       // For mobile/desktop fallback
  //       return _buildClickToPickZone();
  //     }),
  //   );
  // }

// Clickable fallback for mobile/desktop
  Widget _buildClickToPickZone() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isHovering ? auxColor : auxColor2,
            width: isHovering ? 3 : 2),
        color: isHovering
            ? Colors.yellow.withOpacity(0.15)
            : auxColor3.withOpacity(0.9),
      ),
      child: InkWell(
        onTap: () {
          if (!docUploading) _openFilePicker();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload,
                      size: 42, color: mainColor.withOpacity(0.8)),
                  const SizedBox(height: 8),
                  Text(
                    docBytes == null
                        ? "Drop document here (or click to choose)"
                        : "Selected: ${docUrl != null ? "Uploaded" : "Ready to upload"}",
                    style: TextStyle(
                        color: mainColor.withOpacity(0.9), fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZoneWithOverlay(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: InkWell(
        onTap: () {
          if (!docUploading) _openFilePicker();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isHovering ? auxColor : auxColor2,
                width: isHovering ? 3 : 2),
            color: isHovering
                ? Colors.yellow.withValues(alpha: 0.15)
                : auxColor3.withValues(alpha: 0.9),
          ),
          child: InkWell(
            onTap: () {
              if (!docUploading) _openFilePicker();
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload,
                          size: 42, color: mainColor.withValues(alpha: 0.8)),
                      const SizedBox(height: 8),
                      Text(
                        docBytes == null
                            ? "Drop document here (or click to choose)"
                            : "Selected: ${docUrl != null ? "Uploaded" : "Ready to upload"}",
                        style: TextStyle(
                            color: mainColor.withValues(alpha: 0.9),
                            fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openFilePicker() async {
    if (!kIsWeb) return;

    final input = html.FileUploadInputElement()
      ..accept = "*/*"
      ..multiple = false;

    input.click();

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) return;
      final file = files[0];

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

    reader.onLoadEnd.listen((event) async {
      final result = reader.result;
      if (result == null) return;

      final bytes =
          result is Uint8List ? result : Uint8List.view((result as ByteBuffer));

      setState(() {
        droppedBytes = bytes;
        droppedFilename = file.name;
      });

      await _startUploadSequence();
    });

    reader.readAsArrayBuffer(file);
  }

  Future<void> _startUploadSequence() async {
    if (droppedBytes == null || droppedFilename == null) return;

    setState(() {
      docUploading = true;
      extracted = false;
    });

    final cloudData =
        await uploadFileToCloudinary(droppedBytes!, droppedFilename!);

    if (cloudData != null) {
      final fileUrl = cloudData['url'];
      final publicId = cloudData['public_id'];

      // Call the document validation API
      final response = await http.post(
        Uri.parse(
            'https://aurion-docvalidation-api.vercel.app/api/validate_document'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "file_url": fileUrl,
          "public_id": publicId,
          "selfie_url": FirebaseAuth.instance.currentUser?.photoURL,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result["valid"] == true) {
          setState(() {
            docUrl = fileUrl;
            extracted = true;
            extractedData = {
              "name": result["name"],
              "phone": result["phone"] ?? "-",
              "country": result["country"] ?? "Nigeria",
            };
            currentStep = 2; // move to next step
          });
        } else {
          _showErrorSnackbar(
              "Document verification failed: ${result['reason']}");
        }
      } else {
        _showErrorSnackbar("Document verification API error.");
      }
    } else {
      _showErrorSnackbar("Upload failed. Try again.");
    }

    setState(() {
      docUploading = false;
    });
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
              height: constraints.maxHeight * 0.85,
              padding: const EdgeInsets.all(28),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _buildStepContent(),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _uploadSelfie() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (selfieBytes == null) return;

    setState(() => selfieUploading = true);

    try {
      // Generate unique public_id
      final publicId = "selfie_${DateTime.now().millisecondsSinceEpoch}.png";

      // Upload selfie to Cloudinary
      final cloudData =
          await uploadImageToCloudinaryWeb(selfieBytes!, publicId);

      if (cloudData == null) {
        throw Exception("Image upload failed.");
      }

      final cloudUrl = cloudData['url'];
      final cloudPublicId = cloudData['public_id'];

      // Call FastAPI validation
      final response = await http.post(
        Uri.parse(
            'https://aurion-image-validation-api.vercel.app/api/validate_selfie'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "image_url": cloudUrl,
          "public_id": cloudPublicId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Image validation failed. Try again.");
      }

      final result = jsonDecode(response.body);

      if (result["valid"] == true) {
        // Selfie is valid
        setState(() {
          selfieUrl = cloudUrl;
          currentStep = 1;

          // Update Firestore
          if (uid != null) {
            FirebaseFirestore.instance.collection("users").doc(uid).set({
              "photourl": selfieUrl,
            }, SetOptions(merge: true));
          }
        });
      } else {
        // Selfie invalid, backend auto-deletes
        setState(() {
          selfieBytes = null;
          selfieUrl = null;
        });

        final reason = result['reason'] ?? "Unknown reason";
        final cloudMsg = result['cloudinary_delete']?['message'] ?? "";
        print(
            "Selfie validation failed: $reason. Cloudinary delete response: $cloudMsg");
        //show user reason of failure in just a sentence. first sentence;;;
        _showErrorSnackbar("Selfie verification failed: $reason");
        // _showErrorSnackbar("Selfie verification failed: $reason");
      }
    } catch (e) {
      debugPrint("Selfie upload error: $e"); //digital comprehensi
      _showErrorSnackbar("An unexpected error occurred. Please try again.");
      setState(() {
        selfieBytes = null;
        selfieUrl = null;
      });
    } finally {
      setState(() => selfieUploading = false);
    }
  }

  Future<Map<String, dynamic>?> uploadImageToCloudinaryWeb(
      Uint8List bytes, String publicId) async {
    try {
      final cloudName = 'dujehbdln';
      final uploadPreset = 'videoApi_unsigned';

      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = publicId
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: publicId,
        ));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final jsonData = jsonDecode(body);

      if (response.statusCode == 200 && jsonData['secure_url'] != null) {
        return {
          "url": jsonData['secure_url'],
          "public_id": jsonData['public_id'],
        };
      }
    } catch (e) {
      debugPrint("Cloudinary upload error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> uploadFileToCloudinary(
      Uint8List bytes, String filename) async {
    try {
      final cloudName = 'dujehbdln';
      final uploadPreset = 'videoApi_unsigned';

      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: filename));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final jsonData = jsonDecode(body);

      if (response.statusCode == 200 && jsonData['secure_url'] != null) {
        return {
          "url": jsonData['secure_url'],
          "public_id": jsonData['public_id'],
        };
      }
    } catch (e) {
      debugPrint("Cloudinary upload error: $e");
    }
    return null;
  }
}

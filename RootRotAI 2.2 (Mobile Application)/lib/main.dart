import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'RootRotAI',
    home: HomePage(),
  ));
}

// ==========================================
// 1. AESTHETIC HOME PAGE
// ==========================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.teal),
              SizedBox(width: 10),
              Text("About RootRotAI 2.2"),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              "RootRotAI2.2\n\n"
              "A Deep Learning-based tool for the rapid detection of Dry Root Rot "
              "(Rhizoctonia bataticola) in chickpeas.\n\n"
              "• Architecture: Vision Transformer (ViT)\n"
              "• Modalities: Microscope, Scanner, Camera\n"
              "• Inference: On-device TFLite\n\n"
              "Developed for agricultural research.",
              style: TextStyle(height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close", style: TextStyle(color: Colors.teal)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: Colors.teal),
              SizedBox(width: 10),
              Text("User Guide"),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              "1. Tap 'Start Diagnosis' to enter the workspace.\n"
              "2. Tap 'View Samples' to see reference images.\n"
              "3. Select your input device (Camera/Scanner/Microscope).\n"
              "4. Use 'Camera' for single shots or 'Pick Files' for batch upload.\n"
              "5. View Severity Scores instantly and Download CSV.",
              style: TextStyle(height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Got it", style: TextStyle(color: Colors.teal)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.description_outlined,
                      color: Colors.white),
                  iconSize: 32,
                  tooltip: 'Terms & Conditions',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TermsPage()),
                    );
                  },
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const Icon(Icons.contact_phone_outlined,
                      color: Colors.white),
                  iconSize: 32,
                  tooltip: 'Contact Us',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ContactPage()),
                    );
                  },
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                  iconSize: 32,
                  onPressed: () => _showHelpDialog(context),
                  tooltip: 'Help',
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  iconSize: 32,
                  onPressed: () => _showInfoDialog(context),
                  tooltip: 'About',
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/field_background.png",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.teal.shade900);
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(0, 0, 0, 0).withAlpha(35),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 190),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double screenWidth = MediaQuery.of(context).size.width;
                        double mainTitleSize = screenWidth < 360 ? 40 : 54;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "RootRotAI 2.2",
                              style: TextStyle(
                                fontSize: mainTitleSize,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3.0,
                                color: Colors.white,
                                shadows: const <Shadow>[
                                  Shadow(
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 120.0,
                                    color: Color.fromARGB(255, 50, 49, 49),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double screenWidth = MediaQuery.of(context).size.width;
                        double titleSize = screenWidth < 360 ? 24 : 34;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Root Rot Assessment Interface",
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: Colors.white70,
                                shadows: const <Shadow>[
                                  Shadow(
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 120.0,
                                    color: Color.fromARGB(255, 50, 49, 49),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double screenWidth = MediaQuery.of(context).size.width;
                        double subtitleSize = screenWidth < 360 ? 14 : 18;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "ML-Powered DRR Detection and Assessment",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: subtitleSize,
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontStyle: FontStyle.italic,
                                shadows: const <Shadow>[
                                  Shadow(
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 80.0,
                                    color: Color.fromARGB(255, 50, 49, 49),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                    SizedBox(
                      width: 240,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DiagnosisPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          elevation: 10,
                          shadowColor: Colors.black45,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                            side: const BorderSide(
                                color: Colors.white30, width: 1),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.analytics_outlined, size: 28),
                            SizedBox(width: 12),
                            Text(
                              "Start Diagnosis",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 75,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/bric_nipgr_logo.png",
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Column(
                      children: [
                        Icon(Icons.account_balance,
                            color: Colors.white54, size: 40),
                        Text("NIPGR",
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = MediaQuery.of(context).size.width;
                    double bottomSize = screenWidth < 360 ? 10 : 12;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "BRIC - National Institute of Plant Genome Research",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: bottomSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. OPTIMIZED DIAGNOSIS WORKSPACE WITH GATEKEEPER
// ==========================================
enum AppMode { camera, scanner, microscope }

// ✅ Lightweight gatekeeper result
class GatekeeperResult {
  final bool isPlant;
  final double confidence;

  GatekeeperResult(this.isPlant, this.confidence);
}

class AnalysisResult {
  final String imageName;
  final String status;
  final double confidence;
  final int severityScore;
  final bool isPlant;
  final double plantConfidence;

  AnalysisResult(
    this.imageName,
    this.status,
    this.confidence,
    this.severityScore, {
    this.isPlant = true,
    this.plantConfidence = 1.0,
  });
}

class DiagnosisPage extends StatefulWidget {
  const DiagnosisPage({super.key});

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  AppMode _selectedMode = AppMode.camera;

  // ✅ Two interpreters
  Interpreter? _gatekeeperInterpreter;
  Interpreter? _diseaseInterpreter;

  final ImagePicker _cameraPicker = ImagePicker();

  bool _isProcessing = false;
  int _currentIndex = 0;
  int _totalImages = 0;
  String _statusMessage = "Select a mode and pick images.";
  List<AnalysisResult> _results = [];

  final double _gatekeeperThreshold = 0.7;
  File? _lastConvertedFile; // ✅ Track temp files

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  @override
  void dispose() {
    _gatekeeperInterpreter?.close();
    _diseaseInterpreter?.close();
    _cleanupTempFile(); // ✅ Clean temp files
    super.dispose();
  }

  // ✅ Cleanup temp files
  Future<void> _cleanupTempFile() async {
    if (_lastConvertedFile != null && await _lastConvertedFile!.exists()) {
      try {
        await _lastConvertedFile!.delete();
        _lastConvertedFile = null;
      } catch (e) {
        debugPrint("Failed to delete temp file: $e");
      }
    }
  }

  // ✅ Load both models
  Future<void> _loadModels() async {
    try {
      _gatekeeperInterpreter =
          await Interpreter.fromAsset('assets/plant_non_classifier.tflite');
      await _loadDiseaseModel(_selectedMode);
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = "Error loading models: $e");
      }
    }
  }

  Future<void> _loadDiseaseModel(AppMode mode) async {
    _diseaseInterpreter?.close();

    String modelFile;
    if (mode == AppMode.microscope) {
      modelFile = 'assets/pure_model_A3.tflite';
    } else {
      modelFile = 'assets/pure_multitask_model.tflite';
    }

    try {
      _diseaseInterpreter = await Interpreter.fromAsset(modelFile);
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = "Error loading disease model: $e");
      }
    }
  }

  void _showSampleImages(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 500,
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "Reference Standards",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                  ),
                  const TabBar(
                    labelColor: Colors.teal,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.teal,
                    tabs: [
                      Tab(icon: Icon(Icons.camera_alt), text: "Camera"),
                      Tab(icon: Icon(Icons.scanner), text: "Scanner"),
                      Tab(icon: Icon(Icons.science), text: "Microscope"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildSampleView(
                            "Camera",
                            "assets/samples/camera_healthy.png",
                            "assets/samples/camera_drr.png"),
                        _buildSampleView(
                            "Scanner",
                            "assets/samples/scanner_healthy.png",
                            "assets/samples/scanner_drr.png"),
                        _buildSampleView(
                            "Microscope",
                            "assets/samples/microscope_healthy.png",
                            "assets/samples/microscope_drr.png"),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close",
                        style: TextStyle(color: Colors.teal)),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSampleView(String mode, String healthyPath, String drrPath) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 3),
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                image: AssetImage(healthyPath),
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const Text("HEALTHY",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 3),
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                image: AssetImage(drrPath), fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const Text("DRR (DISEASED)",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Typical appearance in $mode mode.",
            style: const TextStyle(
                fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _captureFromCamera() async {
    try {
      final XFile? photo = await _cameraPicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (photo == null) return;

      setState(() {
        _isProcessing = true;
        _totalImages = 1;
        _currentIndex = 1;
        _statusMessage = "Analyzing Camera Capture...";
      });

      await Future.delayed(const Duration(milliseconds: 100));

      var analysis = await _runFullPipeline(File(photo.path), "Camera_Capture");

      if (mounted) {
        setState(() {
          _results.add(analysis);
          _isProcessing = false;
          _statusMessage = "Diagnosis Complete.";
        });
      }
    } catch (e) {
      debugPrint("Camera error: $e");
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = "Camera capture failed: $e";
        });
      }
    }
  }

  // ✅ OPTIMIZED: Don't resize during conversion
  Future<File> _ensurePngFormat(File imageFile, String originalName) async {
    String extension = path.extension(imageFile.path).toLowerCase();

    if (extension == '.png' || extension == '.jpg' || extension == '.jpeg') {
      return imageFile;
    }

    try {
      var bytes = await imageFile.readAsBytes();
      var image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image format: $extension');
      }

      // ✅ Don't resize - let processing function handle it
      var pngBytes = img.encodePng(image);

      Directory tempDir = await getTemporaryDirectory();
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String tempPath = '${tempDir.path}/converted_$timestamp.png';

      File pngFile = File(tempPath);
      await pngFile.writeAsBytes(pngBytes);

      return pngFile;
    } catch (e) {
      debugPrint('Conversion error for $originalName: $e');
      throw Exception('Could not convert $originalName to PNG: $e');
    }
  }

  // ✅ OPTIMIZED: Batch processing
  Future<void> _pickAndAnalyzeBatch() async {
    if (_gatekeeperInterpreter == null || _diseaseInterpreter == null) {
      _showSnackBar("Models not loaded. Please wait.", Colors.orange);
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _results.clear();
      _totalImages = result.files.length;
      _currentIndex = 0;
      _statusMessage = "Starting analysis...";
    });

    await Future.delayed(const Duration(milliseconds: 100));

    List<AnalysisResult> tempResults = [];
    int rejectedCount = 0;

    for (var file in result.files) {
      if (file.path == null) continue;

      if (mounted) {
        setState(() {
          _currentIndex++;
        });
      }

      // ✅ Minimal delay
      await Future.delayed(const Duration(milliseconds: 5));

      try {
        File originalFile = File(file.path!);

        await _cleanupTempFile();

        File pngFile = await _ensurePngFormat(originalFile, file.name);
        _lastConvertedFile = pngFile;

        var analysis = await _runFullPipeline(pngFile, file.name);
        tempResults.add(analysis);

        if (!analysis.isPlant) rejectedCount++;

        // ✅ Update UI every 5 images
        if (mounted &&
            (_currentIndex % 5 == 0 || _currentIndex == _totalImages)) {
          setState(() {
            _results = List.from(tempResults);
            _statusMessage =
                "Processed $_currentIndex/$_totalImages (Rejected: $rejectedCount)";
          });
        }
      } catch (e) {
        debugPrint("Error processing ${file.name}: $e");
        tempResults.add(AnalysisResult(
          file.name,
          "ERROR",
          0.0,
          0,
          isPlant: false,
          plantConfidence: 0.0,
        ));
      }
    }

    if (mounted) {
      setState(() {
        _results = List.from(tempResults);
        _isProcessing = false;
        _statusMessage =
            "Completed: ${_totalImages - rejectedCount} plants, $rejectedCount rejected";
      });
    }

    await _cleanupTempFile();
  }

  // ✅ FIXED: Single read for both models
  Future<AnalysisResult> _runFullPipeline(File imageFile, String name) async {
    try {
      // ✅ Process BOTH sizes in ONE call
      var processedData =
          await compute(processImageForBothModels, imageFile.path);

      // STEP 1: Gatekeeper
      var input224 = processedData.gatekeeperInput.reshape([1, 224, 224, 3]);

      // ✅ FIX: Output shape is [1, 1], NOT [1, 2]!
      var output = List.filled(1 * 1, 0.0).reshape([1, 1]);
      _gatekeeperInterpreter!.run(input224, output);

      // ✅ FIX: Get the single probability value
      var probPlant = output[0][0];

      debugPrint("Gatekeeper output for $name: $probPlant");

      bool isPlant = probPlant > _gatekeeperThreshold;

      if (!isPlant) {
        return AnalysisResult(
          name,
          "Invalid",
          1.0 - probPlant,
          0,
          isPlant: false,
          plantConfidence: probPlant,
        );
      }

      // STEP 2: Disease detection (already have 288x288!)
      var input288 = processedData.diseaseInput.reshape([1, 288, 288, 3]);

      var output0 = List.filled(1 * 2, 0.0).reshape([1, 2]);
      var output1 = List.filled(1 * 1, 0.0).reshape([1, 1]);
      var outputs = {0: output0, 1: output1};

      _diseaseInterpreter!.runForMultipleInputs([input288], outputs);

      var probList = output0[0];
      var rawScore = output1[0][0];

      if (output0[0].length == 1) {
        probList = output1[0];
        rawScore = output0[0][0];
      }

      var probDRR = probList[1];
      String status = probDRR > 0.5 ? "DRR DETECTED" : "HEALTHY";
      int roundedScore =
          (status == "HEALTHY") ? 0 : rawScore.round().clamp(1, 5);

      return AnalysisResult(
        name,
        status,
        probDRR,
        roundedScore,
        isPlant: true,
        plantConfidence: probPlant,
      );
    } catch (e) {
      debugPrint("Pipeline error for $name: $e");
      return AnalysisResult(
        name,
        "ERROR",
        0.0,
        0,
        isPlant: false,
        plantConfidence: 0.0,
      );
    }
  }

  Future<void> _saveToDownloads() async {
    if (_results.isEmpty) return;

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (await Permission.manageExternalStorage.status.isDenied) {
      await Permission.manageExternalStorage.request();
    }

    try {
      List<List<dynamic>> rows = [];
      rows.add([
        "Image Name",
        "Plant Check",
        "Plant Confidence",
        "Prediction",
        "Probability of DRR",
        "Severity Score"
      ]);

      for (var res in _results) {
        rows.add([
          res.imageName,
          res.isPlant ? "Valid" : "Invalid ",
          "${(res.plantConfidence * 100).toStringAsFixed(1)}%",
          res.status,
          "${(res.confidence * 100).toStringAsFixed(1)}%",
          res.severityScore
        ]);
      }
      String csvData = const ListToCsvConverter().convert(rows);

      String downloadPath =
          await ExternalPath.getExternalStoragePublicDirectory("Download");
      String fileName =
          "DRR_Result_${DateTime.now().millisecondsSinceEpoch}.csv";
      File file = File("$downloadPath/$fileName");

      await file.writeAsString(csvData);

      _showSnackBar("✅ Saved to Downloads/$fileName", Colors.green);
    } catch (e) {
      _showSnackBar("❌ Error: $e", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Color _getModeColor(AppMode mode) {
    switch (mode) {
      case AppMode.camera:
        return Colors.red.shade100;
      case AppMode.scanner:
        return Colors.blue.shade100;
      case AppMode.microscope:
        return Colors.white;
    }
  }

  String _getModeDescription(AppMode mode) {
    switch (mode) {
      case AppMode.camera:
        return "RED Background Required";
      case AppMode.scanner:
        return "BLUE Background Required";
      case AppMode.microscope:
        return "WHITE Background Required";
    }
  }

  String _getSampleImage(AppMode mode) {
    switch (mode) {
      case AppMode.camera:
        return 'assets/sample_camera.png';
      case AppMode.scanner:
        return 'assets/sample_scanner.png';
      case AppMode.microscope:
        return 'assets/sample_microscope.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diagnosis Workspace"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showSampleImages(context),
                        icon: const Icon(Icons.collections, size: 18),
                        label: const Text("View Reference Images"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal.shade700,
                          side: BorderSide(color: Colors.teal.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<AppMode>(
                      value: _selectedMode,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                            value: AppMode.camera,
                            child: Text("📷 Camera Mode")),
                        DropdownMenuItem(
                            value: AppMode.scanner,
                            child: Text("📠 Scanner Mode")),
                        DropdownMenuItem(
                            value: AppMode.microscope,
                            child: Text("🔬 Microscope Mode (A3)")),
                      ],
                      onChanged: (AppMode? newMode) {
                        if (newMode != null) {
                          setState(() => _selectedMode = newMode);
                          _loadDiseaseModel(newMode);
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getModeColor(_selectedMode),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image:
                                    AssetImage(_getSampleImage(_selectedMode)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "REQUIREMENTS:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "1. ${_getModeDescription(_selectedMode)}",
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (_isProcessing ||
                                    _selectedMode != AppMode.camera)
                                ? null
                                : _captureFromCamera,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Camera",
                                maxLines: 1, style: TextStyle(fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 4),
                              backgroundColor: Colors.orange.shade800,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _isProcessing ? null : _pickAndAnalyzeBatch,
                            icon: const Icon(Icons.folder_open),
                            label: const Text("Pick Files",
                                maxLines: 1, style: TextStyle(fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 4),
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _results.isEmpty ? null : _saveToDownloads,
                            icon: const Icon(Icons.download),
                            label: const Text("CSV",
                                maxLines: 1, style: TextStyle(fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(_statusMessage,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: _results.isEmpty
                    ? const Center(child: Text("No results yet."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final res = _results[index];

                          if (!res.isPlant) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: Colors.grey.shade200,
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.image,
                                            size: 18, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            res.imageName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Divider(height: 1),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.block,
                                            color: Colors.orange, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Invalid Image ",
                                            style: const TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: res.status.contains("DRR")
                                ? Colors.red.shade50
                                : Colors.white,
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.image,
                                          size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          res.imageName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            Icon(
                                              res.status.contains("DRR")
                                                  ? Icons.warning_amber_rounded
                                                  : Icons.check_circle_outline,
                                              color: res.status.contains("DRR")
                                                  ? Colors.red
                                                  : Colors.green,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                res.status,
                                                style: TextStyle(
                                                  color:
                                                      res.status.contains("DRR")
                                                          ? Colors.red
                                                          : Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: res.severityScore == 0
                                              ? Colors.green.shade100
                                              : Colors.orange.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: res.severityScore == 0
                                                ? Colors.green.shade300
                                                : Colors.orange.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              "Severity: ",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              res.severityScore.toString(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: res.severityScore == 0
                                                    ? Colors.green.shade800
                                                    : Colors.orange.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withAlpha(150),
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.teal),
                        const SizedBox(height: 20),
                        const Text("Processing...",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text("Image $_currentIndex of $_totalImages",
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. TERMS & CONDITIONS PAGE
// ==========================================
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("TERMS AND CONDITIONS",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Last Updated: January 20, 2026",
                style:
                    TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            Divider(height: 30, thickness: 2),
            _SectionHeader("1. Introduction"),
            _SectionText(
              "Welcome to the RootRotAI. This Application is developed as part of a research initiative at the National Institute of Plant Genome Research (NIPGR), New Delhi.\n\n"
              "By using this App, you agree to these Terms. If you do not agree, please do not use the Application.",
            ),
            _SectionHeader("2. Nature of Application"),
            _SectionText(
              "This App is a research prototype provided for educational and experimental purposes only.\n\n"
              "• Not a Commercial Product.\n"
              "• Not Professional Advice: Results should not be used as the sole basis for crop management decisions (e.g., fungicide use).",
            ),
            _SectionHeader("3. Limitations"),
            _SectionText(
              "Predictions are probabilistic and subject to error. Accuracy depends on image quality and lighting.\n\n"
              "Performance Metrics (Testing Dataset):\n"
              "• Camera Mode: Acc: 94% | RMSE: 0.87\n"
              "• Scanner Mode: Acc: 85% | RMSE: 1.49\n"
              "• Microscope Mode: Acc: 93% | RMSE: 1.21",
            ),
            _SectionHeader("4. Data Privacy"),
            _SectionText(
              "• On-Device Inference: All processing happens on your phone.\n"
              "• No Cloud Uploads: Your images never leave your device.\n"
              "• Local Storage: You control your CSV data.",
            ),
            _SectionHeader("5. Intellectual Property"),
            _SectionText(
              "All rights, source code, and AI models belong to the National Institute of Plant Genome Research (NIPGR). Commercial use without permission is prohibited.",
            ),
            _SectionHeader("6. Limitation of Liability"),
            _SectionText(
              "NIPGR, the developers, and contributors are NOT liable for any crop failure, financial loss, or damages resulting from the use of this App. The App is provided 'AS IS' without warranties.",
            ),
            _SectionHeader("7. Contact Information"),
            _SectionText(
              "Name: Dr. Senthil-Kumar Muthappa\n"
              "Email: skmuthappa@nipgr.ac.in\n"
              "Institute: NIPGR, New Delhi",
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. CONTACT PAGE
// ==========================================
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.teal.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                "assets/image_16.png",
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person, size: 80, color: Colors.teal);
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "RootRotAI Team",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            const SizedBox(height: 40),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    const Text(
                      "Dr. Senthil-Kumar Muthappa",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    const Text("Staff Scientist",
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const Divider(height: 30, thickness: 1.5),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: Colors.teal),
                        SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            "National Institute of Plant Genome Research\n"
                            "Aruna Asaf Ali Marg, P.O. Box No. 10531\n"
                            "New Delhi - 110 067",
                            style: TextStyle(fontSize: 15, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    InkWell(
                      onTap: () => _launchUrl(
                          "http://nipgr.ac.in/research/dr_skmuthappa.php"),
                      child: Row(
                        children: [
                          const Icon(Icons.language, color: Colors.teal),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              "Visit Research Profile",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.teal.shade700,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(Icons.open_in_new,
                              size: 18, color: Colors.teal),
                        ],
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

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
    );
  }
}

// ==========================================
// ✅ OPTIMIZED IMAGE PROCESSING
// ==========================================

// ✅ Data class for both processed images
class ImageProcessingData {
  final Float32List gatekeeperInput;
  final Float32List diseaseInput;

  ImageProcessingData(this.gatekeeperInput, this.diseaseInput);
}

// ✅ FIXED: Process BOTH sizes WITHOUT normalization (model does it internally)
ImageProcessingData processImageForBothModels(String path) {
  final imageFile = File(path);
  final bytes = imageFile.readAsBytesSync();
  final decodedImage = img.decodeImage(bytes);

  if (decodedImage == null) throw Exception("Unable to decode image");

  // Resize to 224x224 for gatekeeper
  final resized224 = img.copyResize(decodedImage, width: 224, height: 224);
  var floatList224 = Float32List(224 * 224 * 3);
  int pixelIndex = 0;

  for (var y = 0; y < 224; y++) {
    for (var x = 0; x < 224; x++) {
      var pixel = resized224.getPixel(x, y);
      // ✅ FIX: NO normalization! Just raw pixel values [0-255]
      // The TFLite model has Rescaling layer built-in
      floatList224[pixelIndex++] = pixel.r.toDouble();
      floatList224[pixelIndex++] = pixel.g.toDouble();
      floatList224[pixelIndex++] = pixel.b.toDouble();
    }
  }

  // Resize to 288x288 for disease model
  final resized288 = img.copyResize(decodedImage, width: 288, height: 288);
  var floatList288 = Float32List(288 * 288 * 3);
  pixelIndex = 0;

  for (var y = 0; y < 288; y++) {
    for (var x = 0; x < 288; x++) {
      var pixel = resized288.getPixel(x, y);
      // ✅ Same for disease model - check if it also has Rescaling layer
      floatList288[pixelIndex++] = pixel.r.toDouble();
      floatList288[pixelIndex++] = pixel.g.toDouble();
      floatList288[pixelIndex++] = pixel.b.toDouble();
    }
  }

  return ImageProcessingData(floatList224, floatList288);
}

// ✅ Backward compatibility function
Float32List heavyImageProcessing(String path) {
  final imageFile = File(path);
  final bytes = imageFile.readAsBytesSync();
  final decodedImage = img.decodeImage(bytes);

  if (decodedImage == null) throw Exception("Unable to decode image");

  final resized = img.copyResize(decodedImage, width: 288, height: 288);

  var floatList = Float32List(288 * 288 * 3);
  int pixelIndex = 0;

  for (var y = 0; y < 288; y++) {
    for (var x = 0; x < 288; x++) {
      var pixel = resized.getPixel(x, y);
      // ✅ NO normalization
      floatList[pixelIndex++] = pixel.r.toDouble();
      floatList[pixelIndex++] = pixel.g.toDouble();
      floatList[pixelIndex++] = pixel.b.toDouble();
    }
  }
  return floatList;
}
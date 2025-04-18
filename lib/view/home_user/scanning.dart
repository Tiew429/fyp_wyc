import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/utils/my_button.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ScanningPage extends StatefulWidget {
  final XFile image;

  const ScanningPage({
    super.key,
    required this.image,
  });

  @override
  State<ScanningPage> createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage> {
  late XFile _image;
  late final Interpreter _interpreter;
  late final List<String> _labels;
  List<Map<String, dynamic>> predictions = [];
  List<String> selectedIngredients = [];
  bool isScanning = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _image = widget.image;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scanImage();
    });
  }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/model/model.tflite');
  }

  Future<void> _loadLabels() async {
    final labelsData = await rootBundle.loadString('assets/model/labels.txt');
    _labels = labelsData.split('\n');
  }

  Future<void> _scanAgain(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _image = image;
      });
      _scanImage();
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        maxHeight: 120, // Height for exactly two ListTiles
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min, // Use minimum space needed
        children: [
          ListTile(
            title: Text('Take Photo'),
            onTap: () async => await _scanAgain(ImageSource.camera),
          ),
          Divider(height: 1, thickness: 1),
          ListTile(
            title: Text('Pick Image'),
            onTap: () async => await _scanAgain(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Future<void> _scanImage() async {
    setState(() {
      isScanning = true;
    });

    // 1. load model
    _loadModel();

    // 2. load labels
    _loadLabels();

    // 3. load & decode image
    final imageBytes = await _image.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);
    
    if (decodedImage == null) {
      throw Exception('Failed to decode image');
    }

    // 4. resize to model input
    final inputShape = _interpreter.getInputTensor(0).shape;
    final inputH = inputShape[1];
    final inputW = inputShape[2];
    final resizedImage = img.copyResize(
      decodedImage,
      width: inputW,
      height: inputH,
      interpolation: img.Interpolation.cubic,
    );

    // 5. preprocess image
    final inputBuffer = Float32List(1 * inputH * inputW * 3);
    int pixelIndex = 0;

    // ImageNet standard normalization parameters
    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];

    for (int y = 0; y < inputH; y++) {
      for (int x = 0; x < inputW; x++) {
        final pixel = resizedImage.getPixel(x, y);

        // Convert to BGR order and normalize
        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;

        // Apply normalization (value - mean) / std
        inputBuffer[pixelIndex++] = (b - mean[2]) / std[2]; // B channel
        inputBuffer[pixelIndex++] = (g - mean[1]) / std[1]; // G channel
        inputBuffer[pixelIndex++] = (r - mean[0]) / std[0]; // R channel
      }
    }

    // 6. Prepare output
    final outputShape = _interpreter.getOutputTensor(0).shape;
    final outputSize = outputShape[outputShape.length - 1];
    final outputBuffer = Float32List(outputSize);

    // 7. Run inference
    _interpreter.run(inputBuffer.buffer, outputBuffer.buffer);

    // 8. Process results
    final results = outputBuffer.toList();
    final indexedResults = results.asMap().entries.toList();
    indexedResults.sort((a, b) => b.value.compareTo(a.value));

    // 9. Get predictions (ingredients that are in the image have more than 10% confidence)
    final newPredictions = indexedResults.where((entry) {
      final confidence = entry.value;
      return confidence > 0.1;
    }).map((entry) {
      final idx = entry.key;
      final confidence = entry.value;
      return {
        'label': _labels[idx],
        'confidence': confidence,
      };
    }).toList();

    // 10. Update UI with merged predictions (avoiding duplicates)
    setState(() {
      // Merge predictions without duplicates
      for (var newPred in newPredictions) {
        if (!predictions.any((pred) => pred['label'] == newPred['label'])) {
          predictions.add(newPred);
        }
      }
      isScanning = false;
    });
  }

  Future<void> _onContinue() async {
    navigatorKey.currentContext!.push(
      '/${ViewData.scanResult.path}',
      extra: selectedIngredients,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Scanning'),
        bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey[300],
          height: 1.0,
        ),
      ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text('Ingredient Recognition',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Constrain image size to prevent overflow
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4, // Limit height to 40% of screen
                  ),
                  child: Image.file(
                    File(_image.path),
                    fit: BoxFit.contain, // Maintain aspect ratio
                  ),
                ),
              ),
              const SizedBox(height: 20),
              isScanning ? _buildScanningProgress() : _buildScanningResult(),
              const SizedBox(height: 20), // Add bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanningProgress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Scanning...'),
        const SizedBox(height: 20),
        const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildScanningResult() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch, // Fill available width
        children: [
          const Text('Scanning Result',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text('Please select the ingredients you see in the image',
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            height: 200, // Fixed height with scrolling
            child: predictions.isEmpty 
              ? Center(child: Text('No ingredients detected'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = predictions[index];
                    final label = prediction['label'] as String;
                    return CheckboxListTile(
                      dense: true, // Make the list tiles more compact
                      title: Text(label),
                      value: selectedIngredients.contains(label),
                      activeColor: Color.fromARGB(255, 26, 218, 128),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedIngredients.add(label);
                          } else {
                            selectedIngredients.remove(label);
                          }
                        });
                      },
                    );
                  },
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MyButton(
                onPressed: _showImageSourceOptions,
                text: 'Scan Again',
                backgroundColor: Colors.blue,
                width: MediaQuery.of(context).size.width * 0.4,
              ),
              MyButton(
                onPressed: selectedIngredients.isEmpty ? () {} : _onContinue, // Disable if no selections
                text: 'Continue',
                width: MediaQuery.of(context).size.width * 0.4,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

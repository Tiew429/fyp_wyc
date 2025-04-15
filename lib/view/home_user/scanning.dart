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
  late final XFile _image;
  late final Interpreter _interpreter;
  late final List<String> _labels;
  List<Map<String, dynamic>> predictions = [];
  List<String> selectedIngredients = [];
  bool isScanning = false;

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

    // 9. Get predictions (ingredients that are in the image have more than 20% confidence)
    final topPredictions = indexedResults.where((entry) {
      // final idx = entry.key;
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

    // 10. Update UI
    setState(() {
      predictions = topPredictions;
    });
    
    setState(() {
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
      body: Center(
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
            Image.file(File(_image.path)),
            const SizedBox(height: 20),
            isScanning ? _buildScanningProgress() : _buildScanningResult(),
          ],
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
        children: [
          const Text('Scanning Result',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              child: Column(
                children: predictions.map((prediction) {
                  final label = prediction['label'] as String;
                  return CheckboxListTile(
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
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          MyButton(
            onPressed: _onContinue,
            text: 'Continue with Selected Ingredients',
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/functions/image_functions.dart';
import 'package:fyp_wyc/main.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _image;

  Future<void> _takePhoto() async {
    final image = await ImageFunctions.takePhoto(_imagePicker);
    setState(() {
      _image = image;
    });
    if (_image != null) {
      navigatorKey.currentContext!.push(
        '/${ViewData.scanning.path}',
        extra: {
          'image': _image,
        },
      );
    }
  }

  Future<void> _pickImage() async {
    final image = await ImageFunctions.pickImage(_imagePicker);
    setState(() {
      _image = image;
    });
    if (_image != null) {
      navigatorKey.currentContext!.push(
        '/${ViewData.scanning.path}',
        extra: {
          'image': _image,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan your Ingredients',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildSelectionButton(
                'Generate Recipe from Photo',
                () => _takePhoto(),
                Icons.camera_alt_outlined,
              ),
              SizedBox(height: 30),
              _buildSelectionButton(
                'Select Photo from Gallery',
                () => _pickImage(),
                Icons.image_outlined,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionButton(String text, VoidCallback onPressed, IconData icon) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 173, 216, 230),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32),
              SizedBox(width: 10),
              Text(text,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
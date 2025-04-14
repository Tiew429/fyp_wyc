import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/functions/image_functions.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/utils/my_button.dart';
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyButton(
            onPressed: () => _takePhoto(),
            text: 'Capture Image',
          ),
          SizedBox(height: 10),
          MyButton(
            onPressed: () => _pickImage(),
            text: 'Upload Image',
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageFunctions {
  static Future<XFile?> pickImage(ImagePicker imagePicker) async {
    return await imagePicker.pickImage(source: ImageSource.gallery);
  }

  static Future<XFile?> takePhoto(ImagePicker imagePicker) async {
    return await imagePicker.pickImage(source: ImageSource.camera);
  }

  static Future<XFile?> cropImage(XFile? image) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: image!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Color(0xFF00BFA6),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
      ],
    );
    if (croppedImage != null) {
      return XFile(croppedImage.path);
    } else {
      return XFile(image.path);
    }
  }

  static Image getAvatarInFuture(String url) {
    return Image.network(url,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.person, color: Colors.grey[800]);
      },
    );
  }
}

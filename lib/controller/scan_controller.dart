import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ScanController {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  Future<File?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) return File(image.path);
    return null;
  }

  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) return File(image.path);
    return null;
  }
}

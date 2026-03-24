import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'design_constants.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (image == null) return null;
      final File file = File(image.path);
      if (!await file.exists() || image.path.isEmpty) return null;
      return file;
    } catch (e, st) {
      debugPrint('ImageHelper.pickImage: $e\n$st');
      return null;
    }
  }

  static Future<File?> cropImage(File imageFile) async {
    File? tempFile;
    try {
      if (!await imageFile.exists() || imageFile.path.isEmpty) return null;

      String fileExtension = path.extension(imageFile.path);
      if (fileExtension.isEmpty) fileExtension = '.jpg';

      final Directory tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String cleanFileName = 'crop_$timestamp$fileExtension';
      final String tempPath = path.join(tempDir.path, cleanFileName);
      tempFile = await imageFile.copy(tempPath);
      if (!await tempFile.exists()) return null;
      final fileSize = await tempFile.length();
      if (fileSize == 0) return null;

      await Future<void>.delayed(const Duration(milliseconds: 200));

      CroppedFile? croppedFile;
      try {
        croppedFile = await ImageCropper().cropImage(
          sourcePath: tempFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Product Image',
              toolbarColor: AppColors.primary,
              toolbarWidgetColor: AppColors.secondary,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              backgroundColor: Colors.black,
              activeControlsWidgetColor: AppColors.primary,
              dimmedLayerColor: Colors.black.withValues(alpha: 0.8),
              cropFrameColor: Colors.white,
              cropGridColor: Colors.white.withValues(alpha: 0.5),
              cropFrameStrokeWidth: 2,
              cropGridStrokeWidth: 1,
              showCropGrid: true,
              hideBottomControls: false,
            ),
            IOSUiSettings(
              title: 'Crop Product Image',
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
              rotateButtonsHidden: false,
              rotateClockwiseButtonHidden: false,
              doneButtonTitle: 'Done',
              cancelButtonTitle: 'Cancel',
              aspectRatioPickerButtonHidden: true,
            ),
          ],
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 90,
        );
      } catch (e, st) {
        debugPrint('ImageHelper.cropImage platform: $e\n$st');
        try {
          if (tempFile.existsSync()) await tempFile.delete();
        } catch (_) {}
        return null;
      }

      try {
        if (tempFile.existsSync()) await tempFile.delete();
      } catch (_) {}

      if (croppedFile == null) return null;
      final croppedFileObj = File(croppedFile.path);
      if (!await croppedFileObj.exists()) return null;
      return croppedFileObj;
    } catch (e, st) {
      debugPrint('ImageHelper.cropImage: $e\n$st');
      try {
        if (tempFile != null && await tempFile.exists()) await tempFile.delete();
      } catch (_) {}
      return null;
    }
  }

  static Future<String?> saveImageToAppDirectory(
    File imageFile,
    String productId,
  ) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'product_images');
      final Directory dir = Directory(imagesDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final String extension = path.extension(imageFile.path);
      final String filename = '$productId$extension';
      final String newPath = path.join(imagesDir, filename);
      final File savedFile = await imageFile.copy(newPath);
      return savedFile.path;
    } catch (e, st) {
      debugPrint('ImageHelper.saveImageToAppDirectory: $e\n$st');
      return null;
    }
  }

  static Future<bool> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return false;
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e, st) {
      debugPrint('ImageHelper.deleteImage: $e\n$st');
      return false;
    }
  }
}

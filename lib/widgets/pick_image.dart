import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<File?> pickImage() async {
  final picker = ImagePicker();

  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );

  if (image == null) return null;

  final extension = image.name.split('.').last.toLowerCase();

  const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  if (!allowedExtensions.contains(extension)) {
    throw Exception('Format gambar harus JPG, PNG, atau WEBP');
  }

  return File(image.path);
}

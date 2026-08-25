import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressor {
  ImageCompressor._();

  static Future<File?> compress(File? file) async {
    if (file == null) return null;

    try {
      final tempDir = await getTemporaryDirectory();

      final targetPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final XFile? compressedFile =
          await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            targetPath,
            quality: 70,
            minWidth: 1200,
            minHeight: 1200,
            format: CompressFormat.jpeg,
          );

      if (compressedFile == null) {
        return file;
      }

      return File(compressedFile.path);
    } catch (e) {
      print('Image compression error: $e');
      return file;
    }
  }
}

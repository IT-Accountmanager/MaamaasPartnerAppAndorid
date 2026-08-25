import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

extension MultipartFileExtension on File {
  Future<http.MultipartFile> asMultipart(String fieldName) async {
    final fileName = path.split('/').last;

    // Detect real MIME type (jpeg/png/webp)
    final mimeType = lookupMimeType(path) ?? 'image/jpeg';
    final parts = mimeType.split('/');

    print("🧾 Detected MIME: $mimeType for file: $fileName");

    return await http.MultipartFile.fromPath(
      fieldName,
      path,
      filename: fileName,
      contentType: MediaType(parts[0], parts[1]),
    );
  }
}

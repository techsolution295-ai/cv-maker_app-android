import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class PdfSaveResult {
  final String fileName;
  final String displayLocation;

  const PdfSaveResult({
    required this.fileName,
    required this.displayLocation,
  });
}

class FileStorageService {
  static const _channel = MethodChannel('com.rehman.smartcvmaker/file_storage');

  String pdfFileNameFor(String baseName) => _buildFileName(baseName);

  Future<PdfSaveResult> savePdf({
    required Uint8List bytes,
    required String baseName,
  }) async {
    final fileName = _buildFileName(baseName);

    if (Platform.isAndroid) {
      try {
        final location = await _channel.invokeMethod<String>(
          'savePdfToDownloads',
          {
            'fileName': fileName,
            'bytes': bytes,
          },
        );
        if (location != null && location.isNotEmpty) {
          return PdfSaveResult(
            fileName: fileName,
            displayLocation: location,
          );
        }
      } catch (_) {
        // Fall back to app storage below.
      }
    }

    return _saveToAppFolder(bytes: bytes, fileName: fileName);
  }

  Future<PdfSaveResult> _saveToAppFolder({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final baseDir = await getApplicationDocumentsDirectory();
    final folder = Directory('${baseDir.path}/CV Maker');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final file = await _resolveUniqueFile(folder, fileName);
    await file.writeAsBytes(bytes, flush: true);

    return PdfSaveResult(
      fileName: file.path.split(Platform.pathSeparator).last,
      displayLocation: 'CV Maker/${file.path.split(Platform.pathSeparator).last}',
    );
  }

  Future<File> _resolveUniqueFile(Directory folder, String fileName) async {
    var target = File('${folder.path}/$fileName');
    if (!await target.exists()) return target;

    final base = _stripExtension(fileName);
    var index = 1;
    while (await target.exists()) {
      target = File('${folder.path}/${base}_$index.pdf');
      index++;
    }
    return target;
  }

  String _buildFileName(String baseName) {
    final sanitized = baseName
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final name = sanitized.isEmpty ? 'My_Resume' : '${sanitized}_Resume';
    return '$name.pdf';
  }

  String _stripExtension(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return fileName.substring(0, fileName.length - 4);
    }
    return fileName;
  }
}

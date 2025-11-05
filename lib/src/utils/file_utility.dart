import 'dart:typed_data';
import 'package:mime/mime.dart';

/// Utility class for file operations
class FileUtility {
  /// Get MIME type from file name and/or bytes
  static String getMimeType({
    String? fileName,
    Uint8List? bytes,
  }) {
    if (bytes != null) {
      String dummyPath = 'file';
      if (fileName != null && fileName.contains('.')) {
        dummyPath += '.${fileName.split('.').last}';
      }
      return lookupMimeType(dummyPath, headerBytes: bytes) ??
          'application/octet-stream';
    } else if (fileName != null && fileName.contains('.')) {
      final extension = fileName.split('.').last.toLowerCase();
      return lookupMimeType('file.$extension') ?? 'application/octet-stream';
    }
    return 'application/octet-stream';
  }

  /// Get file extension from file name
  static String? getExtension(String? fileName) {
    if (fileName == null || !fileName.contains('.')) {
      return null;
    }
    return fileName.split('.').last.toLowerCase();
  }

  /// Check if file name has a valid extension
  static bool hasExtension(String? fileName) {
    return getExtension(fileName) != null;
  }

  /// Format file size in human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Sanitize file name (remove invalid characters)
  static String sanitizeFileName(String fileName) {
    // Remove invalid characters for file names
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  /// Get safe file name with fallback
  static String getSafeFileName(String? fileName, String fallback) {
    if (fileName == null || fileName.isEmpty) {
      return fallback;
    }
    return sanitizeFileName(fileName);
  }
}
import 'dart:typed_data';
import 'package:mime/mime.dart';
import 'package:universal_viewer/src/core/content_type.dart';

/// Intelligent content type detection
class ContentDetector {
  /// Detect content type from multiple sources
  static ContentType detect({
    String? url,
    String? fileName,
    Uint8List? bytes,
    String? mimeType,
    String? htmlContent,
  }) {
    // If HTML content is provided directly
    if (htmlContent != null && htmlContent.isNotEmpty) {
      return ContentType.html;
    }

    // Check URL patterns first (highest priority)
    if (url != null && url.isNotEmpty) {
      final urlType = _detectFromUrl(url);
      if (urlType != null) return urlType;
    }

    // Try MIME type detection
    if (mimeType != null) {
      final mimeTypeResult = _detectFromMimeType(mimeType);
      if (mimeTypeResult != ContentType.unknown) {
        return mimeTypeResult;
      }
    }

    // Try to detect from bytes
    if (bytes != null) {
      final detectedMime = lookupMimeType(
        fileName ?? 'file',
        headerBytes: bytes,
      );
      if (detectedMime != null) {
        final mimeResult = _detectFromMimeType(detectedMime);
        if (mimeResult != ContentType.unknown) {
          return mimeResult;
        }
      }
    }

    // Try file extension
    if (fileName != null && fileName.contains('.')) {
      final extensionType = _detectFromFileName(fileName);
      if (extensionType != ContentType.unknown) {
        return extensionType;
      }
    }

    // If URL exists but no specific type detected, it's a web page
    if (url != null && url.isNotEmpty) {
      return ContentType.web;
    }

    return ContentType.unknown;
  }

  /// Detect from URL patterns
  static ContentType? _detectFromUrl(String url) {
    final lowerUrl = url.toLowerCase();

    // YouTube
    if (lowerUrl.contains('youtube.com') ||
        lowerUrl.contains('youtu.be') ||
        lowerUrl.contains('youtube-nocookie.com')) {
      return ContentType.youtube;
    }

    // Vimeo
    if (lowerUrl.contains('vimeo.com')) {
      return ContentType.vimeo;
    }

    // Google Docs/Sheets/Slides
    if (lowerUrl.contains('docs.google.com') ||
        lowerUrl.contains('drive.google.com')) {
      return ContentType.googleDoc;
    }

    return null;
  }

  /// Detect from MIME type
  static ContentType _detectFromMimeType(String mimeType) {
    final lower = mimeType.toLowerCase();

    if (lower.startsWith('image/')) return ContentType.image;
    if (lower.startsWith('video/')) return ContentType.video;
    if (lower.startsWith('audio/')) return ContentType.audio;

    if (lower == 'application/pdf') return ContentType.pdf;
    if (lower.startsWith('text/')) return ContentType.text;
    if (lower == 'text/html') return ContentType.html;

    // Microsoft Office
    if (lower.contains('word') ||
        lower.contains('document') ||
        lower == 'application/msword' ||
        lower.contains('wordprocessingml')) {
      return ContentType.word;
    }

    if (lower.contains('excel') ||
        lower.contains('spreadsheet') ||
        lower == 'application/vnd.ms-excel' ||
        lower.contains('spreadsheetml') ||
        lower == 'text/csv') {
      return ContentType.excel;
    }

    if (lower.contains('powerpoint') ||
        lower.contains('presentation') ||
        lower == 'application/vnd.ms-powerpoint' ||
        lower.contains('presentationml')) {
      return ContentType.powerpoint;
    }

    // Archives
    if (lower.contains('zip') ||
        lower.contains('rar') ||
        lower.contains('tar') ||
        lower.contains('compressed')) {
      return ContentType.archive;
    }

    return ContentType.unknown;
  }

  /// Detect from file name/extension
  static ContentType _detectFromFileName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    for (final type in ContentType.values) {
      if (type.extensions.contains(extension)) {
        return type;
      }
    }

    return ContentType.unknown;
  }

  /// Get appropriate file extension for content type
  static String getDefaultExtension(ContentType type) {
    if (type.extensions.isNotEmpty) {
      return type.extensions.first;
    }
    return 'bin';
  }
}
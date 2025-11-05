import 'package:flutter/material.dart';

/// Enum defining all supported content types
enum ContentType {
  /// Regular website (any URL)
  web(
    name: 'Website',
    icon: Icons.language,
    color: Colors.blue,
    extensions: ['http', 'https'],
  ),

  /// Image files
  image(
    name: 'Image',
    extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg', 'ico'],
    icon: Icons.image,
    color: Colors.blue,
  ),

  /// Video files or streaming
  video(
    name: 'Video',
    extensions: ['mp4', 'webm', 'ogg', 'mov', 'avi', 'mkv', 'm4v', 'flv'],
    icon: Icons.videocam,
    color: Colors.red,
  ),

  /// Audio files
  audio(
    name: 'Audio',
    extensions: ['mp3', 'wav', 'ogg', 'aac', 'flac', 'm4a', 'wma'],
    icon: Icons.audiotrack,
    color: Colors.purple,
  ),

  /// PDF documents
  pdf(
    name: 'PDF',
    extensions: ['pdf'],
    icon: Icons.picture_as_pdf,
    color: Colors.red,
  ),

  /// Microsoft Word documents
  word(
    name: 'Word Document',
    extensions: ['doc', 'docx', 'docm', 'dot', 'dotx', 'dotm'],
    icon: Icons.description,
    color: Color(0xFF2B579A),
  ),

  /// Microsoft Excel spreadsheets
  excel(
    name: 'Excel Spreadsheet',
    extensions: ['xls', 'xlsx', 'xlsm', 'xltx', 'xltm', 'csv'],
    icon: Icons.table_chart,
    color: Color(0xFF217346),
  ),

  /// Microsoft PowerPoint presentations
  powerpoint(
    name: 'PowerPoint Presentation',
    extensions: ['ppt', 'pptx', 'pptm', 'pps', 'ppsx', 'ppsm'],
    icon: Icons.slideshow,
    color: Color(0xFFD24726),
  ),

  /// Text files
  text(
    name: 'Text Document',
    extensions: [
      'txt',
      'rtf',
      'md',
      'markdown',
      'json',
      'xml',
      'html',
      'htm',
      'css',
      'js',
      'jsx',
      'ts',
      'tsx',
      'dart',
      'yaml',
      'yml'
    ],
    icon: Icons.text_snippet,
    color: Colors.blueGrey,
  ),

  /// Archive files
  archive(
    name: 'Archive',
    extensions: ['zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz'],
    icon: Icons.folder_zip,
    color: Colors.amber,
  ),

  /// YouTube videos
  youtube(
    name: 'YouTube Video',
    extensions: [],
    icon: Icons.ondemand_video,
    color: Color(0xFFFF0000),
  ),

  /// Vimeo videos
  vimeo(
    name: 'Vimeo Video',
    extensions: [],
    icon: Icons.video_library,
    color: Color(0xFF1AB7EA),
  ),

  /// Google Docs/Sheets/Slides
  googleDoc(
    name: 'Google Document',
    extensions: [],
    icon: Icons.description_outlined,
    color: Color(0xFF4285F4),
  ),

  /// Raw HTML content
  html(
    name: 'HTML Content',
    extensions: [],
    icon: Icons.code,
    color: Colors.orange,
  ),

  /// Unknown or unsupported type
  unknown(
    name: 'Unknown File',
    extensions: [],
    icon: Icons.insert_drive_file,
    color: Colors.grey,
  );

  const ContentType({
    required this.name,
    required this.extensions,
    required this.icon,
    required this.color,
  });

  final String name;
  final List<String> extensions;
  final IconData icon;
  final Color color;

  /// Check if this content type requires HTML rendering
  bool get requiresHtmlView {
    return this == ContentType.web ||
        this == ContentType.video ||
        this == ContentType.audio ||
        this == ContentType.pdf ||
        this == ContentType.text ||
        this == ContentType.word ||
        this == ContentType.excel ||
        this == ContentType.powerpoint ||
        this == ContentType.youtube ||
        this == ContentType.vimeo ||
        this == ContentType.googleDoc ||
        this == ContentType.html;
  }

  /// Check if this content type can be downloaded
  bool get isDownloadable {
    return this != ContentType.web &&
        this != ContentType.youtube &&
        this != ContentType.vimeo &&
        this != ContentType.googleDoc &&
        this != ContentType.html;
  }

  /// Check if this is an online service
  bool get isOnlineService {
    return this == ContentType.youtube ||
        this == ContentType.vimeo ||
        this == ContentType.googleDoc ||
        this == ContentType.web;
  }

  /// Get MIME type for this content type
  String? get mimeType {
    switch (this) {
      case ContentType.pdf:
        return 'application/pdf';
      case ContentType.image:
        return 'image/*';
      case ContentType.video:
        return 'video/*';
      case ContentType.audio:
        return 'audio/*';
      case ContentType.text:
        return 'text/plain';
      case ContentType.html:
        return 'text/html';
      case ContentType.word:
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case ContentType.excel:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case ContentType.powerpoint:
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      default:
        return null;
    }
  }
}

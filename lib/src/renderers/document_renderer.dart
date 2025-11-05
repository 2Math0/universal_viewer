import 'package:flutter/material.dart';
import 'package:universal_viewer/src/controllers/viewer_controller.dart';
import 'package:universal_viewer/src/core/content_type.dart';
import 'package:universal_viewer/src/renderers/renderer.dart';

/// Renderer for document content (PDF, Office)
class DocumentRenderer extends ContentRenderer {
  @override
  bool canRender(ContentType type) {
    return type == ContentType.pdf ||
        type == ContentType.word ||
        type == ContentType.excel ||
        type == ContentType.powerpoint ||
        type == ContentType.text;
  }

  @override
  Widget build(BuildContext context, ViewerController controller) {
    // Platform-specific implementation needed
    return const Center(
      child: Text('Document renderer - platform implementation required'),
    );
  }
}
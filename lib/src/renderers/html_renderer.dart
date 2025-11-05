import 'package:flutter/material.dart';
import 'package:universal_viewer/src/controllers/viewer_controller.dart';
import 'package:universal_viewer/src/core/content_type.dart';
import 'package:universal_viewer/src/renderers/renderer.dart';

/// Renderer for raw HTML content
class HtmlRenderer extends ContentRenderer {
  @override
  bool canRender(ContentType type) {
    return type == ContentType.html;
  }

  @override
  Widget build(BuildContext context, ViewerController controller) {
    // Platform-specific implementation needed
    return const Center(
      child: Text('HTML renderer - platform implementation required'),
    );
  }
}
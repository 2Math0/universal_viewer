import 'package:flutter/material.dart';
import 'package:universal_viewer/src/controllers/viewer_controller.dart';
import 'package:universal_viewer/src/core/content_type.dart';
import 'package:universal_viewer/src/renderers/renderer.dart';

/// Renderer for web content (any URL)
class WebRenderer extends ContentRenderer {
  @override
  bool canRender(ContentType type) {
    return type == ContentType.web ||
        type == ContentType.youtube ||
        type == ContentType.vimeo ||
        type == ContentType.googleDoc;
  }

  @override
  Widget build(BuildContext context, ViewerController controller) {
    // Implementation depends on platform
    return const Center(
      child: Text('Web renderer - platform implementation required'),
    );
  }
}

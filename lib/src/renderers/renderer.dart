import 'package:flutter/material.dart';
import 'package:universal_viewer/src/controllers/viewer_controller.dart';
import 'package:universal_viewer/src/core/content_type.dart';

/// Abstract base class for content renderers
abstract class ContentRenderer {
  /// Check if this renderer can handle the given content type
  bool canRender(ContentType type);

  /// Build the widget for rendering
  Widget build(BuildContext context, ViewerController controller);

  /// Cleanup resources when renderer is disposed
  void dispose() {}
}

/// Factory for creating appropriate renderers
class RendererFactory {
  static ContentRenderer? getRenderer(ContentType type) {
    // Implementation will be in specific renderer files
    return null;
  }
}

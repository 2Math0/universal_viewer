import 'package:flutter/material.dart';
import 'package:universal_viewer/src/controllers/viewer_controller.dart';
import 'package:universal_viewer/src/core/content_type.dart';
import 'package:universal_viewer/src/renderers/renderer.dart';

/// Renderer for video and audio content
class MediaRenderer extends ContentRenderer {
  @override
  bool canRender(ContentType type) {
    return type == ContentType.video || type == ContentType.audio;
  }

  @override
  Widget build(BuildContext context, ViewerController controller) {
    // Platform-specific implementation needed
    return const Center(
      child: Text('Media renderer - platform implementation required'),
    );
  }
}
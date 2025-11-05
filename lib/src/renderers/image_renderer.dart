import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:universal_viewer/src/controllers/viewer_controller.dart';
import 'package:universal_viewer/src/core/content_type.dart';
import 'package:universal_viewer/src/core/viewer_config.dart';
import 'package:universal_viewer/src/renderers/renderer.dart';

/// Renderer for image content
class ImageRenderer extends ContentRenderer {
  ImageRenderer({required this.config});

  final ViewerConfig config;

  @override
  bool canRender(ContentType type) {
    return type == ContentType.image;
  }

  @override
  Widget build(BuildContext context, ViewerController controller) {
    final state = controller.value;
    final theme = config.theme ?? ViewerTheme.fromThemeData(Theme.of(context));

    if (state.objectUrl == null) {
      return Center(
        child: Text(
          'No image URL available',
          style: TextStyle(color: theme.errorColor),
        ),
      );
    }

    // If we have bytes, show from memory
    if (state.bytes != null) {
      return InteractiveViewer(
        child: Image.memory(
          state.bytes!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 64, color: theme.errorColor),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: theme.errorColor),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    // Load from URL with caching
    return InteractiveViewer(
      child: CachedNetworkImage(
        imageUrl: state.objectUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: theme.loadingIndicatorColor ?? theme.primaryColor,
          ),
        ),
        errorWidget: (context, url, error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 64, color: theme.errorColor),
                const SizedBox(height: 16),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: theme.errorColor),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

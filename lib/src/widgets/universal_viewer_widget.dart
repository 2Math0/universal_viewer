import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:universal_viewer/src/controllers/viewer_controller.dart';
import 'package:universal_viewer/src/core/content_detector.dart';
import 'package:universal_viewer/src/core/content_type.dart';
import 'package:universal_viewer/src/core/viewer_config.dart';
import 'package:universal_viewer/src/platform/mobile_fallback.dart';
import 'package:universal_viewer/src/platform/web_implementation.dart';
import 'package:universal_viewer/src/renderers/image_renderer.dart';
import 'package:universal_viewer/src/utils/platform_detector.dart';
import 'package:universal_viewer/src/widgets/overlay_handler.dart';
import 'package:universal_viewer/src/widgets/viewer_toolbar.dart';

/// Main Universal Viewer Widget
class UniversalViewer extends StatefulWidget {
  const UniversalViewer({
    super.key,
    this.url,
    this.file,
    this.bytes,
    this.fileName,
    this.mimeType,
    this.htmlContent,
    this.config = const ViewerConfig(),
    this.controller,
  });

  /// Create viewer from URL
  factory UniversalViewer.url(
    String url, {
    ViewerConfig config = const ViewerConfig(),
    ViewerController? controller,
  }) {
    return UniversalViewer(
      url: url,
      config: config,
      controller: controller,
    );
  }

  /// Create viewer from file
  factory UniversalViewer.file(
    PlatformFile file, {
    ViewerConfig config = const ViewerConfig(),
    ViewerController? controller,
  }) {
    return UniversalViewer(
      file: file,
      config: config,
      controller: controller,
    );
  }

  /// Create viewer from bytes
  factory UniversalViewer.bytes(
    Uint8List bytes, {
    String? fileName,
    String? mimeType,
    ViewerConfig config = const ViewerConfig(),
    ViewerController? controller,
  }) {
    return UniversalViewer(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      config: config,
      controller: controller,
    );
  }

  /// Create viewer from HTML content
  factory UniversalViewer.html(
    String htmlContent, {
    ViewerConfig config = const ViewerConfig(),
    ViewerController? controller,
  }) {
    return UniversalViewer(
      htmlContent: htmlContent,
      config: config,
      controller: controller,
    );
  }

  final String? url;
  final PlatformFile? file;
  final Uint8List? bytes;
  final String? fileName;
  final String? mimeType;
  final String? htmlContent;
  final ViewerConfig config;
  final ViewerController? controller;

  @override
  State<UniversalViewer> createState() => _UniversalViewerState();
}

class _UniversalViewerState extends State<UniversalViewer> {
  late ViewerController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ViewerController();
    _ownsController = widget.controller == null;
    _loadContent();
  }

  @override
  void didUpdateWidget(UniversalViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if content source changed
    if (oldWidget.url != widget.url ||
        oldWidget.file != widget.file ||
        oldWidget.bytes != widget.bytes ||
        oldWidget.htmlContent != widget.htmlContent) {
      _loadContent();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadContent() async {
    widget.config.onLoadStart?.call();
    _controller.setLoading(true);

    try {
      // Determine file name
      // Determine file name
      final fileName = widget.fileName ??
          widget.file?.name ??
          (widget.url != null ? _extractFileNameFromUrl(widget.url!) : null);

      // Get bytes
      final bytes = widget.bytes ?? widget.file?.bytes;

      // Detect content type
      final contentType = ContentDetector.detect(
        url: widget.url,
        fileName: fileName,
        bytes: bytes,
        mimeType: widget.mimeType,
        htmlContent: widget.htmlContent,
      );

      // Get object URL
      String? objectUrl = widget.url;

      if (objectUrl == null && bytes != null) {
        // Create blob URL for bytes (web only)
        if (PlatformDetector.isWeb) {
          final mimeType = widget.mimeType ??
              ContentDetector.detect(
                fileName: fileName,
                bytes: bytes,
              ).mimeType ??
              'application/octet-stream';
          objectUrl = WebImplementation.createBlobUrl(bytes, mimeType);
        }
      }

      if (objectUrl == null && widget.htmlContent != null) {
        // Create blob URL for HTML content (web only)
        if (PlatformDetector.isWeb) {
          objectUrl = WebImplementation.createHtmlBlobUrl(widget.htmlContent!);
        }
      }

      if (objectUrl == null) {
        throw Exception('No valid content source provided');
      }

      _controller.setContent(
        objectUrl: objectUrl,
        contentType: contentType,
        fileName: fileName,
        bytes: bytes,
      );

      widget.config.onLoadComplete?.call();
    } catch (e) {
      final errorMessage = 'Failed to load content: $e';
      _controller.setError(errorMessage);
      widget.config.onError?.call(errorMessage);
    }
  }

  void _handleDownload() {
    final state = _controller.value;

    if (state.bytes != null || state.objectUrl != null) {
      final fileName = widget.config.customDownloadName ??
          state.fileName ??
          'file.${ContentDetector.getDefaultExtension(state.contentType)}';

      widget.config.onDownload?.call(fileName, state.bytes);

      // Platform-specific download
      if (PlatformDetector.isWeb) {
        WebImplementation.downloadFile(
          fileName: fileName,
          url: state.objectUrl,
          bytes: state.bytes,
          mimeType: state.contentType.mimeType,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        widget.config.theme ?? ViewerTheme.fromThemeData(Theme.of(context));

    return ValueListenableBuilder<ViewerState>(
      valueListenable: _controller,
      builder: (context, state, child) {
        return Container(
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: theme.borderRadius,
          ),
          child: Column(
            children: [
              // Toolbar
              if (widget.config.showToolbar)
                widget.config.customToolbarBuilder
                        ?.call(context, _controller) ??
                    ViewerToolbar(
                      controller: _controller,
                      config: widget.config,
                      onDownload: state.contentType.isDownloadable
                          ? _handleDownload
                          : null,
                    ),

              // Content
              Expanded(
                child: _buildContent(context, state, theme),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _extractFileNameFromUrl(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return null;

      // Get path segments
      final segments = uri.pathSegments;

      // If there are segments and the last one is not empty, use it
      if (segments.isNotEmpty && segments.last.isNotEmpty) {
        return segments.last;
      }

      // Otherwise, use the domain name
      return uri.host.isNotEmpty ? uri.host : null;
    } catch (e) {
      return null;
    }
  }

  Widget _buildContent(
      BuildContext context, ViewerState state, ViewerTheme theme) {
    // Loading state
    if (state.isLoading) {
      return widget.config.loadingWidget ??
          Center(
            child: CircularProgressIndicator(
              color: theme.loadingIndicatorColor ?? theme.primaryColor,
            ),
          );
    }

    // Error state
    if (state.hasError) {
      return widget.config.errorBuilder?.call(context, state.error!) ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: theme.errorColor),
                  const SizedBox(height: 16),
                  Text(
                    state.error!,
                    style: TextStyle(color: theme.errorColor, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _controller.reload(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
    }

    // Handle overlay detection
    if (widget.config.enableAutoOverlayDetection) {
      return OverlayHandler(
        onOverlayChanged: (hasOverlay) {
          if (hasOverlay) {
            _controller.hide();
          } else {
            _controller.show();
          }
        },
        child: _buildContentByType(context, state, theme),
      );
    }

    return _buildContentByType(context, state, theme);
  }

  Widget _buildContentByType(
      BuildContext context, ViewerState state, ViewerTheme theme) {
    // Show placeholder if hidden by overlay
    if (state.isHidden && widget.config.showPlaceholderOnOverlay) {
      return widget.config.placeholderBuilder?.call(context) ??
          _buildPlaceholder(state, theme);
    }

    // Route to appropriate renderer based on content type
    if (state.contentType == ContentType.image) {
      return ImageRenderer(config: widget.config).build(context, _controller);
    }

    // For other types, use platform-specific implementation
    if (PlatformDetector.isWeb) {
      return WebImplementation.buildViewer(
        context: context,
        state: state,
        config: widget.config,
      );
    } else {
      return MobileFallback.buildViewer(
        context: context,
        state: state,
        config: widget.config,
      );
    }
  }

  Widget _buildPlaceholder(ViewerState state, ViewerTheme theme) {
    return Container(
      color: theme.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.contentType.icon,
              size: 64,
              color: state.contentType.color,
            ),
            const SizedBox(height: 16),
            Text(
              state.fileName ?? state.contentType.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Content hidden while dialog is open',
              style: TextStyle(
                  fontSize: 14, color: theme.textColor.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.visibility_off,
              color: theme.textColor.withValues(alpha: 0.4),
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:universal_viewer/src/controllers/viewer_controller.dart';
import 'package:universal_viewer/src/core/content_type.dart';
import 'package:universal_viewer/src/core/viewer_config.dart';
import 'package:universal_viewer/src/utils/file_utility.dart';
import 'package:universal_viewer/src/utils/url_utility.dart';
import 'package:web/web.dart' as web;

/// Web-specific implementation using package:web
class WebImplementation {
  static final List<web.HTMLElement> _createdElements = [];
  static int _viewIdCounter = 0;

  /// Create a blob URL from bytes
  static String createBlobUrl(Uint8List bytes, String mimeType) {
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: mimeType),
    );
    return web.URL.createObjectURL(blob);
  }

  /// Create a blob URL from HTML content
  static String createHtmlBlobUrl(String htmlContent) {
    final blob = web.Blob(
      [htmlContent.toJS].toJS,
      web.BlobPropertyBag(type: 'text/html'),
    );
    return web.URL.createObjectURL(blob);
  }

  /// Revoke a blob URL
  static void revokeBlobUrl(String url) {
    if (url.startsWith('blob:')) {
      web.URL.revokeObjectURL(url);
    }
  }

  /// Download file on web
  static void downloadFile({
    required String fileName,
    String? url,
    Uint8List? bytes,
    String? mimeType,
  }) {
    String downloadUrl;
    bool needsCleanup = false;

    if (url != null && !url.startsWith('blob:')) {
      downloadUrl = url;
    } else if (bytes != null) {
      final mime =
          mimeType ?? FileUtility.getMimeType(fileName: fileName, bytes: bytes);
      downloadUrl = createBlobUrl(bytes, mime);
      needsCleanup = true;
    } else if (url != null) {
      downloadUrl = url;
    } else {
      throw Exception('No valid source for download');
    }

    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = downloadUrl;
    anchor.target = '_blank';
    anchor.download = fileName;
    anchor.click();

    if (needsCleanup) {
      Future.delayed(const Duration(seconds: 1), () {
        revokeBlobUrl(downloadUrl);
      });
    }
  }

  /// Build viewer for web platform
  static Widget buildViewer({
    required BuildContext context,
    required ViewerState state,
    required ViewerConfig config,
  }) {
    if (state.objectUrl == null) {
      return const Center(child: Text('No content URL available'));
    }

    final contentType = state.contentType;

    // Handle different content types
    if (contentType == ContentType.video) {
      return _buildVideoElement(state.objectUrl!);
    }

    if (contentType == ContentType.audio) {
      return _buildAudioElement(state.objectUrl!);
    }

    if (contentType == ContentType.pdf || contentType == ContentType.text) {
      return _buildIframeElement(state.objectUrl!);
    }

    if (contentType == ContentType.word ||
        contentType == ContentType.excel ||
        contentType == ContentType.powerpoint) {
      // Try Google Docs viewer for Office files
      if (!state.objectUrl!.startsWith('blob:')) {
        final googleViewerUrl =
            'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(state.objectUrl!)}';
        return _buildIframeElement(googleViewerUrl);
      } else {
        // Can't use Google viewer with blob URLs, show download option
        return _buildOfficePreview(context, state, config);
      }
    }

    if (contentType == ContentType.youtube) {
      final embedUrl = UrlUtility.toYouTubeEmbedUrl(state.objectUrl!);
      return _buildIframeElement(embedUrl, allowFullscreen: true);
    }

    if (contentType == ContentType.vimeo) {
      final embedUrl = UrlUtility.toVimeoEmbedUrl(state.objectUrl!);
      return _buildIframeElement(embedUrl, allowFullscreen: true);
    }

    if (contentType == ContentType.googleDoc ||
        contentType == ContentType.web ||
        contentType == ContentType.html) {
      return _buildIframeElement(state.objectUrl!, allowFullscreen: true);
    }

    // Default: try iframe
    return _buildIframeElement(state.objectUrl!);
  }

  /// Build video element
  static Widget _buildVideoElement(String url) {
    return _createHtmlElementView((viewId) {
      final element =
          web.document.createElement('video') as web.HTMLVideoElement;
      element.src = url;
      element.controls = true;
      element.style.width = '100%';
      element.style.height = '100%';
      element.style.objectFit = 'contain';
      element.style.backgroundColor = '#000';
      _createdElements.add(element);
      return element;
    });
  }

  /// Build audio element
  static Widget _buildAudioElement(String url) {
    return _createHtmlElementView((viewId) {
      final element =
          web.document.createElement('audio') as web.HTMLAudioElement;
      element.src = url;
      element.controls = true;
      element.style.width = '100%';
      element.style.padding = '20px';
      _createdElements.add(element);
      return element;
    });
  }

  /// Build iframe element
  static Widget _buildIframeElement(String url,
      {bool allowFullscreen = false}) {
    return _createHtmlElementView((viewId) {
      final element =
          web.document.createElement('iframe') as web.HTMLIFrameElement;
      element.src = url;
      element.style.border = 'none';
      element.style.width = '100%';
      element.style.height = '100%';

      if (allowFullscreen) {
        element.allowFullscreen = true;
      }

      _createdElements.add(element);
      return element;
    });
  }

  /// Build office file preview (download prompt)
  static Widget _buildOfficePreview(
    BuildContext context,
    ViewerState state,
    ViewerConfig config,
  ) {
    final theme = config.theme ?? ViewerTheme.fromThemeData(Theme.of(context));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.contentType.icon,
              size: 80,
              color: state.contentType.color,
            ),
            const SizedBox(height: 16),
            Text(
              state.fileName ?? '${state.contentType.name} Document',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This document cannot be previewed directly.',
              style: TextStyle(color: theme.textColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.download),
              label: const Text('Download File'),
              onPressed: () {
                if (state.bytes != null || state.objectUrl != null) {
                  final fileName = state.fileName ??
                      'document.${state.contentType.extensions.isNotEmpty ? state.contentType.extensions.first : 'bin'}';

                  downloadFile(
                    fileName: fileName,
                    url: state.objectUrl,
                    bytes: state.bytes,
                    mimeType: state.contentType.mimeType,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Create HTML element view using modern platform views
  static Widget _createHtmlElementView(
    web.Element Function(String viewId) elementBuilder,
  ) {
    final viewId = 'universal-viewer-${_viewIdCounter++}';
    final element = elementBuilder(viewId);

    // Register the view factory using modern API
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => element,
    );

    return HtmlElementView(viewType: viewId);
  }

  /// Update visibility of HTML elements
  static void updateElementsVisibility(bool visible) {
    for (final element in _createdElements) {
      if (visible) {
        element.style.pointerEvents = 'auto';
        element.style.visibility = 'visible';
        element.style.opacity = '1';
      } else {
        element.style.pointerEvents = 'none';
        element.style.visibility = 'hidden';
        element.style.opacity = '0';
      }
    }
  }

  /// Cleanup HTML elements
  static void cleanupElements() {
    for (final element in _createdElements) {
      try {
        element.remove();
      } catch (e) {
        // Element might already be removed
      }
    }
    _createdElements.clear();
  }
}

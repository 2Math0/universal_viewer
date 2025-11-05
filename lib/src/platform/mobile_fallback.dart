import 'package:flutter/material.dart';
import 'package:universal_viewer/src/controllers/viewer_controller.dart';
import 'package:universal_viewer/src/core/content_type.dart';
import 'package:universal_viewer/src/core/viewer_config.dart';
import 'package:universal_viewer/src/utils/url_utility.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Mobile platform implementation using webview_flutter
class MobileFallback {
  /// Build viewer for mobile platforms
  static Widget buildViewer({
    required BuildContext context,
    required ViewerState state,
    required ViewerConfig config,
  }) {
    if (state.objectUrl == null) {
      return const Center(child: Text('No content URL available'));
    }

    final contentType = state.contentType;

    // Handle YouTube
    if (contentType == ContentType.youtube) {
      final embedUrl = UrlUtility.toYouTubeEmbedUrl(state.objectUrl!);
      return _buildWebView(embedUrl, config);
    }

    // Handle Vimeo
    if (contentType == ContentType.vimeo) {
      final embedUrl = UrlUtility.toVimeoEmbedUrl(state.objectUrl!);
      return _buildWebView(embedUrl, config);
    }

    // Handle blob URLs (can't load directly on mobile)
    if (state.objectUrl!.startsWith('blob:')) {
      return _buildUnsupportedContent(context, state, config);
    }

    // Handle office documents with Google Docs viewer
    if (contentType == ContentType.word ||
        contentType == ContentType.excel ||
        contentType == ContentType.powerpoint) {
      final googleViewerUrl =
          'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(state.objectUrl!)}';
      return _buildWebView(googleViewerUrl, config);
    }

    // Default: load in webview
    return _buildWebView(state.objectUrl!, config);
  }

  /// Build WebView widget
  static Widget _buildWebView(String url, ViewerConfig config) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            // Could expose this through config callbacks
          },
          onPageStarted: (url) {
            config.onLoadStart?.call();
          },
          onPageFinished: (url) {
            config.onLoadComplete?.call();
          },
          onWebResourceError: (error) {
            config.onError?.call(error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    return WebViewWidget(controller: controller);
  }

  /// Build unsupported content widget
  static Widget _buildUnsupportedContent(
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
              state.fileName ?? state.contentType.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This content cannot be displayed on mobile devices.',
              style: TextStyle(color: theme.textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please try opening it in a web browser.',
              style: TextStyle(
                color: theme.textColor.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
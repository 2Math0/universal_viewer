/// Utility class for URL operations
class UrlUtility {
  /// Check if string is a valid URL
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.hasScheme) &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  /// Convert YouTube URL to embed URL
  static String toYouTubeEmbedUrl(String url) {
    final uri = Uri.parse(url);

    // Handle youtu.be short links
    if (uri.host.contains('youtu.be')) {
      final videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
      if (videoId.isNotEmpty) {
        return 'https://www.youtube.com/embed/$videoId';
      }
    }

    // Handle youtube.com/watch?v=... links
    if (uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];
      if (videoId != null && videoId.isNotEmpty) {
        return 'https://www.youtube.com/embed/$videoId';
      }

      // Handle youtube.com/embed/... (already embedded)
      if (uri.pathSegments.contains('embed') && uri.pathSegments.length > 1) {
        return url;
      }
    }

    // Handle youtube-nocookie.com
    if (uri.host.contains('youtube-nocookie.com')) {
      if (uri.pathSegments.contains('embed') && uri.pathSegments.length > 1) {
        return url;
      }
    }

    return url; // Fallback to original URL
  }

  /// Convert Vimeo URL to embed URL
  static String toVimeoEmbedUrl(String url) {
    final uri = Uri.parse(url);

    if (uri.host.contains('vimeo.com')) {
      // Handle player.vimeo.com/video/... (already embedded)
      if (uri.host.contains('player.vimeo.com')) {
        return url;
      }

      // Handle vimeo.com/123456789
      final videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      if (videoId.isNotEmpty && int.tryParse(videoId) != null) {
        return 'https://player.vimeo.com/video/$videoId';
      }
    }

    return url; // Fallback
  }

  /// Extract domain from URL
  static String? getDomain(String? url) {
    if (url == null || url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    return uri?.host;
  }

  /// Check if URL is a YouTube link
  static bool isYouTubeUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('youtube.com') ||
        lower.contains('youtu.be') ||
        lower.contains('youtube-nocookie.com');
  }

  /// Check if URL is a Vimeo link
  static bool isVimeoUrl(String url) {
    return url.toLowerCase().contains('vimeo.com');
  }

  /// Check if URL is a Google Docs link
  static bool isGoogleDocsUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('docs.google.com') ||
        lower.contains('drive.google.com');
  }

  /// Encode URL component
  static String encodeComponent(String component) {
    return Uri.encodeComponent(component);
  }

  /// Decode URL component
  static String decodeComponent(String component) {
    return Uri.decodeComponent(component);
  }

  /// Add query parameters to URL
  static String addQueryParameters(String url, Map<String, String> params) {
    final uri = Uri.parse(url);
    final newParams = Map<String, String>.from(uri.queryParameters);
    newParams.addAll(params);

    return uri.replace(queryParameters: newParams).toString();
  }
}
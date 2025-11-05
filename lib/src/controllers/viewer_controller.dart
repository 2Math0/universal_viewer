import 'package:flutter/foundation.dart';
import 'package:universal_viewer/src/core/content_type.dart';

/// State for the viewer
class ViewerState {

  const ViewerState({
    this.isLoading = true,
    this.error,
    this.objectUrl,
    this.contentType = ContentType.unknown,
    this.fileName,
    this.bytes,
    this.isHidden = false,
  });
  final bool isLoading;
  final String? error;
  final String? objectUrl;
  final ContentType contentType;
  final String? fileName;
  final Uint8List? bytes;
  final bool isHidden;

  ViewerState copyWith({
    bool? isLoading,
    String? error,
    String? objectUrl,
    ContentType? contentType,
    String? fileName,
    Uint8List? bytes,
    bool? isHidden,
  }) {
    return ViewerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      objectUrl: objectUrl ?? this.objectUrl,
      contentType: contentType ?? this.contentType,
      fileName: fileName ?? this.fileName,
      bytes: bytes ?? this.bytes,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  bool get hasError => error != null;
  bool get isReady => !isLoading && !hasError && objectUrl != null;
}

/// Controller for the Universal Viewer using ValueNotifier
class ViewerController extends ValueNotifier<ViewerState> {
  ViewerController() : super(const ViewerState());

  /// Update loading state
  void setLoading(bool loading) {
    value = value.copyWith(isLoading: loading);
  }

  /// Set error
  void setError(String error) {
    value = value.copyWith(
      isLoading: false,
      error: error,
    );
  }

  /// Set content loaded
  void setContent({
    required String objectUrl,
    required ContentType contentType,
    String? fileName,
    Uint8List? bytes,
  }) {
    value = value.copyWith(
      isLoading: false,
      objectUrl: objectUrl,
      contentType: contentType,
      fileName: fileName,
      bytes: bytes,
    );
  }

  /// Hide the viewer (useful for overlays)
  void hide() {
    value = value.copyWith(isHidden: true);
  }

  /// Show the viewer
  void show() {
    value = value.copyWith(isHidden: false);
  }

  /// Toggle visibility
  void toggleVisibility() {
    value = value.copyWith(isHidden: !value.isHidden);
  }

  /// Reload/refresh the content
  void reload() {
    value = value.copyWith(isLoading: true);
  }

  /// Clear all content
  void clear() {
    value = const ViewerState();
  }

  /// Get current state values
  bool get isLoading => value.isLoading;
  String? get error => value.error;
  String? get objectUrl => value.objectUrl;
  ContentType get contentType => value.contentType;
  String? get fileName => value.fileName;
  Uint8List? get bytes => value.bytes;
  bool get isHidden => value.isHidden;
  bool get hasError => value.hasError;
  bool get isReady => value.isReady;
}
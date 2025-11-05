import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Configuration for the Universal Viewer
class ViewerConfig {

  const ViewerConfig({
    this.showToolbar = true,
    this.enableDownload = true,
    this.preferBlobForOffice = false,
    this.customDownloadName,
    this.theme,
    this.onLoadStart,
    this.onLoadComplete,
    this.onError,
    this.onDownload,
    this.customToolbarBuilder,
    this.showPlaceholderOnOverlay = true,
    this.enableAutoOverlayDetection = true,
    this.loadingWidget,
    this.errorBuilder,
    this.placeholderBuilder,
  });
  /// Whether to show the toolbar
  final bool showToolbar;

  /// Whether to enable download functionality
  final bool enableDownload;

  /// Whether to prefer blob URLs for Office documents
  final bool preferBlobForOffice;

  /// Custom download file name
  final String? customDownloadName;

  /// Theme configuration
  final ViewerTheme? theme;

  /// Callback when loading starts
  final VoidCallback? onLoadStart;

  /// Callback when loading completes
  final VoidCallback? onLoadComplete;

  /// Callback when an error occurs
  final void Function(String error)? onError;

  /// Callback when download is triggered
  final void Function(String fileName, Uint8List? bytes)? onDownload;

  /// Custom toolbar builder
  final Widget Function(BuildContext context, dynamic controller)?
  customToolbarBuilder;

  /// Whether to show a placeholder when overlays are active
  final bool showPlaceholderOnOverlay;

  /// Whether to enable automatic overlay detection
  final bool enableAutoOverlayDetection;

  /// Custom loading widget
  final Widget? loadingWidget;

  /// Custom error widget builder
  final Widget Function(BuildContext context, String error)? errorBuilder;

  /// Custom placeholder widget builder
  final Widget Function(BuildContext context)? placeholderBuilder;

  ViewerConfig copyWith({
    bool? showToolbar,
    bool? enableDownload,
    bool? preferBlobForOffice,
    String? customDownloadName,
    ViewerTheme? theme,
    VoidCallback? onLoadStart,
    VoidCallback? onLoadComplete,
    void Function(String error)? onError,
    void Function(String fileName, Uint8List? bytes)? onDownload,
    Widget Function(BuildContext context, dynamic controller)?
    customToolbarBuilder,
    bool? showPlaceholderOnOverlay,
    bool? enableAutoOverlayDetection,
    Widget? loadingWidget,
    Widget Function(BuildContext context, String error)? errorBuilder,
    Widget Function(BuildContext context)? placeholderBuilder,
  }) {
    return ViewerConfig(
      showToolbar: showToolbar ?? this.showToolbar,
      enableDownload: enableDownload ?? this.enableDownload,
      preferBlobForOffice: preferBlobForOffice ?? this.preferBlobForOffice,
      customDownloadName: customDownloadName ?? this.customDownloadName,
      theme: theme ?? this.theme,
      onLoadStart: onLoadStart ?? this.onLoadStart,
      onLoadComplete: onLoadComplete ?? this.onLoadComplete,
      onError: onError ?? this.onError,
      onDownload: onDownload ?? this.onDownload,
      customToolbarBuilder: customToolbarBuilder ?? this.customToolbarBuilder,
      showPlaceholderOnOverlay:
      showPlaceholderOnOverlay ?? this.showPlaceholderOnOverlay,
      enableAutoOverlayDetection:
      enableAutoOverlayDetection ?? this.enableAutoOverlayDetection,
      loadingWidget: loadingWidget ?? this.loadingWidget,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      placeholderBuilder: placeholderBuilder ?? this.placeholderBuilder,
    );
  }
}

/// Theme configuration for the viewer
class ViewerTheme {

  const ViewerTheme({
    this.primaryColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black87,
    this.textColor = Colors.black87,
    this.errorColor = Colors.red,
    this.toolbarHeight = 56.0,
    this.borderRadius,
    this.toolbarElevation = 0,
    this.loadingIndicatorColor,
  });

  /// Create theme from Flutter ThemeData
  factory ViewerTheme.fromThemeData(ThemeData themeData) {
    return ViewerTheme(
      primaryColor: themeData.primaryColor,
      backgroundColor: themeData.scaffoldBackgroundColor,
      iconColor: themeData.iconTheme.color ?? Colors.black87,
      textColor: themeData.textTheme.bodyLarge?.color ?? Colors.black87,
      errorColor: themeData.colorScheme.error,
      loadingIndicatorColor: themeData.primaryColor,
    );
  }
  /// Primary color for UI elements
  final Color primaryColor;

  /// Background color
  final Color backgroundColor;

  /// Icon color
  final Color iconColor;

  /// Text color
  final Color textColor;

  /// Error color
  final Color errorColor;

  /// Toolbar height
  final double toolbarHeight;

  /// Border radius
  final BorderRadius? borderRadius;

  /// Toolbar elevation
  final double toolbarElevation;

  /// Loading indicator color
  final Color? loadingIndicatorColor;

  ViewerTheme copyWith({
    Color? primaryColor,
    Color? backgroundColor,
    Color? iconColor,
    Color? textColor,
    Color? errorColor,
    double? toolbarHeight,
    BorderRadius? borderRadius,
    double? toolbarElevation,
    Color? loadingIndicatorColor,
  }) {
    return ViewerTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      iconColor: iconColor ?? this.iconColor,
      textColor: textColor ?? this.textColor,
      errorColor: errorColor ?? this.errorColor,
      toolbarHeight: toolbarHeight ?? this.toolbarHeight,
      borderRadius: borderRadius ?? this.borderRadius,
      toolbarElevation: toolbarElevation ?? this.toolbarElevation,
      loadingIndicatorColor:
      loadingIndicatorColor ?? this.loadingIndicatorColor,
    );
  }
}
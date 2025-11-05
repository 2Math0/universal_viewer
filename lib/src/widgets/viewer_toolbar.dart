import 'package:flutter/material.dart';
import 'package:universal_viewer/src/controllers/viewer_controller.dart';
import 'package:universal_viewer/src/core/viewer_config.dart';

/// Default toolbar for the Universal Viewer
class ViewerToolbar extends StatelessWidget {

  const ViewerToolbar({
    required this.controller, required this.config, super.key,
    this.onDownload,
  });
  final ViewerController controller;
  final ViewerConfig config;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = config.theme ?? ViewerTheme.fromThemeData(Theme.of(context));

    return ValueListenableBuilder<ViewerState>(
      valueListenable: controller,
      builder: (context, state, child) {
        return Container(
          height: theme.toolbarHeight,
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            boxShadow: theme.toolbarElevation > 0
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: theme.toolbarElevation,
                offset: Offset(0, theme.toolbarElevation / 2),
              ),
            ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Content type icon
                Icon(
                  state.contentType.icon,
                  color: state.contentType.color,
                  size: 24,
                ),
                const SizedBox(width: 12),

                // File name or content type
                Expanded(
                  child: Text(
                    state.fileName ?? state.contentType.name,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Download button
                if (config.enableDownload &&
                    state.contentType.isDownloadable &&
                    onDownload != null)
                  IconButton(
                    icon: Icon(Icons.download, color: theme.iconColor),
                    tooltip: 'Download',
                    onPressed: onDownload,
                  ),

                // Refresh button
                IconButton(
                  icon: Icon(Icons.refresh, color: theme.iconColor),
                  tooltip: 'Refresh',
                  onPressed: () => controller.reload(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Minimalist toolbar variant
class MinimalViewerToolbar extends StatelessWidget {

  const MinimalViewerToolbar({
    required this.controller, required this.config, super.key,
    this.onDownload,
  });
  final ViewerController controller;
  final ViewerConfig config;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = config.theme ?? ViewerTheme.fromThemeData(Theme.of(context));

    return ValueListenableBuilder<ViewerState>(
      valueListenable: controller,
      builder: (context, state, child) {
        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (config.enableDownload &&
                  state.contentType.isDownloadable &&
                  onDownload != null)
                IconButton(
                  icon: Icon(Icons.download_rounded, color: theme.iconColor),
                  tooltip: 'Download',
                  onPressed: onDownload,
                  iconSize: 20,
                ),
            ],
          ),
        );
      },
    );
  }
}
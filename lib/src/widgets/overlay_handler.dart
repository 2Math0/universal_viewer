import 'dart:async';
import 'package:flutter/material.dart';

/// Handles overlay detection and visibility management
class OverlayHandler extends StatefulWidget {

  const OverlayHandler({
    required this.child, super.key,
    this.enabled = true,
    this.onOverlayChanged,
  });
  final Widget child;
  final bool enabled;
  final void Function(bool hasOverlay)? onOverlayChanged;

  @override
  State<OverlayHandler> createState() => _OverlayHandlerState();
}

class _OverlayHandlerState extends State<OverlayHandler> {
  bool _hasOverlay = false;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startOverlayDetection();
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  void _startOverlayDetection() {
    _checkTimer = Timer.periodic(
      const Duration(milliseconds: 100),
          (_) => _checkForOverlays(),
    );
  }

  void _checkForOverlays() {
    if (!mounted) return;

    final hasOverlay = _detectOverlay();

    if (_hasOverlay != hasOverlay) {
      setState(() => _hasOverlay = hasOverlay);
      widget.onOverlayChanged?.call(hasOverlay);
    }
  }

  bool _detectOverlay() {
    // Check if there are any modal routes
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null && !modalRoute.isCurrent) {
      return true;
    }

    // Additional platform-specific checks can be added here
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Simple overlay state notifier using InheritedWidget
class OverlayState extends InheritedWidget {

  const OverlayState({
    required this.hasOverlay, required super.child, super.key,
  });
  final bool hasOverlay;

  static OverlayState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OverlayState>();
  }

  static OverlayState of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No OverlayState found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(OverlayState oldWidget) {
    return hasOverlay != oldWidget.hasOverlay;
  }
}
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NetworkScanFabWidget extends StatefulWidget {
  final bool isScanning;
  final VoidCallback onScanPressed;

  const NetworkScanFabWidget({
    Key? key,
    required this.isScanning,
    required this.onScanPressed,
  }) : super(key: key);

  @override
  State<NetworkScanFabWidget> createState() => _NetworkScanFabWidgetState();
}

class _NetworkScanFabWidgetState extends State<NetworkScanFabWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    if (widget.isScanning) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(NetworkScanFabWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _animationController.repeat();
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: widget.isScanning ? null : widget.onScanPressed,
      backgroundColor: widget.isScanning
          ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.7)
          : AppTheme.lightTheme.colorScheme.primary,
      foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
      elevation: widget.isScanning ? 2 : 4,
      icon: widget.isScanning
          ? AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: CustomIconWidget(
                    iconName: 'radar',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 6.w,
                  ),
                );
              },
            )
          : CustomIconWidget(
              iconName: 'search',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 6.w,
            ),
      label: Text(
        widget.isScanning ? 'Scanning...' : 'Scan Network',
        style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.lightTheme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmergencyFabWidget extends StatefulWidget {
  final VoidCallback onPressed;
  final bool hasEmergency;

  const EmergencyFabWidget({
    Key? key,
    required this.onPressed,
    required this.hasEmergency,
  }) : super(key: key);

  @override
  State<EmergencyFabWidget> createState() => _EmergencyFabWidgetState();
}

class _EmergencyFabWidgetState extends State<EmergencyFabWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.hasEmergency) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(EmergencyFabWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasEmergency != oldWidget.hasEmergency) {
      if (widget.hasEmergency) {
        _animationController.repeat(reverse: true);
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
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.hasEmergency ? _scaleAnimation.value : 1.0,
          child: FloatingActionButton.extended(
            onPressed: widget.onPressed,
            backgroundColor: widget.hasEmergency
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.tertiary,
            foregroundColor: Colors.white,
            elevation: widget.hasEmergency ? 8.0 : 4.0,
            icon: CustomIconWidget(
              iconName: widget.hasEmergency ? 'warning' : 'emergency',
              color: Colors.white,
              size: 6.w,
            ),
            label: Text(
              widget.hasEmergency ? 'EMERGENCY' : 'Emergency Stop',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}

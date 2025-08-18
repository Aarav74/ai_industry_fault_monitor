import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SensorCardWidget extends StatelessWidget {
  final String sensorName;
  final String value;
  final String unit;
  final String status;
  final String iconName;
  final List<double> trendData;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SensorCardWidget({
    Key? key,
    required this.sensorName,
    required this.value,
    required this.unit,
    required this.status,
    required this.iconName,
    required this.trendData,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'normal':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'warning':
        return const Color(0xFFF57C00);
      case 'critical':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  Color _getBackgroundColor() {
    switch (status.toLowerCase()) {
      case 'normal':
        return AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1);
      case 'warning':
        return const Color(0xFFF57C00).withValues(alpha: 0.1);
      case 'critical':
        return AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1);
      default:
        return AppTheme.lightTheme.colorScheme.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: _getStatusColor().withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: _getStatusColor(),
                      size: 5.w,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sensorName,
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusS),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 8.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: AppTheme.lightTheme.textTheme.headlineMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _getStatusColor(),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          unit,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 6.h,
                      child: CustomPaint(
                        painter: SparklinePainter(
                          data: trendData,
                          color: _getStatusColor(),
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) return;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minValue) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

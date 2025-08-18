import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ChartLegendWidget extends StatelessWidget {
  final List<String> sensorNames;
  final Map<String, bool> sensorVisibility;
  final Function(String, bool) onVisibilityChanged;

  const ChartLegendWidget({
    Key? key,
    required this.sensorNames,
    required this.sensorVisibility,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sensor Visibility',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 3.w,
            runSpacing: 1.h,
            children: sensorNames.map((sensorName) {
              final isVisible = sensorVisibility[sensorName] ?? true;
              return GestureDetector(
                onTap: () => onVisibilityChanged(sensorName, !isVisible),
                child: AnimatedContainer(
                  duration: AppTheme.fastAnimation,
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isVisible
                        ? _getSensorColor(sensorName).withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: isVisible
                          ? _getSensorColor(sensorName)
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isVisible
                              ? _getSensorColor(sensorName)
                              : AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        sensorName,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: isVisible
                              ? AppTheme.lightTheme.colorScheme.onSurface
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                          fontWeight:
                              isVisible ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      CustomIconWidget(
                        iconName: isVisible ? 'visibility' : 'visibility_off',
                        color: isVisible
                            ? _getSensorColor(sensorName)
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getSensorColor(String sensorName) {
    switch (sensorName.toLowerCase()) {
      case 'temperature':
        return const Color(0xFFFF6B35);
      case 'humidity':
        return const Color(0xFF2E7D32);
      case 'gas (lpg)':
        return const Color(0xFFF57C00);
      case 'gas (co2)':
        return const Color(0xFF9C27B0);
      case 'current':
        return const Color(0xFF1976D2);
      case 'voltage':
        return const Color(0xFFD32F2F);
      case 'motion':
        return const Color(0xFF388E3C);
      case 'flame':
        return const Color(0xFFFF5722);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}

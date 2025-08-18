import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class StatisticsCardWidget extends StatelessWidget {
  final String sensorName;
  final Map<String, dynamic> statistics;
  final bool isVisible;

  const StatisticsCardWidget({
    Key? key,
    required this.sensorName,
    required this.statistics,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      width: 80.w,
      margin: EdgeInsets.only(right: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getSensorColor(sensorName).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: CustomIconWidget(
                  iconName: _getSensorIcon(sensorName),
                  color: _getSensorColor(sensorName),
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  sensorName,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildStatRow('Min', statistics['min'], _getUnit(sensorName)),
          SizedBox(height: 1.h),
          _buildStatRow('Max', statistics['max'], _getUnit(sensorName)),
          SizedBox(height: 1.h),
          _buildStatRow('Avg', statistics['average'], _getUnit(sensorName)),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: (statistics['trend'] as double) >= 0
                    ? 'trending_up'
                    : 'trending_down',
                color: (statistics['trend'] as double) >= 0
                    ? AppTheme.statusColors['success']!
                    : AppTheme.statusColors['error']!,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                '${(statistics['trend'] as double).abs().toStringAsFixed(1)}%',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: (statistics['trend'] as double) >= 0
                      ? AppTheme.statusColors['success']!
                      : AppTheme.statusColors['error']!,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 1.w),
              Text(
                'vs last period',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, dynamic value, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
        Text(
          '${(value as num).toStringAsFixed(1)}$unit',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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

  String _getSensorIcon(String sensorName) {
    switch (sensorName.toLowerCase()) {
      case 'temperature':
        return 'thermostat';
      case 'humidity':
        return 'water_drop';
      case 'gas (lpg)':
      case 'gas (co2)':
        return 'air';
      case 'current':
        return 'electric_bolt';
      case 'voltage':
        return 'power';
      case 'motion':
        return 'directions_run';
      case 'flame':
        return 'local_fire_department';
      default:
        return 'sensors';
    }
  }

  String _getUnit(String sensorName) {
    switch (sensorName.toLowerCase()) {
      case 'temperature':
        return '°C';
      case 'humidity':
        return '%';
      case 'gas (lpg)':
      case 'gas (co2)':
        return 'ppm';
      case 'current':
        return 'A';
      case 'voltage':
        return 'V';
      case 'motion':
      case 'flame':
        return '';
      default:
        return '';
    }
  }
}

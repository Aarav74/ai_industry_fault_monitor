import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RefreshIntervalsSection extends StatefulWidget {
  final Map<String, int> refreshIntervals;
  final Function(String, int) onIntervalChanged;

  const RefreshIntervalsSection({
    Key? key,
    required this.refreshIntervals,
    required this.onIntervalChanged,
  }) : super(key: key);

  @override
  State<RefreshIntervalsSection> createState() =>
      _RefreshIntervalsSectionState();
}

class _RefreshIntervalsSectionState extends State<RefreshIntervalsSection> {
  final List<Map<String, dynamic>> sensorTypes = [
    {
      'key': 'temperature',
      'name': 'Temperature Sensors',
      'icon': Icons.thermostat,
      'color': Color(0xFFFF6B35),
    },
    {
      'key': 'humidity',
      'name': 'Humidity Sensors',
      'icon': Icons.water_drop,
      'color': Color(0xFF1976D2),
    },
    {
      'key': 'gas',
      'name': 'Gas Sensors',
      'icon': Icons.air,
      'color': Color(0xFF2E7D32),
    },
    {
      'key': 'electrical',
      'name': 'Electrical Sensors',
      'icon': Icons.electrical_services,
      'color': Color(0xFFF57C00),
    },
    {
      'key': 'motion',
      'name': 'Motion & IR Sensors',
      'icon': Icons.sensors,
      'color': Color(0xFF9C27B0),
    },
    {
      'key': 'safety',
      'name': 'Safety Sensors',
      'icon': Icons.security,
      'color': Color(0xFFD32F2F),
    },
  ];

  final List<int> intervalOptions = [1, 2, 5, 10, 15, 30, 60];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'refresh',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Refresh Intervals',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: AppTheme.dividerLight,
            height: 1,
            indent: 4.w,
            endIndent: 4.w,
          ),
          ...sensorTypes
              .map((sensorType) => _buildIntervalSelector(sensorType)),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.statusColors['warning']!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color:
                      AppTheme.statusColors['warning']!.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.statusColors['warning']!,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Shorter intervals provide real-time data but may increase battery usage and network load.',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.statusColors['warning']!,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildIntervalSelector(Map<String, dynamic> sensorType) {
    final String key = sensorType['key'] as String;
    final String name = sensorType['name'] as String;
    final IconData icon = sensorType['icon'] as IconData;
    final Color color = sensorType['color'] as Color;
    final int currentInterval = widget.refreshIntervals[key] ?? 5;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: CustomIconWidget(
                  iconName: icon.codePoint.toString(),
                  color: color,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Every ${currentInterval}s',
                      style: AppTheme.dataTextTheme(isLight: true)
                          .bodySmall
                          ?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showIntervalPicker(key, name, currentInterval),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: AppTheme.lightTheme.primaryColor
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${currentInterval}s',
                        style: AppTheme.dataTextTheme(isLight: true)
                            .labelMedium
                            ?.copyWith(
                              color: AppTheme.lightTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: 'keyboard_arrow_down',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 4.w,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showIntervalPicker(String key, String sensorName, int currentInterval) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Refresh Interval',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 1.h),
            Text(
              sensorName,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              height: 20.h,
              child: ListView.builder(
                itemCount: intervalOptions.length,
                itemBuilder: (context, index) {
                  final interval = intervalOptions[index];
                  final isSelected = interval == currentInterval;

                  return ListTile(
                    title: Text(
                      '${interval} second${interval == 1 ? '' : 's'}',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      _getIntervalDescription(interval),
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                    trailing: isSelected
                        ? CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 6.w,
                          )
                        : null,
                    onTap: () {
                      widget.onIntervalChanged(key, interval);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  String _getIntervalDescription(int interval) {
    switch (interval) {
      case 1:
        return 'Real-time monitoring (high battery usage)';
      case 2:
        return 'Near real-time (high battery usage)';
      case 5:
        return 'Recommended for critical sensors';
      case 10:
        return 'Balanced performance and battery';
      case 15:
        return 'Good for general monitoring';
      case 30:
        return 'Standard monitoring interval';
      case 60:
        return 'Low battery usage';
      default:
        return 'Custom interval';
    }
  }
}

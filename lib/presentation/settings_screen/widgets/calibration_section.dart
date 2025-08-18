import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalibrationSection extends StatefulWidget {
  final Map<String, double> calibrationValues;
  final Function(String, double) onCalibrationChanged;
  final VoidCallback onResetCalibration;

  const CalibrationSection({
    Key? key,
    required this.calibrationValues,
    required this.onCalibrationChanged,
    required this.onResetCalibration,
  }) : super(key: key);

  @override
  State<CalibrationSection> createState() => _CalibrationSectionState();
}

class _CalibrationSectionState extends State<CalibrationSection> {
  final Map<String, TextEditingController> _controllers = {};

  final List<Map<String, dynamic>> calibrationSensors = [
    {
      'key': 'temperature',
      'name': 'Temperature Offset',
      'unit': '°C',
      'icon': Icons.thermostat,
      'color': Color(0xFFFF6B35),
      'min': -10.0,
      'max': 10.0,
      'description': 'Adjust temperature readings',
    },
    {
      'key': 'humidity',
      'name': 'Humidity Offset',
      'unit': '%',
      'icon': Icons.water_drop,
      'color': Color(0xFF1976D2),
      'min': -20.0,
      'max': 20.0,
      'description': 'Adjust humidity readings',
    },
    {
      'key': 'gas_lpg',
      'name': 'LPG Sensitivity',
      'unit': 'ppm',
      'icon': Icons.air,
      'color': Color(0xFF2E7D32),
      'min': -100.0,
      'max': 100.0,
      'description': 'Adjust LPG sensor sensitivity',
    },
    {
      'key': 'gas_co2',
      'name': 'CO2 Sensitivity',
      'unit': 'ppm',
      'icon': Icons.air,
      'color': Color(0xFF388E3C),
      'min': -50.0,
      'max': 50.0,
      'description': 'Adjust CO2 sensor sensitivity',
    },
    {
      'key': 'current',
      'name': 'Current Offset',
      'unit': 'A',
      'icon': Icons.electrical_services,
      'color': Color(0xFFF57C00),
      'min': -5.0,
      'max': 5.0,
      'description': 'Adjust current sensor readings',
    },
    {
      'key': 'voltage',
      'name': 'Voltage Offset',
      'unit': 'V',
      'icon': Icons.electrical_services,
      'color': Color(0xFFFF9800),
      'min': -2.0,
      'max': 2.0,
      'description': 'Adjust voltage sensor readings',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final sensor in calibrationSensors) {
      final key = sensor['key'] as String;
      final value = widget.calibrationValues[key] ?? 0.0;
      _controllers[key] = TextEditingController(text: value.toStringAsFixed(2));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

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
                  iconName: 'tune',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Sensor Calibration',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showResetConfirmation,
                  icon: CustomIconWidget(
                    iconName: 'restore',
                    color: AppTheme.statusColors['warning']!,
                    size: 4.w,
                  ),
                  label: Text(
                    'Reset All',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.statusColors['warning']!,
                      fontWeight: FontWeight.w500,
                    ),
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
          ...calibrationSensors
              .map((sensor) => _buildCalibrationControl(sensor)),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.statusColors['info']!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: AppTheme.statusColors['info']!.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.statusColors['info']!,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Calibration values are applied to raw sensor readings. Use certified reference instruments for accurate calibration.',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.statusColors['info']!,
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

  Widget _buildCalibrationControl(Map<String, dynamic> sensor) {
    final String key = sensor['key'] as String;
    final String name = sensor['name'] as String;
    final String unit = sensor['unit'] as String;
    final IconData icon = sensor['icon'] as IconData;
    final Color color = sensor['color'] as Color;
    final double min = sensor['min'] as double;
    final double max = sensor['max'] as double;
    final String description = sensor['description'] as String;
    final TextEditingController controller = _controllers[key]!;

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
                      description,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.dividerLight.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: TextFormField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^-?\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 2.h,
                      ),
                      suffixText: unit,
                      suffixStyle: AppTheme.dataTextTheme(isLight: true)
                          .bodyMedium
                          ?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    style: AppTheme.dataTextTheme(isLight: true).bodyMedium,
                    onChanged: (value) {
                      final double? parsedValue = double.tryParse(value);
                      if (parsedValue != null &&
                          parsedValue >= min &&
                          parsedValue <= max) {
                        widget.onCalibrationChanged(key, parsedValue);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          min.toStringAsFixed(1),
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                        Text(
                          max.toStringAsFixed(1),
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: color,
                        thumbColor: color,
                        overlayColor: color.withValues(alpha: 0.2),
                        inactiveTrackColor: color.withValues(alpha: 0.3),
                        trackHeight: 3.0,
                      ),
                      child: Slider(
                        value: (widget.calibrationValues[key] ?? 0.0)
                            .clamp(min, max),
                        min: min,
                        max: max,
                        divisions: ((max - min) * 10).round(),
                        onChanged: (value) {
                          controller.text = value.toStringAsFixed(2);
                          widget.onCalibrationChanged(key, value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Calibration',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to reset all calibration values to zero? This will affect sensor accuracy.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onResetCalibration();
              _resetControllers();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusColors['warning'],
            ),
            child: Text(
              'Reset All',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetControllers() {
    for (final controller in _controllers.values) {
      controller.text = '0.00';
    }
  }
}

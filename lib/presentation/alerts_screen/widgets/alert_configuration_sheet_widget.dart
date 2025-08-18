import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AlertConfigurationSheetWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onSaveConfiguration;

  const AlertConfigurationSheetWidget({
    Key? key,
    required this.onSaveConfiguration,
  }) : super(key: key);

  @override
  State<AlertConfigurationSheetWidget> createState() =>
      _AlertConfigurationSheetWidgetState();
}

class _AlertConfigurationSheetWidgetState
    extends State<AlertConfigurationSheetWidget> {
  final Map<String, Map<String, TextEditingController>> _controllers = {};
  final Map<String, bool> _enabledSensors = {};

  final List<Map<String, dynamic>> _sensorTypes = [
    {
      'type': 'temperature',
      'name': 'Temperature',
      'icon': 'thermostat',
      'unit': '°C',
      'defaultMin': '0',
      'defaultMax': '50',
      'criticalMax': '80',
    },
    {
      'type': 'humidity',
      'name': 'Humidity',
      'icon': 'water_drop',
      'unit': '%',
      'defaultMin': '30',
      'defaultMax': '70',
      'criticalMax': '90',
    },
    {
      'type': 'gas_lpg',
      'name': 'LPG Gas',
      'icon': 'air',
      'unit': 'ppm',
      'defaultMin': '0',
      'defaultMax': '1000',
      'criticalMax': '5000',
    },
    {
      'type': 'gas_co2',
      'name': 'CO2 Gas',
      'icon': 'air',
      'unit': 'ppm',
      'defaultMin': '0',
      'defaultMax': '1000',
      'criticalMax': '5000',
    },
    {
      'type': 'current',
      'name': 'Current',
      'icon': 'electrical_services',
      'unit': 'A',
      'defaultMin': '0',
      'defaultMax': '10',
      'criticalMax': '20',
    },
    {
      'type': 'voltage',
      'name': 'Voltage',
      'icon': 'bolt',
      'unit': 'V',
      'defaultMin': '0',
      'defaultMax': '240',
      'criticalMax': '280',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final sensor in _sensorTypes) {
      final type = sensor['type'] as String;
      _controllers[type] = {
        'minWarning':
            TextEditingController(text: sensor['defaultMin'] as String),
        'maxWarning':
            TextEditingController(text: sensor['defaultMax'] as String),
        'maxCritical':
            TextEditingController(text: sensor['criticalMax'] as String),
      };
      _enabledSensors[type] = true;
    }
  }

  @override
  void dispose() {
    for (final controllerMap in _controllers.values) {
      for (final controller in controllerMap.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              children: [
                _buildInstructions(),
                SizedBox(height: 2.h),
                ..._sensorTypes
                    .map((sensor) => _buildSensorConfiguration(sensor)),
                SizedBox(height: 10.h),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'settings',
            color: AppTheme.lightTheme.primaryColor,
            size: 24.sp,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Alert Configuration',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.textSecondaryLight,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.statusColors['info']!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: AppTheme.statusColors['info']!.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(
            iconName: 'info',
            color: AppTheme.statusColors['info'],
            size: 20.sp,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration Guide',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.statusColors['info'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Set threshold values for each sensor type. Warning alerts trigger when values exceed the warning range. Critical alerts trigger when values exceed the critical threshold.',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorConfiguration(Map<String, dynamic> sensor) {
    final type = sensor['type'] as String;
    final isEnabled = _enabledSensors[type] ?? true;

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: isEnabled
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3)
              : AppTheme.dividerLight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSensorHeader(sensor, isEnabled),
          if (isEnabled) _buildThresholdInputs(sensor),
        ],
      ),
    );
  }

  Widget _buildSensorHeader(Map<String, dynamic> sensor, bool isEnabled) {
    final type = sensor['type'] as String;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: isEnabled
                  ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                  : AppTheme.textDisabledLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: sensor['icon'] as String,
                color: isEnabled
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.textDisabledLight,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sensor['name'] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isEnabled
                        ? AppTheme.textPrimaryLight
                        : AppTheme.textDisabledLight,
                  ),
                ),
                Text(
                  'Unit: ${sensor['unit']}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              setState(() {
                _enabledSensors[type] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdInputs(Map<String, dynamic> sensor) {
    final type = sensor['type'] as String;
    final controllers = _controllers[type]!;
    final unit = sensor['unit'] as String;

    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
      child: Column(
        children: [
          Divider(color: AppTheme.dividerLight),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildThresholdInput(
                  'Min Warning',
                  controllers['minWarning']!,
                  unit,
                  AppTheme.statusColors['warning']!,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildThresholdInput(
                  'Max Warning',
                  controllers['maxWarning']!,
                  unit,
                  AppTheme.statusColors['warning']!,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildThresholdInput(
            'Critical Threshold',
            controllers['maxCritical']!,
            unit,
            AppTheme.statusColors['critical']!,
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdInput(
    String label,
    TextEditingController controller,
    String unit,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.5.h),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: unit,
            suffixStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(color: color, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(
                color: AppTheme.dividerLight.withValues(alpha: 0.12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveConfiguration,
                child: const Text('Save Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveConfiguration() {
    final configuration = <String, dynamic>{};

    for (final sensor in _sensorTypes) {
      final type = sensor['type'] as String;
      final isEnabled = _enabledSensors[type] ?? true;

      if (isEnabled) {
        final controllers = _controllers[type]!;
        configuration[type] = {
          'enabled': true,
          'minWarning': double.tryParse(controllers['minWarning']!.text) ?? 0.0,
          'maxWarning':
              double.tryParse(controllers['maxWarning']!.text) ?? 100.0,
          'maxCritical':
              double.tryParse(controllers['maxCritical']!.text) ?? 200.0,
          'unit': sensor['unit'],
        };
      } else {
        configuration[type] = {'enabled': false};
      }
    }

    widget.onSaveConfiguration(configuration);
    Navigator.pop(context);
  }
}

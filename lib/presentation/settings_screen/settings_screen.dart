import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/about_section.dart';
import './widgets/calibration_section.dart';
import './widgets/data_management_section.dart';
import './widgets/device_management_section.dart';
import './widgets/notification_settings_section.dart';
import './widgets/refresh_intervals_section.dart';
import './widgets/theme_selection_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock data for ESP32 devices
  final List<Map<String, dynamic>> savedDevices = [
    {
      "id": "esp32_001",
      "name": "Production Line A",
      "ipAddress": "192.168.1.100",
      "status": "online",
      "sensorCount": 8,
      "lastConnection": DateTime.now().subtract(const Duration(minutes: 2)),
    },
    {
      "id": "esp32_002",
      "name": "Quality Control Station",
      "ipAddress": "192.168.1.101",
      "status": "offline",
      "sensorCount": 6,
      "lastConnection": DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      "id": "esp32_003",
      "name": "Safety Monitoring Hub",
      "ipAddress": "192.168.1.102",
      "status": "error",
      "sensorCount": 10,
      "lastConnection": DateTime.now().subtract(const Duration(minutes: 15)),
    },
  ];

  // Notification settings
  Map<String, bool> notificationSettings = {
    'criticalAlerts': true,
    'warningAlerts': true,
    'systemAlerts': false,
    'maintenanceAlerts': true,
    'soundEnabled': true,
    'vibrationEnabled': true,
    'pushNotifications': true,
  };

  // Data management settings
  Map<String, dynamic> dataSettings = {
    'exportFrequency': 'weekly',
    'storageLimit': 150,
    'retentionDays': 90,
  };

  // Theme settings
  String currentTheme = 'auto';

  // Refresh intervals (in seconds)
  Map<String, int> refreshIntervals = {
    'temperature': 5,
    'humidity': 10,
    'gas': 2,
    'electrical': 5,
    'motion': 1,
    'safety': 1,
  };

  // Calibration values
  Map<String, double> calibrationValues = {
    'temperature': 0.0,
    'humidity': 0.0,
    'gas_lpg': 0.0,
    'gas_co2': 0.0,
    'current': 0.0,
    'voltage': 0.0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 2,
        shadowColor: AppTheme.shadowLight,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showQuickActions(),
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),

            // Device Management Section
            DeviceManagementSection(
              savedDevices: savedDevices,
              onEditDevice: _editDevice,
              onDeleteDevice: _deleteDevice,
              onTestConnection: _testConnection,
            ),

            // Notification Settings Section
            NotificationSettingsSection(
              notificationSettings: notificationSettings,
              onSettingChanged: _updateNotificationSetting,
            ),

            // Data Management Section
            DataManagementSection(
              dataSettings: dataSettings,
              onSettingChanged: _updateDataSetting,
              onClearCache: _clearCache,
              onExportData: _exportData,
            ),

            // Theme Selection Section
            ThemeSelectionSection(
              currentTheme: currentTheme,
              onThemeChanged: _updateTheme,
            ),

            // Refresh Intervals Section
            RefreshIntervalsSection(
              refreshIntervals: refreshIntervals,
              onIntervalChanged: _updateRefreshInterval,
            ),

            // Calibration Section
            CalibrationSection(
              calibrationValues: calibrationValues,
              onCalibrationChanged: _updateCalibration,
              onResetCalibration: _resetCalibration,
            ),

            // About Section
            AboutSection(
              onBackupRestore: _backupRestore,
              onFactoryReset: _factoryReset,
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  void _editDevice(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Device',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: device['name'] as String,
              decoration: const InputDecoration(
                labelText: 'Device Name',
                border: OutlineInputBorder(),
              ),
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            TextFormField(
              initialValue: device['ipAddress'] as String,
              decoration: const InputDecoration(
                labelText: 'IP Address',
                border: OutlineInputBorder(),
              ),
              style: AppTheme.dataTextTheme(isLight: true).bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('Device updated successfully');
            },
            child: Text(
              'Save',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteDevice(String deviceId) {
    setState(() {
      savedDevices.removeWhere((device) => device['id'] == deviceId);
    });
    _showSuccessMessage('Device removed successfully');
  }

  void _testConnection(String deviceId) {
    final device = savedDevices.firstWhere((d) => d['id'] == deviceId);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.lightTheme.primaryColor,
            ),
            SizedBox(height: 2.h),
            Text(
              'Testing connection to ${device['name']}...',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Simulate connection test
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      final bool isSuccess = DateTime.now().millisecond % 2 == 0;

      if (isSuccess) {
        setState(() {
          final deviceIndex =
              savedDevices.indexWhere((d) => d['id'] == deviceId);
          if (deviceIndex != -1) {
            savedDevices[deviceIndex]['status'] = 'online';
            savedDevices[deviceIndex]['lastConnection'] = DateTime.now();
          }
        });
        _showSuccessMessage('Connection successful');
      } else {
        _showErrorMessage('Connection failed - Check IP address and network');
      }
    });
  }

  void _updateNotificationSetting(String key, bool value) {
    setState(() {
      notificationSettings[key] = value;
    });
  }

  void _updateDataSetting(String key, dynamic value) {
    setState(() {
      dataSettings[key] = value;
    });
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Cache',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'This will clear temporary files and free up storage space. Historical sensor data will not be affected.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('Cache cleared successfully - 45MB freed');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusColors['warning'],
            ),
            child: Text(
              'Clear Cache',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.lightTheme.primaryColor,
            ),
            SizedBox(height: 2.h),
            Text(
              'Exporting sensor data...',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Simulate data export
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pop(context);
      _showSuccessMessage(
          'Data exported successfully - sensor_data_20250818.csv');
    });
  }

  void _updateTheme(String theme) {
    setState(() {
      currentTheme = theme;
    });
    _showSuccessMessage('Theme updated - Restart app to apply changes');
  }

  void _updateRefreshInterval(String sensorType, int interval) {
    setState(() {
      refreshIntervals[sensorType] = interval;
    });
  }

  void _updateCalibration(String sensorType, double value) {
    setState(() {
      calibrationValues[sensorType] = value;
    });
  }

  void _resetCalibration() {
    setState(() {
      calibrationValues.updateAll((key, value) => 0.0);
    });
    _showSuccessMessage('All calibration values reset to zero');
  }

  void _backupRestore() {
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
              'Backup & Restore',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'cloud_upload',
                color: AppTheme.statusColors['info']!,
                size: 6.w,
              ),
              title: Text(
                'Backup Settings',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Export current configuration',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              onTap: () {
                Navigator.pop(context);
                _showSuccessMessage(
                    'Settings backed up - ai_fault_backup_20250818.json');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'cloud_download',
                color: AppTheme.statusColors['healthy']!,
                size: 6.w,
              ),
              title: Text(
                'Restore Settings',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Import configuration from file',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              onTap: () {
                Navigator.pop(context);
                _showSuccessMessage('Settings restored successfully');
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _factoryReset() {
    // Simulate factory reset
    setState(() {
      savedDevices.clear();
      notificationSettings.updateAll((key, value) => false);
      dataSettings = {
        'exportFrequency': 'manual',
        'storageLimit': 100,
        'retentionDays': 30,
      };
      currentTheme = 'auto';
      refreshIntervals.updateAll((key, value) => 5);
      calibrationValues.updateAll((key, value) => 0.0);
    });
    _showSuccessMessage('Factory reset completed - App will restart');
  }

  void _showQuickActions() {
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
              'Quick Actions',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.statusColors['info']!,
                size: 6.w,
              ),
              title: Text(
                'Refresh All Connections',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _showSuccessMessage('All device connections refreshed');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.statusColors['healthy']!,
                size: 6.w,
              ),
              title: Text(
                'Share Configuration',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _showSuccessMessage('Configuration shared successfully');
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.statusColors['healthy'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.statusColors['error'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

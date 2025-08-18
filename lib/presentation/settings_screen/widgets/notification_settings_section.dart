import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationSettingsSection extends StatefulWidget {
  final Map<String, bool> notificationSettings;
  final Function(String, bool) onSettingChanged;

  const NotificationSettingsSection({
    Key? key,
    required this.notificationSettings,
    required this.onSettingChanged,
  }) : super(key: key);

  @override
  State<NotificationSettingsSection> createState() =>
      _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState
    extends State<NotificationSettingsSection> {
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
                  iconName: 'notifications',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Notification Settings',
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
          _buildNotificationToggle(
            'criticalAlerts',
            'Critical Alerts',
            'High priority sensor alerts',
            Icons.warning,
            AppTheme.statusColors['critical']!,
          ),
          _buildNotificationToggle(
            'warningAlerts',
            'Warning Alerts',
            'Medium priority sensor warnings',
            Icons.info,
            AppTheme.statusColors['warning']!,
          ),
          _buildNotificationToggle(
            'systemAlerts',
            'System Alerts',
            'Device connection and system status',
            Icons.router,
            AppTheme.statusColors['info']!,
          ),
          _buildNotificationToggle(
            'maintenanceAlerts',
            'Maintenance Alerts',
            'Scheduled maintenance reminders',
            Icons.build,
            AppTheme.statusColors['maintenance']!,
          ),
          Divider(
            color: AppTheme.dividerLight.withValues(alpha: 0.5),
            height: 1,
            indent: 4.w,
            endIndent: 4.w,
          ),
          _buildNotificationToggle(
            'soundEnabled',
            'Sound Notifications',
            'Play sound for alerts',
            Icons.volume_up,
            AppTheme.lightTheme.primaryColor,
          ),
          _buildNotificationToggle(
            'vibrationEnabled',
            'Vibration',
            'Vibrate device for alerts',
            Icons.vibration,
            AppTheme.lightTheme.primaryColor,
          ),
          _buildNotificationToggle(
            'pushNotifications',
            'Push Notifications',
            'Receive notifications when app is closed',
            Icons.notifications_active,
            AppTheme.lightTheme.primaryColor,
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(
    String key,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final bool isEnabled = widget.notificationSettings[key] ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: CustomIconWidget(
              iconName: icon.codePoint.toString(),
              color: iconColor,
              size: 5.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              widget.onSettingChanged(key, value);
            },
            activeColor: AppTheme.lightTheme.primaryColor,
            activeTrackColor:
                AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
            inactiveThumbColor:
                AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            inactiveTrackColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                .withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

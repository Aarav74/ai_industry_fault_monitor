import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DeviceManagementSection extends StatefulWidget {
  final List<Map<String, dynamic>> savedDevices;
  final Function(Map<String, dynamic>) onEditDevice;
  final Function(String) onDeleteDevice;
  final Function(String) onTestConnection;

  const DeviceManagementSection({
    Key? key,
    required this.savedDevices,
    required this.onEditDevice,
    required this.onDeleteDevice,
    required this.onTestConnection,
  }) : super(key: key);

  @override
  State<DeviceManagementSection> createState() =>
      _DeviceManagementSectionState();
}

class _DeviceManagementSectionState extends State<DeviceManagementSection> {
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
                  iconName: 'router',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Device Management',
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
          widget.savedDevices.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Center(
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: 'device_hub',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 12.w,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No ESP32 devices configured',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Add devices from the Home screen',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.savedDevices.length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppTheme.dividerLight.withValues(alpha: 0.5),
                    height: 1,
                    indent: 4.w,
                    endIndent: 4.w,
                  ),
                  itemBuilder: (context, index) {
                    final device = widget.savedDevices[index];
                    return _buildDeviceCard(device);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final String deviceId = device['id'] as String;
    final String deviceName = device['name'] as String;
    final String ipAddress = device['ipAddress'] as String;
    final String status = device['status'] as String;
    final int sensorCount = device['sensorCount'] as int;
    final DateTime lastConnection = device['lastConnection'] as DateTime;

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'online':
        statusColor = AppTheme.statusColors['healthy']!;
        statusIcon = Icons.check_circle;
        break;
      case 'offline':
        statusColor = AppTheme.statusColors['offline']!;
        statusIcon = Icons.cancel;
        break;
      case 'error':
        statusColor = AppTheme.statusColors['error']!;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = AppTheme.statusColors['warning']!;
        statusIcon = Icons.help;
    }

    return Dismissible(
      key: Key(deviceId),
      background: Container(
        color: AppTheme.statusColors['info']!,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 6.w),
        child: CustomIconWidget(
          iconName: 'edit',
          color: Colors.white,
          size: 6.w,
        ),
      ),
      secondaryBackground: Container(
        color: AppTheme.statusColors['error']!,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 6.w),
        child: CustomIconWidget(
          iconName: 'delete',
          color: Colors.white,
          size: 6.w,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(deviceName);
        } else {
          widget.onEditDevice(device);
          return false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          widget.onDeleteDevice(deviceId);
        }
      },
      child: InkWell(
        onLongPress: () => _showAdvancedOptions(device),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deviceName,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          ipAddress,
                          style: AppTheme.dataTextTheme(isLight: true)
                              .bodyMedium
                              ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          status.toUpperCase(),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
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
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'sensors',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 4.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '$sensorCount sensors',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                        SizedBox(width: 4.w),
                        CustomIconWidget(
                          iconName: 'access_time',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 4.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          _formatLastConnection(lastConnection),
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => widget.onTestConnection(deviceId),
                    icon: CustomIconWidget(
                      iconName: 'wifi_find',
                      color: Colors.white,
                      size: 4.w,
                    ),
                    label: Text(
                      'Test',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.primaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      minimumSize: Size(0, 5.h),
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

  String _formatLastConnection(DateTime lastConnection) {
    final now = DateTime.now();
    final difference = now.difference(lastConnection);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<bool?> _showDeleteConfirmation(String deviceName) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Device',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to delete "$deviceName"? This action cannot be undone.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusColors['error'],
            ),
            child: Text(
              'Delete',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdvancedOptions(Map<String, dynamic> device) {
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
              'Advanced Options',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'network_ping',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
              title: Text(
                'IP Range Scan',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Scan for devices in network range',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              onTap: () {
                Navigator.pop(context);
                // Implement IP range scanning
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings_ethernet',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
              title: Text(
                'Custom Port Configuration',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Configure custom communication port',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              onTap: () {
                Navigator.pop(context);
                // Implement custom port configuration
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'timer',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
              title: Text(
                'Connection Timeout',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Adjust connection timeout settings',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              onTap: () {
                Navigator.pop(context);
                // Implement timeout configuration
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

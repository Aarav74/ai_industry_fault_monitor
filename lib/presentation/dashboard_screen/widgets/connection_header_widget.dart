import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectionHeaderWidget extends StatelessWidget {
  final String ipAddress;
  final String connectionStatus;
  final bool isAutoRefresh;
  final VoidCallback onRefresh;
  final VoidCallback onToggleAutoRefresh;

  const ConnectionHeaderWidget({
    Key? key,
    required this.ipAddress,
    required this.connectionStatus,
    required this.isAutoRefresh,
    required this.onRefresh,
    required this.onToggleAutoRefresh,
  }) : super(key: key);

  Color _getConnectionStatusColor() {
    switch (connectionStatus.toLowerCase()) {
      case 'connected':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'connecting':
        return const Color(0xFFF57C00);
      case 'disconnected':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: _getConnectionStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: CustomIconWidget(
                    iconName: 'router',
                    color: _getConnectionStatusColor(),
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESP32 Device',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        ipAddress,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onToggleAutoRefresh,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: isAutoRefresh
                              ? AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1)
                              : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        child: CustomIconWidget(
                          iconName: 'autorenew',
                          color: isAutoRefresh
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 5.w,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: onRefresh,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        child: CustomIconWidget(
                          iconName: 'refresh',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 5.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Container(
                  width: 2.w,
                  height: 2.w,
                  decoration: BoxDecoration(
                    color: _getConnectionStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  connectionStatus.toUpperCase(),
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: _getConnectionStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'Last updated: ${DateTime.now().toString().substring(11, 19)}',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

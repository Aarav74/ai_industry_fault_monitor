import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectionStatusCardWidget extends StatelessWidget {
  final Map<String, dynamic>? connectionStatus;
  final bool isConnecting;

  const ConnectionStatusCardWidget({
    Key? key,
    this.connectionStatus,
    required this.isConnecting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (connectionStatus == null && !isConnecting) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: _getBorderColor(),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isConnecting ? _buildConnectingState() : _buildConnectionInfo(),
    );
  }

  Color _getBorderColor() {
    if (isConnecting)
      return AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3);
    if (connectionStatus == null)
      return AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.12);

    final isConnected = connectionStatus!['isConnected'] as bool? ?? false;
    return isConnected
        ? AppTheme.successLight.withValues(alpha: 0.3)
        : AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3);
  }

  Widget _buildConnectingState() {
    return Row(
      children: [
        SizedBox(
          width: 6.w,
          height: 6.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connecting to ESP32...',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Please wait while we establish connection',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionInfo() {
    final isConnected = connectionStatus!['isConnected'] as bool? ?? false;
    final deviceIp = connectionStatus!['deviceIp'] as String? ?? '';
    final sensorCount = connectionStatus!['sensorCount'] as int? ?? 0;
    final lastConnected = connectionStatus!['lastConnected'] as DateTime?;
    final deviceName =
        connectionStatus!['deviceName'] as String? ?? 'ESP32 Device';

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isConnected
                    ? AppTheme.successLight.withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.error
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: CustomIconWidget(
                iconName: isConnected ? 'wifi' : 'wifi_off',
                color: isConnected
                    ? AppTheme.successLight
                    : AppTheme.lightTheme.colorScheme.error,
                size: 6.w,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceName,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    deviceIp,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: isConnected
                    ? AppTheme.successLight.withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.error
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Text(
                isConnected ? 'ONLINE' : 'OFFLINE',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: isConnected
                      ? AppTheme.successLight
                      : AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
        if (isConnected) ...[
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Sensors',
                  sensorCount.toString(),
                  'sensors',
                ),
              ),
              Container(
                width: 1,
                height: 4.h,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.12),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Last Update',
                  _formatLastConnected(lastConnected),
                  'update',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, String iconName) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.textSecondaryLight,
            size: 5.w,
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontSize: 11.sp,
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastConnected(DateTime? lastConnected) {
    if (lastConnected == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastConnected);

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
}

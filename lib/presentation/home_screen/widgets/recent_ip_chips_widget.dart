import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentIpChipsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> recentIps;
  final Function(String) onIpSelected;
  final Function(String) onIpDeleted;

  const RecentIpChipsWidget({
    Key? key,
    required this.recentIps,
    required this.onIpSelected,
    required this.onIpDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recentIps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Recent Connections',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        SizedBox(
          height: 6.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: recentIps.length,
            separatorBuilder: (context, index) => SizedBox(width: 2.w),
            itemBuilder: (context, index) {
              final ipData = recentIps[index];
              final ip = ipData['ip'] as String;
              final isOnline = ipData['isOnline'] as bool? ?? false;
              final lastConnected = ipData['lastConnected'] as DateTime?;

              return Dismissible(
                key: Key(ip),
                direction: DismissDirection.up,
                onDismissed: (direction) => onIpDeleted(ip),
                background: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.error,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'delete',
                      color: AppTheme.lightTheme.colorScheme.onError,
                      size: 5.w,
                    ),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => onIpSelected(ip),
                  onLongPress: () => _showIpContextMenu(context, ip),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      border: Border.all(
                        color: isOnline
                            ? AppTheme.successLight.withValues(alpha: 0.3)
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowLight,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 2.w,
                          height: 2.w,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? AppTheme.successLight
                                : AppTheme.lightTheme.colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          ip,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimaryLight,
                          ),
                        ),
                        if (lastConnected != null) ...[
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName: 'access_time',
                            color: AppTheme.textSecondaryLight,
                            size: 3.w,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showIpContextMenu(BuildContext context, String ip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusL),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              ip,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text(
                'Rename Device',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement rename functionality
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 6.w,
              ),
              title: Text(
                'Delete',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onIpDeleted(ip);
              },
            ),
          ],
        ),
      ),
    );
  }
}

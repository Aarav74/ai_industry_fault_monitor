import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AlertSummaryBadgesWidget extends StatelessWidget {
  final int criticalCount;
  final int warningCount;
  final int infoCount;

  const AlertSummaryBadgesWidget({
    Key? key,
    required this.criticalCount,
    required this.warningCount,
    required this.infoCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBadge(
            context,
            'Critical',
            criticalCount,
            AppTheme.statusColors['critical']!,
            CustomIconWidget(
              iconName: 'error',
              color: Colors.white,
              size: 16.sp,
            ),
          ),
          _buildBadge(
            context,
            'Warning',
            warningCount,
            AppTheme.statusColors['warning']!,
            CustomIconWidget(
              iconName: 'warning',
              color: Colors.white,
              size: 16.sp,
            ),
          ),
          _buildBadge(
            context,
            'Info',
            infoCount,
            AppTheme.statusColors['info']!,
            CustomIconWidget(
              iconName: 'info',
              color: Colors.white,
              size: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    String label,
    int count,
    Color color,
    Widget icon,
  ) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(height: 0.5.h),
            Text(
              count.toString(),
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 10.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

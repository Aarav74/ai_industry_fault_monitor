import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AboutSection extends StatefulWidget {
  final VoidCallback onBackupRestore;
  final VoidCallback onFactoryReset;

  const AboutSection({
    Key? key,
    required this.onBackupRestore,
    required this.onFactoryReset,
  }) : super(key: key);

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
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
                  iconName: 'info',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'About & Support',
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
          _buildInfoItem(
            'App Version',
            'v2.1.3 (Build 2025081801)',
            Icons.smartphone,
            AppTheme.statusColors['info']!,
          ),
          _buildInfoItem(
            'ESP32 Firmware Compatibility',
            'v1.8.0 and above',
            Icons.memory,
            AppTheme.statusColors['healthy']!,
          ),
          _buildInfoItem(
            'Last Updated',
            'August 18, 2025',
            Icons.update,
            AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          Divider(
            color: AppTheme.dividerLight.withValues(alpha: 0.5),
            height: 1,
            indent: 4.w,
            endIndent: 4.w,
          ),
          _buildCertificationSection(),
          Divider(
            color: AppTheme.dividerLight.withValues(alpha: 0.5),
            height: 1,
            indent: 4.w,
            endIndent: 4.w,
          ),
          _buildActionButton(
            'Backup & Restore Settings',
            'Export or import app configuration',
            Icons.backup,
            AppTheme.statusColors['info']!,
            widget.onBackupRestore,
          ),
          _buildActionButton(
            'Factory Reset',
            'Reset all settings to default values',
            Icons.restore,
            AppTheme.statusColors['error']!,
            () => _showFactoryResetConfirmation(),
          ),
          _buildActionButton(
            'Technical Support',
            'Get help with industrial deployment',
            Icons.support_agent,
            AppTheme.statusColors['healthy']!,
            () => _showSupportOptions(),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      String title, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                  value,
                  style: AppTheme.dataTextTheme(isLight: true)
                      .bodyMedium
                      ?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationSection() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Industrial Certifications',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              _buildCertificationBadge(
                  'ISO 27001', AppTheme.statusColors['healthy']!),
              _buildCertificationBadge(
                  'IEC 61508', AppTheme.statusColors['info']!),
              _buildCertificationBadge(
                  'NIST Compliant', AppTheme.statusColors['success']!),
              _buildCertificationBadge(
                  'CE Marked', AppTheme.lightTheme.primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationBadge(String certification, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        certification,
        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
            CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }

  void _showFactoryResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: AppTheme.statusColors['error']!,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Factory Reset',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete:',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            ...[
              'All saved ESP32 devices',
              'Notification preferences',
              'Calibration settings',
              'Historical sensor data',
              'Theme and display settings'
            ].map(
              (item) => Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 0.5.h),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'circle',
                      color: AppTheme.statusColors['error']!,
                      size: 2.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.statusColors['error']!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Text(
                'This action cannot be undone. Consider backing up your settings first.',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.statusColors['error']!,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
              widget.onFactoryReset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusColors['error'],
            ),
            child: Text(
              'Reset Everything',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportOptions() {
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
              'Technical Support',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'email',
                color: AppTheme.statusColors['info']!,
                size: 6.w,
              ),
              title: Text(
                'Email Support',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'support@aiindustryfault.com',
                style: AppTheme.dataTextTheme(isLight: true)
                    .bodySmall
                    ?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implement email support
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'phone',
                color: AppTheme.statusColors['healthy']!,
                size: 6.w,
              ),
              title: Text(
                '24/7 Industrial Hotline',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              subtitle: Text(
                '+1 (800) 555-FAULT',
                style: AppTheme.dataTextTheme(isLight: true)
                    .bodySmall
                    ?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implement phone support
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'help',
                color: AppTheme.statusColors['warning']!,
                size: 6.w,
              ),
              title: Text(
                'Documentation & FAQ',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Access installation guides and troubleshooting',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              onTap: () {
                Navigator.pop(context);
                // Implement documentation access
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

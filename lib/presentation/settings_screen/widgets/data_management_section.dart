import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DataManagementSection extends StatefulWidget {
  final Map<String, dynamic> dataSettings;
  final Function(String, dynamic) onSettingChanged;
  final VoidCallback onClearCache;
  final VoidCallback onExportData;

  const DataManagementSection({
    Key? key,
    required this.dataSettings,
    required this.onSettingChanged,
    required this.onClearCache,
    required this.onExportData,
  }) : super(key: key);

  @override
  State<DataManagementSection> createState() => _DataManagementSectionState();
}

class _DataManagementSectionState extends State<DataManagementSection> {
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
                  iconName: 'storage',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Data Management',
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
          _buildExportFrequencySelector(),
          _buildStorageLimitSelector(),
          _buildRetentionPolicySelector(),
          Divider(
            color: AppTheme.dividerLight.withValues(alpha: 0.5),
            height: 1,
            indent: 4.w,
            endIndent: 4.w,
          ),
          _buildActionButton(
            'Export Data',
            'Export sensor data to CSV file',
            Icons.file_download,
            AppTheme.statusColors['info']!,
            widget.onExportData,
          ),
          _buildActionButton(
            'Clear Cache',
            'Free up storage space',
            Icons.cleaning_services,
            AppTheme.statusColors['warning']!,
            widget.onClearCache,
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildExportFrequencySelector() {
    final String currentFrequency =
        widget.dataSettings['exportFrequency'] as String? ?? 'manual';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Frequency',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.dividerLight.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentFrequency,
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: 'manual',
                    child: Text(
                      'Manual Export Only',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'daily',
                    child: Text(
                      'Daily Automatic Export',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'weekly',
                    child: Text(
                      'Weekly Automatic Export',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'monthly',
                    child: Text(
                      'Monthly Automatic Export',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    widget.onSettingChanged('exportFrequency', value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageLimitSelector() {
    final int currentLimit = widget.dataSettings['storageLimit'] as int? ?? 100;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Storage Limit',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${currentLimit}MB',
                style:
                    AppTheme.dataTextTheme(isLight: true).titleMedium?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.lightTheme.primaryColor,
              thumbColor: AppTheme.lightTheme.primaryColor,
              overlayColor:
                  AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
              inactiveTrackColor: AppTheme
                  .lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.3),
              trackHeight: 4.0,
            ),
            child: Slider(
              value: currentLimit.toDouble(),
              min: 50,
              max: 500,
              divisions: 9,
              onChanged: (value) {
                widget.onSettingChanged('storageLimit', value.round());
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '50MB',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                '500MB',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRetentionPolicySelector() {
    final int currentDays = widget.dataSettings['retentionDays'] as int? ?? 30;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Retention Policy',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.dividerLight.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: currentDays,
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: 7,
                    child: Text(
                      'Keep for 7 days',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 30,
                    child: Text(
                      'Keep for 30 days',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 90,
                    child: Text(
                      'Keep for 90 days',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 365,
                    child: Text(
                      'Keep for 1 year',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                  DropdownMenuItem(
                    value: -1,
                    child: Text(
                      'Keep forever',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    widget.onSettingChanged('retentionDays', value);
                  }
                },
              ),
            ),
          ),
        ],
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
}

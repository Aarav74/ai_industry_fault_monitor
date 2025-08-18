import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ThemeSelectionSection extends StatefulWidget {
  final String currentTheme;
  final Function(String) onThemeChanged;

  const ThemeSelectionSection({
    Key? key,
    required this.currentTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<ThemeSelectionSection> createState() => _ThemeSelectionSectionState();
}

class _ThemeSelectionSectionState extends State<ThemeSelectionSection> {
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
                  iconName: 'palette',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Theme Selection',
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
          _buildThemeOption(
            'light',
            'Light Theme',
            'Optimized for bright environments',
            Icons.light_mode,
            AppTheme.statusColors['warning']!,
          ),
          _buildThemeOption(
            'dark',
            'Dark Theme',
            'Optimized for low-light industrial environments',
            Icons.dark_mode,
            AppTheme.lightTheme.colorScheme.onSurface,
          ),
          _buildThemeOption(
            'auto',
            'Auto Theme',
            'Follows system theme settings',
            Icons.auto_mode,
            AppTheme.statusColors['info']!,
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.statusColors['info']!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: AppTheme.statusColors['info']!.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.statusColors['info']!,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'High contrast mode is automatically enabled in industrial environments for better visibility.',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.statusColors['info']!,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    String themeKey,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final bool isSelected = widget.currentTheme == themeKey;

    return InkWell(
      onTap: () => widget.onThemeChanged(themeKey),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
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
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.onSurface,
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
            if (isSelected)
              Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'check',
                  color: Colors.white,
                  size: 4.w,
                ),
              )
            else
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.3),
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

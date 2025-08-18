import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class IpAddressInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final bool isValid;
  final String? errorMessage;

  const IpAddressInputWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.isValid,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<IpAddressInputWidget> createState() => _IpAddressInputWidgetState();
}

class _IpAddressInputWidgetState extends State<IpAddressInputWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: widget.isValid
                  ? AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.12)
                  : AppTheme.lightTheme.colorScheme.error,
              width: widget.isValid ? 1.0 : 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              LengthLimitingTextInputFormatter(15),
            ],
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '192.168.1.100',
              hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryLight,
                fontSize: 16.sp,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'router',
                  color: widget.isValid
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.error,
                  size: 6.w,
                ),
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: widget.isValid ? 'check_circle' : 'error',
                        color: widget.isValid
                            ? AppTheme.successLight
                            : AppTheme.lightTheme.colorScheme.error,
                        size: 6.w,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
            ),
          ),
        ),
        if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 1.h, left: 4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error_outline',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    widget.errorMessage!,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

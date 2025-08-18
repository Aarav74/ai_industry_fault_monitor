import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../../../core/app_export.dart';

class ExportBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> analyticsData;
  final String selectedPeriod;

  const ExportBottomSheet({
    Key? key,
    required this.analyticsData,
    required this.selectedPeriod,
  }) : super(key: key);

  @override
  State<ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends State<ExportBottomSheet> {
  String selectedFormat = 'CSV';
  DateTimeRange? selectedDateRange;
  bool isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 12.w,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Export Analytics Data',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Format',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: ['CSV', 'PDF'].map((format) {
              final isSelected = selectedFormat == format;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedFormat = format),
                  child: Container(
                    margin: EdgeInsets.only(right: format == 'CSV' ? 2.w : 0),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: format == 'CSV'
                              ? 'table_chart'
                              : 'picture_as_pdf',
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          format,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 3.h),
          Text(
            'Date Range',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          GestureDetector(
            onTap: _selectDateRange,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'date_range',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      selectedDateRange != null
                          ? '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}'
                          : 'Select date range',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: selectedDateRange != null
                            ? AppTheme.lightTheme.colorScheme.onSurface
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isExporting ? null : _exportData,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
              child: isExporting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text('Exporting...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'download',
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text('Export Data'),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  Future<void> _exportData() async {
    setState(() {
      isExporting = true;
    });

    try {
      final filteredData = _filterDataByDateRange();
      final content = selectedFormat == 'CSV'
          ? _generateCSV(filteredData)
          : _generatePDF(filteredData);

      final filename =
          'analytics_${widget.selectedPeriod.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.$selectedFormat.toLowerCase()';

      await _downloadFile(content, filename);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully as $selectedFormat'),
            backgroundColor: AppTheme.statusColors['success'],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: AppTheme.statusColors['error'],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isExporting = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _filterDataByDateRange() {
    if (selectedDateRange == null) return widget.analyticsData;

    return widget.analyticsData.where((data) {
      final dataDate = DateTime.parse(data['timestamp'] as String);
      return dataDate.isAfter(selectedDateRange!.start) &&
          dataDate
              .isBefore(selectedDateRange!.end.add(const Duration(days: 1)));
    }).toList();
  }

  String _generateCSV(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 'No data available';

    final headers = data.first.keys.toList();
    final csvContent = StringBuffer();

    // Add headers
    csvContent.writeln(headers.join(','));

    // Add data rows
    for (final row in data) {
      final values =
          headers.map((header) => row[header]?.toString() ?? '').toList();
      csvContent.writeln(values.join(','));
    }

    return csvContent.toString();
  }

  String _generatePDF(List<Map<String, dynamic>> data) {
    // For this implementation, we'll generate a simple text-based report
    // In a real application, you would use a PDF generation library
    final content = StringBuffer();
    content.writeln('Analytics Report - ${widget.selectedPeriod}');
    content.writeln('Generated: ${DateTime.now().toString()}');
    content.writeln('');

    if (selectedDateRange != null) {
      content.writeln(
          'Date Range: ${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}');
      content.writeln('');
    }

    content.writeln('Sensor Data:');
    content.writeln('============');

    for (final item in data) {
      content.writeln('Timestamp: ${item['timestamp']}');
      item.forEach((key, value) {
        if (key != 'timestamp') {
          content.writeln('$key: $value');
        }
      });
      content.writeln('---');
    }

    return content.toString();
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.Url.revokeObjectUrl(url);
    } else {
      // For mobile platforms, you would typically use path_provider
      // and save to the device's document directory
      // This is a simplified implementation
      throw UnsupportedError('File download not implemented for this platform');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}
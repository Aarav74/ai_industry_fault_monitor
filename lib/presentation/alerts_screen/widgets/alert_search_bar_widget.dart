import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AlertSearchBarWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String?) onSensorFilterChanged;
  final Function(String?) onSeverityFilterChanged;
  final VoidCallback? onDateRangePressed;

  const AlertSearchBarWidget({
    Key? key,
    required this.onSearchChanged,
    required this.onSensorFilterChanged,
    required this.onSeverityFilterChanged,
    this.onDateRangePressed,
  }) : super(key: key);

  @override
  State<AlertSearchBarWidget> createState() => _AlertSearchBarWidgetState();
}

class _AlertSearchBarWidgetState extends State<AlertSearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSensorFilter;
  String? _selectedSeverityFilter;
  bool _isFilterExpanded = false;

  final List<String> _sensorTypes = [
    'All Sensors',
    'Temperature',
    'Humidity',
    'LPG Gas',
    'CO2 Gas',
    'Current',
    'Voltage',
    'Motion',
    'Flame',
    'IR Sensor',
  ];

  final List<String> _severityLevels = [
    'All Severities',
    'Critical',
    'High',
    'Medium',
    'Low',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSearchRow(),
          AnimatedContainer(
            duration: AppTheme.normalAnimation,
            height: _isFilterExpanded ? null : 0,
            child: _isFilterExpanded ? _buildFilterOptions() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search alerts...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.textSecondaryLight,
                    size: 20.sp,
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: AppTheme.textSecondaryLight,
                          size: 18.sp,
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.lightTheme.scaffoldBackgroundColor,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            decoration: BoxDecoration(
              color: _isFilterExpanded
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _isFilterExpanded = !_isFilterExpanded;
                });
              },
              icon: CustomIconWidget(
                iconName: 'tune',
                color: _isFilterExpanded
                    ? Colors.white
                    : AppTheme.textSecondaryLight,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: IconButton(
              onPressed: widget.onDateRangePressed,
              icon: CustomIconWidget(
                iconName: 'date_range',
                color: AppTheme.textSecondaryLight,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
      child: Column(
        children: [
          Divider(
            color: AppTheme.dividerLight,
            height: 2.h,
          ),
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  'Sensor Type',
                  _selectedSensorFilter,
                  _sensorTypes,
                  (value) {
                    setState(() {
                      _selectedSensorFilter =
                          value == 'All Sensors' ? null : value;
                    });
                    widget.onSensorFilterChanged(_selectedSensorFilter);
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildDropdownFilter(
                  'Severity',
                  _selectedSeverityFilter,
                  _severityLevels,
                  (value) {
                    setState(() {
                      _selectedSeverityFilter =
                          value == 'All Severities' ? null : value;
                    });
                    widget.onSeverityFilterChanged(_selectedSeverityFilter);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: _clearAllFilters,
                icon: CustomIconWidget(
                  iconName: 'clear_all',
                  color: AppTheme.textSecondaryLight,
                  size: 16.sp,
                ),
                label: const Text('Clear All'),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isFilterExpanded = false;
                  });
                },
                icon: CustomIconWidget(
                  iconName: 'done',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 16.sp,
                ),
                label: const Text('Apply Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String? selectedValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.5.h),
        DropdownButtonFormField<String>(
          value: selectedValue ?? options.first,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(
                color: AppTheme.dividerLight.withValues(alpha: 0.12),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 3.w,
              vertical: 1.h,
            ),
          ),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: CustomIconWidget(
            iconName: 'arrow_drop_down',
            color: AppTheme.textSecondaryLight,
            size: 20.sp,
          ),
        ),
      ],
    );
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedSensorFilter = null;
      _selectedSeverityFilter = null;
    });
    widget.onSearchChanged('');
    widget.onSensorFilterChanged(null);
    widget.onSeverityFilterChanged(null);
  }
}

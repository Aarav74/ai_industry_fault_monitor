import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/chart_legend_widget.dart';
import './widgets/export_bottom_sheet.dart';
import './widgets/sensor_chart_widget.dart';
import './widgets/statistics_card_widget.dart';
import './widgets/time_period_selector.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  String selectedPeriod = 'Weekly';
  bool isLoading = false;
  bool isConnected = true;
  String deviceIP = '192.168.1.100';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Map<String, bool> sensorVisibility = {
    'Temperature': true,
    'Humidity': true,
    'Gas (LPG)': true,
    'Gas (CO2)': true,
    'Current': true,
    'Voltage': true,
    'Motion': false,
    'Flame': false,
  };

  // Mock analytics data
  final List<Map<String, dynamic>> mockAnalyticsData = [
    {
      'timestamp': '2025-08-11T10:00:00Z',
      'temperature': 24.5,
      'humidity': 65.2,
      'gas_lpg': 120.0,
      'gas_co2': 450.0,
      'current': 2.3,
      'voltage': 220.5,
      'motion': 0,
      'flame': 0,
    },
    {
      'timestamp': '2025-08-12T10:00:00Z',
      'temperature': 26.1,
      'humidity': 62.8,
      'gas_lpg': 115.0,
      'gas_co2': 420.0,
      'current': 2.1,
      'voltage': 218.2,
      'motion': 1,
      'flame': 0,
    },
    {
      'timestamp': '2025-08-13T10:00:00Z',
      'temperature': 25.3,
      'humidity': 68.1,
      'gas_lpg': 125.0,
      'gas_co2': 480.0,
      'current': 2.5,
      'voltage': 222.1,
      'motion': 0,
      'flame': 0,
    },
    {
      'timestamp': '2025-08-14T10:00:00Z',
      'temperature': 27.2,
      'humidity': 59.4,
      'gas_lpg': 110.0,
      'gas_co2': 390.0,
      'current': 1.9,
      'voltage': 215.8,
      'motion': 1,
      'flame': 0,
    },
    {
      'timestamp': '2025-08-15T10:00:00Z',
      'temperature': 23.8,
      'humidity': 71.3,
      'gas_lpg': 130.0,
      'gas_co2': 510.0,
      'current': 2.7,
      'voltage': 225.4,
      'motion': 0,
      'flame': 1,
    },
    {
      'timestamp': '2025-08-16T10:00:00Z',
      'temperature': 25.9,
      'humidity': 64.7,
      'gas_lpg': 118.0,
      'gas_co2': 435.0,
      'current': 2.2,
      'voltage': 219.6,
      'motion': 1,
      'flame': 0,
    },
    {
      'timestamp': '2025-08-17T10:00:00Z',
      'temperature': 24.1,
      'humidity': 66.9,
      'gas_lpg': 122.0,
      'gas_co2': 465.0,
      'current': 2.4,
      'voltage': 221.3,
      'motion': 0,
      'flame': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();
    await _loadAnalyticsData();
  }

  void _onPeriodChanged(String period) {
    if (period != selectedPeriod) {
      HapticFeedback.selectionClick();
      setState(() {
        selectedPeriod = period;
      });
      _loadAnalyticsData();
    }
  }

  void _onSensorVisibilityChanged(String sensorName, bool isVisible) {
    HapticFeedback.lightImpact();
    setState(() {
      sensorVisibility[sensorName] = isVisible;
    });
  }

  void _showExportBottomSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportBottomSheet(
        analyticsData: mockAnalyticsData,
        selectedPeriod: selectedPeriod,
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _generateChartData() {
    final Map<String, List<Map<String, dynamic>>> chartData = {};

    final sensorKeys = {
      'Temperature': 'temperature',
      'Humidity': 'humidity',
      'Gas (LPG)': 'gas_lpg',
      'Gas (CO2)': 'gas_co2',
      'Current': 'current',
      'Voltage': 'voltage',
      'Motion': 'motion',
      'Flame': 'flame',
    };

    sensorKeys.forEach((sensorName, key) {
      chartData[sensorName] = mockAnalyticsData.map((data) {
        final timestamp = DateTime.parse(data['timestamp'] as String);
        return {
          'label': '${timestamp.month}/${timestamp.day}',
          'value': data[key] as num,
        };
      }).toList();
    });

    return chartData;
  }

  Map<String, Map<String, dynamic>> _generateStatistics() {
    final Map<String, Map<String, dynamic>> statistics = {};

    final sensorKeys = {
      'Temperature': 'temperature',
      'Humidity': 'humidity',
      'Gas (LPG)': 'gas_lpg',
      'Gas (CO2)': 'gas_co2',
      'Current': 'current',
      'Voltage': 'voltage',
      'Motion': 'motion',
      'Flame': 'flame',
    };

    sensorKeys.forEach((sensorName, key) {
      final values = mockAnalyticsData
          .map((data) => (data[key] as num).toDouble())
          .toList();

      if (values.isNotEmpty) {
        final min = values.reduce((a, b) => a < b ? a : b);
        final max = values.reduce((a, b) => a > b ? a : b);
        final average = values.reduce((a, b) => a + b) / values.length;

        // Calculate trend (simplified - comparing first half vs second half)
        final halfPoint = values.length ~/ 2;
        final firstHalf = values.take(halfPoint).toList();
        final secondHalf = values.skip(halfPoint).toList();

        final firstAvg = firstHalf.isNotEmpty
            ? firstHalf.reduce((a, b) => a + b) / firstHalf.length
            : 0;
        final secondAvg = secondHalf.isNotEmpty
            ? secondHalf.reduce((a, b) => a + b) / secondHalf.length
            : 0;

        final trend =
            firstAvg != 0 ? ((secondAvg - firstAvg) / firstAvg) * 100 : 0;

        statistics[sensorName] = {
          'min': min,
          'max': max,
          'average': average,
          'trend': trend,
        };
      }
    });

    return statistics;
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _generateChartData();
    final statistics = _generateStatistics();
    final visibleSensors = sensorVisibility.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isConnected
                  ? AppTheme.statusColors['success']!.withValues(alpha: 0.1)
                  : AppTheme.statusColors['error']!.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isConnected
                        ? AppTheme.statusColors['success']
                        : AppTheme.statusColors['error'],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  deviceIP,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: isConnected
                        ? AppTheme.statusColors['success']
                        : AppTheme.statusColors['error'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppTheme.lightTheme.colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TimePeriodSelector(
                  selectedPeriod: selectedPeriod,
                  onPeriodChanged: _onPeriodChanged,
                ),
                if (isLoading)
                  Container(
                    height: 40.h,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Loading analytics data...',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  ChartLegendWidget(
                    sensorNames: sensorVisibility.keys.toList(),
                    sensorVisibility: sensorVisibility,
                    onVisibilityChanged: _onSensorVisibilityChanged,
                  ),

                  SizedBox(height: 2.h),

                  // Charts Section
                  ...chartData.entries.map((entry) {
                    final sensorName = entry.key;
                    final data = entry.value;
                    final isVisible = sensorVisibility[sensorName] ?? false;

                    return SensorChartWidget(
                      sensorName: sensorName,
                      chartData: data,
                      selectedPeriod: selectedPeriod,
                      isVisible: isVisible,
                    );
                  }).toList(),

                  SizedBox(height: 3.h),

                  // Statistics Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      'Statistics Summary',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  SizedBox(
                    height: 20.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: visibleSensors.length,
                      itemBuilder: (context, index) {
                        final sensorName = visibleSensors[index];
                        final sensorStats = statistics[sensorName];

                        if (sensorStats == null) return const SizedBox.shrink();

                        return StatisticsCardWidget(
                          sensorName: sensorName,
                          statistics: sensorStats,
                          isVisible: true,
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 10.h),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showExportBottomSheet,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        icon: CustomIconWidget(
          iconName: 'download',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 20,
        ),
        label: Text(
          'Export',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

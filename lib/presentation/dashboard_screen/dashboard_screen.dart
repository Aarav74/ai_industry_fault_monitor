import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/connection_header_widget.dart';
import './widgets/emergency_fab_widget.dart';
import './widgets/sensor_card_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isAutoRefresh = true;
  bool _isLoading = false;
  String _connectionStatus = 'Connected';
  String _connectedIP = '192.168.1.100';

  // Mock sensor data
  final List<Map<String, dynamic>> _sensorData = [
    {
      'name': 'Temperature',
      'value': '24.5',
      'unit': '°C',
      'status': 'normal',
      'icon': 'thermostat',
      'trend': [22.1, 22.8, 23.2, 23.9, 24.1, 24.3, 24.5],
    },
    {
      'name': 'Humidity',
      'value': '65.2',
      'unit': '%',
      'status': 'normal',
      'icon': 'water_drop',
      'trend': [62.1, 63.5, 64.2, 64.8, 65.0, 65.1, 65.2],
    },
    {
      'name': 'LPG (MQ6)',
      'value': '450',
      'unit': 'ppm',
      'status': 'warning',
      'icon': 'local_gas_station',
      'trend': [420, 430, 435, 440, 445, 448, 450],
    },
    {
      'name': 'CO2 (MQ7)',
      'value': '380',
      'unit': 'ppm',
      'status': 'normal',
      'icon': 'air',
      'trend': [375, 376, 377, 378, 379, 379, 380],
    },
    {
      'name': 'Current',
      'value': '2.45',
      'unit': 'A',
      'status': 'normal',
      'icon': 'electric_bolt',
      'trend': [2.40, 2.41, 2.42, 2.43, 2.44, 2.44, 2.45],
    },
    {
      'name': 'Voltage',
      'value': '220.5',
      'unit': 'V',
      'status': 'normal',
      'icon': 'power',
      'trend': [219.8, 220.0, 220.1, 220.2, 220.3, 220.4, 220.5],
    },
    {
      'name': 'Motion',
      'value': 'Detected',
      'unit': '',
      'status': 'warning',
      'icon': 'sensors',
      'trend': [0, 1, 0, 1, 1, 0, 1],
    },
    {
      'name': 'Flame',
      'value': 'None',
      'unit': '',
      'status': 'normal',
      'icon': 'local_fire_department',
      'trend': [0, 0, 0, 0, 0, 0, 0],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    if (_isAutoRefresh) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _isAutoRefresh) {
          _refreshData();
          _startAutoRefresh();
        }
      });
    }
  }

  Future<void> _refreshData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isLoading = false;
        // Update sensor values with slight variations
        for (var sensor in _sensorData) {
          if (sensor['name'] == 'Temperature') {
            double currentValue = double.parse(sensor['value']);
            double newValue =
                currentValue + (DateTime.now().millisecond % 10 - 5) * 0.1;
            sensor['value'] = newValue.toStringAsFixed(1);
            (sensor['trend'] as List<double>).add(newValue);
            if ((sensor['trend'] as List<double>).length > 7) {
              (sensor['trend'] as List<double>).removeAt(0);
            }
          }
        }
      });
    }
  }

  void _toggleAutoRefresh() {
    setState(() {
      _isAutoRefresh = !_isAutoRefresh;
    });
    if (_isAutoRefresh) {
      _startAutoRefresh();
    }
  }

  void _handleEmergencyStop() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Emergency Stop',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to trigger the emergency stop? This will immediately shut down all connected systems.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Emergency stop activated!'),
                    backgroundColor: AppTheme.lightTheme.colorScheme.error,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'STOP',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleSensorTap(Map<String, dynamic> sensor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: sensor['icon'],
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 8.w,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sensor['name'],
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Detailed sensor information and controls',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${sensor['value']} ${sensor['unit']}',
                          style: AppTheme.lightTheme.textTheme.displayMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Current Reading',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: CustomIconWidget(
                            iconName: 'history',
                            color: Colors.white,
                            size: 4.w,
                          ),
                          label: const Text('View History'),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: CustomIconWidget(
                            iconName: 'tune',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 4.w,
                          ),
                          label: const Text('Calibrate'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasEmergency() {
    return _sensorData.any(
        (sensor) => (sensor['status'] as String).toLowerCase() == 'critical');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ConnectionHeaderWidget(
            ipAddress: _connectedIP,
            connectionStatus: _connectionStatus,
            isAutoRefresh: _isAutoRefresh,
            onRefresh: _refreshData,
            onToggleAutoRefresh: _toggleAutoRefresh,
          ),
          Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'dashboard',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      const Text('Dashboard'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'analytics',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      const Text('Analytics'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'notifications',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      const Text('Alerts'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Dashboard Tab
                RefreshIndicator(
                  onRefresh: _refreshData,
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Fetching sensor data...',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(2.w),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount =
                                  constraints.maxWidth > 600 ? 3 : 2;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: 0.85,
                                  crossAxisSpacing: 1.w,
                                  mainAxisSpacing: 1.w,
                                ),
                                itemCount: _sensorData.length,
                                itemBuilder: (context, index) {
                                  final sensor = _sensorData[index];
                                  return SensorCardWidget(
                                    sensorName: sensor['name'],
                                    value: sensor['value'],
                                    unit: sensor['unit'],
                                    status: sensor['status'],
                                    iconName: sensor['icon'],
                                    trendData: (sensor['trend'] as List)
                                        .cast<double>(),
                                    onTap: () => _handleSensorTap(sensor),
                                    onLongPress: () => _handleSensorTap(sensor),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
                // Analytics Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'analytics',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 15.w,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Analytics View',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Detailed analytics and trends will be displayed here',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 3.h),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/analytics-screen'),
                        child: const Text('View Full Analytics'),
                      ),
                    ],
                  ),
                ),
                // Alerts Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'notifications',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 15.w,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Alerts & Notifications',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'System alerts and notification settings will be displayed here',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 3.h),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/alerts-screen'),
                        child: const Text('View All Alerts'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: EmergencyFabWidget(
        onPressed: _handleEmergencyStop,
        hasEmergency: _hasEmergency(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

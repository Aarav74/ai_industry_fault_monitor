import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/alert_card_widget.dart';
import './widgets/alert_configuration_sheet_widget.dart';
import './widgets/alert_search_bar_widget.dart';
import './widgets/alert_summary_badges_widget.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _expandedAlerts = {};
  final Set<String> _selectedAlerts = {};
  bool _isSelectionMode = false;
  String _searchQuery = '';
  String? _sensorFilter;
  String? _severityFilter;
  bool _isRefreshing = false;

  // Mock data for alerts
  final List<Map<String, dynamic>> _mockAlerts = [
    {
      'id': 'alert_001',
      'sensorName': 'Temperature Sensor #1',
      'type': 'temperature',
      'severity': 'critical',
      'status': 'active',
      'message': 'Temperature exceeded critical threshold',
      'currentValue': 85.2,
      'thresholdExceeded': 80.0,
      'unit': '°C',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'recommendedActions': [
        'Check cooling system immediately',
        'Verify sensor calibration',
        'Inspect equipment for overheating',
      ],
    },
    {
      'id': 'alert_002',
      'sensorName': 'LPG Gas Sensor #2',
      'type': 'gas',
      'severity': 'high',
      'status': 'active',
      'message': 'LPG concentration above safe levels',
      'currentValue': 4500,
      'thresholdExceeded': 4000,
      'unit': 'ppm',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'recommendedActions': [
        'Evacuate area immediately',
        'Check for gas leaks',
        'Ventilate the area',
      ],
    },
    {
      'id': 'alert_003',
      'sensorName': 'Humidity Sensor #1',
      'type': 'humidity',
      'severity': 'medium',
      'status': 'acknowledged',
      'message': 'Humidity levels outside normal range',
      'currentValue': 85.0,
      'thresholdExceeded': 70.0,
      'unit': '%',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'recommendedActions': [
        'Check dehumidification system',
        'Monitor for condensation',
      ],
    },
    {
      'id': 'alert_004',
      'sensorName': 'Current Sensor #3',
      'type': 'current',
      'severity': 'low',
      'status': 'resolved',
      'message': 'Current draw slightly elevated',
      'currentValue': 12.5,
      'thresholdExceeded': 12.0,
      'unit': 'A',
      'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
      'recommendedActions': [
        'Monitor equipment load',
        'Check for efficiency issues',
      ],
    },
    {
      'id': 'alert_005',
      'sensorName': 'Flame Sensor #1',
      'type': 'flame',
      'severity': 'critical',
      'status': 'active',
      'message': 'Flame detected in restricted area',
      'currentValue': 1,
      'thresholdExceeded': 0,
      'unit': '',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'recommendedActions': [
        'Activate fire suppression system',
        'Evacuate area immediately',
        'Contact emergency services',
      ],
    },
    {
      'id': 'alert_006',
      'sensorName': 'Motion Sensor #4',
      'type': 'motion',
      'severity': 'low',
      'status': 'active',
      'message': 'Unauthorized movement detected',
      'currentValue': 1,
      'thresholdExceeded': 0,
      'unit': '',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'recommendedActions': [
        'Check security cameras',
        'Verify authorized personnel',
      ],
    },
    {
      'id': 'alert_007',
      'sensorName': 'Voltage Sensor #2',
      'type': 'voltage',
      'severity': 'medium',
      'status': 'snoozed',
      'message': 'Voltage fluctuation detected',
      'currentValue': 245.8,
      'thresholdExceeded': 240.0,
      'unit': 'V',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'recommendedActions': [
        'Check power supply stability',
        'Inspect electrical connections',
      ],
    },
    {
      'id': 'alert_008',
      'sensorName': 'CO2 Gas Sensor #1',
      'type': 'gas',
      'severity': 'high',
      'status': 'resolved',
      'message': 'CO2 levels exceeded safety threshold',
      'currentValue': 3200,
      'thresholdExceeded': 3000,
      'unit': 'ppm',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'recommendedActions': [
        'Improve ventilation system',
        'Check air filtration',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSummarySection(),
          _buildSearchSection(),
          _buildTabBar(),
          Expanded(
            child: _buildTabBarView(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Alerts',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            onPressed: _selectAllAlerts,
            icon: CustomIconWidget(
              iconName: 'select_all',
              color: AppTheme.lightTheme.primaryColor,
              size: 20.sp,
            ),
          ),
          IconButton(
            onPressed: _bulkAcknowledgeAlerts,
            icon: CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.statusColors['success'],
              size: 20.sp,
            ),
          ),
          IconButton(
            onPressed: _exitSelectionMode,
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.textSecondaryLight,
              size: 20.sp,
            ),
          ),
        ] else ...[
          IconButton(
            onPressed: _refreshAlerts,
            icon: _isRefreshing
                ? SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'refresh',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20.sp,
                  ),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.textSecondaryLight,
              size: 20.sp,
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Text('Export Alerts'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Alert Settings'),
              ),
              const PopupMenuItem(
                value: 'clear_resolved',
                child: Text('Clear Resolved'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSummarySection() {
    final criticalCount = _getFilteredAlerts()
        .where((alert) =>
            alert['severity'] == 'critical' && alert['status'] == 'active')
        .length;
    final warningCount = _getFilteredAlerts()
        .where((alert) =>
            (alert['severity'] == 'high' || alert['severity'] == 'medium') &&
            alert['status'] == 'active')
        .length;
    final infoCount = _getFilteredAlerts()
        .where((alert) =>
            alert['severity'] == 'low' && alert['status'] == 'active')
        .length;

    return AlertSummaryBadgesWidget(
      criticalCount: criticalCount,
      warningCount: warningCount,
      infoCount: infoCount,
    );
  }

  Widget _buildSearchSection() {
    return AlertSearchBarWidget(
      onSearchChanged: (query) {
        setState(() {
          _searchQuery = query;
        });
      },
      onSensorFilterChanged: (filter) {
        setState(() {
          _sensorFilter = filter;
        });
      },
      onSeverityFilterChanged: (filter) {
        setState(() {
          _severityFilter = filter;
        });
      },
      onDateRangePressed: _showDateRangePicker,
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.statusColors['critical'],
                  size: 16.sp,
                ),
                SizedBox(width: 1.w),
                const Text('Active'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'history',
                  color: AppTheme.textSecondaryLight,
                  size: 16.sp,
                ),
                SizedBox(width: 1.w),
                const Text('Recent'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.statusColors['success'],
                  size: 16.sp,
                ),
                SizedBox(width: 1.w),
                const Text('Resolved'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAlertsList(['active']),
        _buildAlertsList(['acknowledged', 'snoozed']),
        _buildAlertsList(['resolved']),
      ],
    );
  }

  Widget _buildAlertsList(List<String> statusFilter) {
    final filteredAlerts = _getFilteredAlerts()
        .where((alert) => statusFilter.contains(alert['status']))
        .toList();

    if (filteredAlerts.isEmpty) {
      return _buildEmptyState(statusFilter.first);
    }

    return RefreshIndicator(
      onRefresh: _refreshAlerts,
      child: ListView.builder(
        padding: EdgeInsets.only(top: 2.h, bottom: 10.h),
        itemCount: filteredAlerts.length,
        itemBuilder: (context, index) {
          final alert = filteredAlerts[index];
          final alertId = alert['id'] as String;
          final isExpanded = _expandedAlerts.contains(alertId);
          final isSelected = _selectedAlerts.contains(alertId);

          return GestureDetector(
            onLongPress: () => _enterSelectionMode(alertId),
            child: Container(
              decoration: _isSelectionMode && isSelected
                  ? BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    )
                  : null,
              child: AlertCardWidget(
                alert: alert,
                isExpanded: isExpanded,
                onTap: () => _isSelectionMode
                    ? _toggleAlertSelection(alertId)
                    : _toggleAlertExpansion(alertId),
                onAcknowledge: () => _acknowledgeAlert(alertId),
                onSnooze: () => _snoozeAlert(alertId),
                onViewDetails: () => _viewAlertDetails(alert),
                onMarkResolved: () => _markAlertResolved(alertId),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String message;
    String iconName;

    switch (status) {
      case 'active':
        message = 'No active alerts\nAll systems operating normally';
        iconName = 'check_circle';
        break;
      case 'acknowledged':
        message = 'No recent alerts\nCheck back later for updates';
        iconName = 'history';
        break;
      case 'resolved':
        message = 'No resolved alerts\nResolved alerts will appear here';
        iconName = 'task_alt';
        break;
      default:
        message = 'No alerts found';
        iconName = 'info';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.textDisabledLight,
            size: 48.sp,
          ),
          SizedBox(height: 2.h),
          Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showAlertConfiguration,
      child: CustomIconWidget(
        iconName: 'settings',
        color: Colors.white,
        size: 24.sp,
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredAlerts() {
    return _mockAlerts.where((alert) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        final sensorName = (alert['sensorName'] as String).toLowerCase();
        final message = (alert['message'] as String).toLowerCase();
        if (!sensorName.contains(searchLower) &&
            !message.contains(searchLower)) {
          return false;
        }
      }

      // Sensor type filter
      if (_sensorFilter != null) {
        final alertType = alert['type'] as String;
        final filterType = _sensorFilter!.toLowerCase().replaceAll(' ', '_');
        if (alertType != filterType &&
            !alertType.contains(filterType.split('_').first)) {
          return false;
        }
      }

      // Severity filter
      if (_severityFilter != null) {
        final alertSeverity = alert['severity'] as String;
        if (alertSeverity.toLowerCase() != _severityFilter!.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _toggleAlertExpansion(String alertId) {
    setState(() {
      if (_expandedAlerts.contains(alertId)) {
        _expandedAlerts.remove(alertId);
      } else {
        _expandedAlerts.add(alertId);
      }
    });
  }

  void _enterSelectionMode(String alertId) {
    setState(() {
      _isSelectionMode = true;
      _selectedAlerts.add(alertId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedAlerts.clear();
    });
  }

  void _toggleAlertSelection(String alertId) {
    setState(() {
      if (_selectedAlerts.contains(alertId)) {
        _selectedAlerts.remove(alertId);
        if (_selectedAlerts.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedAlerts.add(alertId);
      }
    });
  }

  void _selectAllAlerts() {
    setState(() {
      final visibleAlerts = _getFilteredAlerts();
      _selectedAlerts
          .addAll(visibleAlerts.map((alert) => alert['id'] as String));
    });
  }

  void _bulkAcknowledgeAlerts() {
    for (final alertId in _selectedAlerts) {
      _acknowledgeAlert(alertId);
    }
    _exitSelectionMode();
  }

  void _acknowledgeAlert(String alertId) {
    setState(() {
      final alertIndex =
          _mockAlerts.indexWhere((alert) => alert['id'] == alertId);
      if (alertIndex != -1) {
        _mockAlerts[alertIndex]['status'] = 'acknowledged';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Alert acknowledged'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _undoAcknowledgeAlert(alertId),
        ),
      ),
    );
  }

  void _undoAcknowledgeAlert(String alertId) {
    setState(() {
      final alertIndex =
          _mockAlerts.indexWhere((alert) => alert['id'] == alertId);
      if (alertIndex != -1) {
        _mockAlerts[alertIndex]['status'] = 'active';
      }
    });
  }

  void _snoozeAlert(String alertId) {
    setState(() {
      final alertIndex =
          _mockAlerts.indexWhere((alert) => alert['id'] == alertId);
      if (alertIndex != -1) {
        _mockAlerts[alertIndex]['status'] = 'snoozed';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert snoozed for 1 hour')),
    );
  }

  void _markAlertResolved(String alertId) {
    setState(() {
      final alertIndex =
          _mockAlerts.indexWhere((alert) => alert['id'] == alertId);
      if (alertIndex != -1) {
        _mockAlerts[alertIndex]['status'] = 'resolved';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert marked as resolved')),
    );
  }

  void _viewAlertDetails(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert['sensorName'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${alert['type']}'),
            Text('Severity: ${alert['severity']}'),
            Text('Status: ${alert['status']}'),
            Text('Message: ${alert['message']}'),
            if (alert['currentValue'] != null)
              Text(
                  'Current Value: ${alert['currentValue']} ${alert['unit'] ?? ''}'),
            if (alert['thresholdExceeded'] != null)
              Text(
                  'Threshold: ${alert['thresholdExceeded']} ${alert['unit'] ?? ''}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshAlerts() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alerts refreshed')),
    );
  }

  void _showAlertConfiguration() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AlertConfigurationSheetWidget(
        onSaveConfiguration: (configuration) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alert configuration saved')),
          );
        },
      ),
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
    );

    if (picked != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Date range: ${picked.start.month}/${picked.start.day} - ${picked.end.month}/${picked.end.day}',
          ),
        ),
      );
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exporting alerts...')),
        );
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings-screen');
        break;
      case 'clear_resolved':
        _clearResolvedAlerts();
        break;
    }
  }

  void _clearResolvedAlerts() {
    setState(() {
      _mockAlerts.removeWhere((alert) => alert['status'] == 'resolved');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resolved alerts cleared')),
    );
  }
}

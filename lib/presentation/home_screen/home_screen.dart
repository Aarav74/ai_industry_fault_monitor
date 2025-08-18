import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/connection_status_card_widget.dart';
import './widgets/ip_address_input_widget.dart';
import './widgets/network_scan_fab_widget.dart';
import './widgets/recent_ip_chips_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _ipController = TextEditingController();
  final Dio _dio = Dio();

  bool _isValidIp = false;
  String? _errorMessage;
  bool _isConnecting = false;
  bool _isScanning = false;
  Map<String, dynamic>? _connectionStatus;
  List<Map<String, dynamic>> _recentIps = [];

  // Mock sensor data for demonstration
  final List<Map<String, dynamic>> _mockSensorData = [
    {
      "deviceIp": "192.168.1.100",
      "deviceName": "Factory Floor ESP32",
      "isConnected": true,
      "sensorCount": 8,
      "lastConnected": DateTime.now().subtract(const Duration(minutes: 2)),
      "sensors": {
        "temperature": 24.5,
        "humidity": 65.2,
        "gas_lpg": 0.3,
        "gas_co2": 400.2,
        "current": 2.1,
        "voltage": 220.5,
        "motion": false,
        "flame": false
      }
    },
    {
      "deviceIp": "192.168.1.101",
      "deviceName": "Warehouse ESP32",
      "isConnected": false,
      "sensorCount": 6,
      "lastConnected": DateTime.now().subtract(const Duration(hours: 3)),
      "sensors": {}
    },
    {
      "deviceIp": "192.168.1.102",
      "deviceName": "Office ESP32",
      "isConnected": true,
      "sensorCount": 5,
      "lastConnected": DateTime.now().subtract(const Duration(minutes: 5)),
      "sensors": {
        "temperature": 22.1,
        "humidity": 45.8,
        "gas_co2": 380.5,
        "motion": true,
        "flame": false
      }
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentIps();
    _setupDio();
  }

  void _setupDio() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.sendTimeout = const Duration(seconds: 10);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _dio.close();
    super.dispose();
  }

  Future<void> _loadRecentIps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentIpsJson = prefs.getStringList('recent_ips') ?? [];

      setState(() {
        _recentIps = recentIpsJson.map((ipString) {
          final parts = ipString.split('|');
          final ip = parts[0];
          final lastConnectedStr = parts.length > 1 ? parts[1] : '';
          final isOnline = parts.length > 2 ? parts[2] == 'true' : false;

          return {
            'ip': ip,
            'lastConnected': lastConnectedStr.isNotEmpty
                ? DateTime.tryParse(lastConnectedStr)
                : null,
            'isOnline': isOnline,
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading recent IPs: $e');
    }
  }

  Future<void> _saveRecentIps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentIpsJson = _recentIps.map((ipData) {
        final ip = ipData['ip'] as String;
        final lastConnected = ipData['lastConnected'] as DateTime?;
        final isOnline = ipData['isOnline'] as bool? ?? false;

        return '$ip|${lastConnected?.toIso8601String() ?? ''}|$isOnline';
      }).toList();

      await prefs.setStringList('recent_ips', recentIpsJson);
    } catch (e) {
      debugPrint('Error saving recent IPs: $e');
    }
  }

  bool _validateIpAddress(String ip) {
    if (ip.isEmpty) return false;

    final parts = ip.split('.');
    if (parts.length != 4) return false;

    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }

    return true;
  }

  void _onIpChanged(String value) {
    setState(() {
      _isValidIp = _validateIpAddress(value);
      _errorMessage = _isValidIp || value.isEmpty
          ? null
          : 'Please enter a valid IP address (e.g., 192.168.1.100)';
    });
  }

  Future<void> _connectToDevice() async {
    if (!_isValidIp || _ipController.text.isEmpty) return;

    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _errorMessage = 'No network connection available';
      });
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final ip = _ipController.text.trim();

      // Simulate ESP32 connection with mock data
      await Future.delayed(const Duration(seconds: 2));

      // Find mock device data or create new one
      final deviceData = _mockSensorData.firstWhere(
        (device) => device['deviceIp'] == ip,
        orElse: () => {
          'deviceIp': ip,
          'deviceName': 'ESP32 Device',
          'isConnected': true,
          'sensorCount': 8,
          'lastConnected': DateTime.now(),
          'sensors': {
            'temperature': 23.5,
            'humidity': 55.0,
            'gas_lpg': 0.2,
            'gas_co2': 420.0,
            'current': 1.8,
            'voltage': 230.0,
            'motion': false,
            'flame': false
          }
        },
      );

      setState(() {
        _connectionStatus = deviceData;
        _isConnecting = false;
      });

      // Add to recent IPs
      _addToRecentIps(ip, true);

      // Show success feedback
      HapticFeedback.lightImpact();
      Fluttertoast.showToast(
        msg: 'Connected to ESP32 successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successLight,
        textColor: Colors.white,
      );

      // Navigate to dashboard after short delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushNamed(context, '/dashboard-screen');
      }
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _errorMessage =
            'Failed to connect to ESP32. Please check the IP address and try again.';
        _connectionStatus = {
          'deviceIp': _ipController.text.trim(),
          'deviceName': 'ESP32 Device',
          'isConnected': false,
          'sensorCount': 0,
          'lastConnected': null,
        };
      });

      _addToRecentIps(_ipController.text.trim(), false);
    }
  }

  void _addToRecentIps(String ip, bool isOnline) {
    final existingIndex = _recentIps.indexWhere((item) => item['ip'] == ip);

    final ipData = {
      'ip': ip,
      'lastConnected': DateTime.now(),
      'isOnline': isOnline,
    };

    if (existingIndex != -1) {
      _recentIps[existingIndex] = ipData;
    } else {
      _recentIps.insert(0, ipData);
      if (_recentIps.length > 5) {
        _recentIps.removeLast();
      }
    }

    _saveRecentIps();
    setState(() {});
  }

  void _onIpSelected(String ip) {
    _ipController.text = ip;
    _onIpChanged(ip);
  }

  void _onIpDeleted(String ip) {
    setState(() {
      _recentIps.removeWhere((item) => item['ip'] == ip);
    });
    _saveRecentIps();

    Fluttertoast.showToast(
      msg: 'IP address removed',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _scanNetwork() async {
    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Fluttertoast.showToast(
        msg: 'No network connection available',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      // Simulate network scanning
      await Future.delayed(const Duration(seconds: 3));

      // Add discovered devices to recent IPs
      for (final device in _mockSensorData) {
        final ip = device['deviceIp'] as String;
        final isConnected = device['isConnected'] as bool;
        _addToRecentIps(ip, isConnected);
      }

      Fluttertoast.showToast(
        msg: 'Found ${_mockSensorData.length} ESP32 devices',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successLight,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Network scan failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'AI Industry Fault Monitor',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings-screen'),
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect to ESP32 Device',
                      style:
                          AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Enter the IP address of your ESP32 device to start monitoring industrial sensors in real-time.',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              // IP Address Input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: IpAddressInputWidget(
                  controller: _ipController,
                  onChanged: _onIpChanged,
                  isValid: _isValidIp,
                  errorMessage: _errorMessage,
                ),
              ),

              SizedBox(height: 3.h),

              // Connect Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed:
                        _isValidIp && !_isConnecting ? _connectToDevice : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isValidIp && !_isConnecting
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.5),
                      foregroundColor:
                          AppTheme.lightTheme.colorScheme.onPrimary,
                      elevation: _isValidIp && !_isConnecting ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                    ),
                    child: _isConnecting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Connecting...',
                                style: AppTheme.lightTheme.textTheme.labelLarge
                                    ?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Connect to ESP32',
                            style: AppTheme.lightTheme.textTheme.labelLarge
                                ?.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              // Recent IP Chips
              RecentIpChipsWidget(
                recentIps: _recentIps,
                onIpSelected: _onIpSelected,
                onIpDeleted: _onIpDeleted,
              ),

              SizedBox(height: 3.h),

              // Connection Status Card
              ConnectionStatusCardWidget(
                connectionStatus: _connectionStatus,
                isConnecting: _isConnecting,
              ),

              SizedBox(height: 10.h), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: NetworkScanFabWidget(
        isScanning: _isScanning,
        onScanPressed: _scanNetwork,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
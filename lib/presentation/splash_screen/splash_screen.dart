import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _loadingOpacityAnimation;

  bool _isInitializing = true;
  String _initializationStatus = 'Initializing...';
  List<String> _savedIpAddresses = [];
  bool _hasNetworkConnection = false;
  bool _lastConnectionSuccessful = false;
  late Dio _httpClient;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Loading animation controller
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo opacity animation
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    // Loading opacity animation
    _loadingOpacityAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start logo animation
    _logoAnimationController.forward();
  }

  Future<void> _startInitialization() async {
    try {
      // Step 1: Initialize HTTP client
      await _initializeHttpClient();

      // Step 2: Check network connectivity
      await _checkNetworkConnectivity();

      // Step 3: Load saved IP addresses
      await _loadSavedIpAddresses();

      // Step 4: Verify last connection status
      await _verifyLastConnection();

      // Step 5: Prepare sensor data cache
      await _prepareSensorDataCache();

      // Wait minimum splash duration for better UX
      await Future.delayed(const Duration(milliseconds: 2500));

      // Navigate based on initialization results
      await _navigateToNextScreen();
    } catch (e) {
      // Handle initialization errors gracefully
      setState(() {
        _initializationStatus = 'Initialization failed';
      });

      // Still navigate after delay to prevent app from being stuck
      await Future.delayed(const Duration(milliseconds: 1000));
      await _navigateToNextScreen();
    }
  }

  Future<void> _initializeHttpClient() async {
    setState(() {
      _initializationStatus = 'Initializing services...';
    });

    _httpClient = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging and error handling
    _httpClient.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));

    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _checkNetworkConnectivity() async {
    setState(() {
      _initializationStatus = 'Checking network...';
    });

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _hasNetworkConnection =
          connectivityResult == ConnectivityResult.wifi ||
              connectivityResult == ConnectivityResult.mobile;
    } catch (e) {
      _hasNetworkConnection = false;
    }

    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<void> _loadSavedIpAddresses() async {
    setState(() {
      _initializationStatus = 'Loading saved devices...';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIps = prefs.getStringList('saved_ip_addresses') ?? [];
      _savedIpAddresses = savedIps;
    } catch (e) {
      _savedIpAddresses = [];
    }

    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _verifyLastConnection() async {
    if (_savedIpAddresses.isEmpty || !_hasNetworkConnection) {
      _lastConnectionSuccessful = false;
      return;
    }

    setState(() {
      _initializationStatus = 'Verifying connections...';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSuccessfulIp = prefs.getString('last_successful_ip');
      final lastConnectionTime = prefs.getInt('last_connection_time') ?? 0;

      // Check if last connection was within the last 24 hours
      final now = DateTime.now().millisecondsSinceEpoch;
      final timeDifference = now - lastConnectionTime;
      final twentyFourHours = 24 * 60 * 60 * 1000;

      if (lastSuccessfulIp != null &&
          _savedIpAddresses.contains(lastSuccessfulIp) &&
          timeDifference < twentyFourHours) {
        // Quick ping to verify if device is still accessible
        try {
          final response = await _httpClient.get(
            'http://$lastSuccessfulIp/status',
            options: Options(
              sendTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
            ),
          );
          _lastConnectionSuccessful = response.statusCode == 200;
        } catch (e) {
          _lastConnectionSuccessful = false;
        }
      } else {
        _lastConnectionSuccessful = false;
      }
    } catch (e) {
      _lastConnectionSuccessful = false;
    }

    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _prepareSensorDataCache() async {
    setState(() {
      _initializationStatus = 'Preparing cache...';
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Initialize sensor data cache structure
      final cacheKeys = [
        'temperature_cache',
        'humidity_cache',
        'gas_mq6_cache',
        'gas_mq7_cache',
        'current_cache',
        'voltage_cache',
        'ir_sensor_cache',
        'motion_sensor_cache',
        'flame_sensor_cache',
      ];

      for (String key in cacheKeys) {
        if (!prefs.containsKey(key)) {
          await prefs.setStringList(key, []);
        }
      }

      // Set cache initialization timestamp
      await prefs.setInt(
          'cache_initialized_time', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Cache preparation failed, but continue
    }

    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<void> _navigateToNextScreen() async {
    setState(() {
      _isInitializing = false;
      _initializationStatus = 'Ready!';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Navigation logic based on initialization results
    if (_savedIpAddresses.isNotEmpty &&
        _lastConnectionSuccessful &&
        _hasNetworkConnection) {
      // User has saved IPs and last connection was successful - go to dashboard
      Navigator.pushReplacementNamed(context, '/dashboard-screen');
    } else {
      // New user or connection issues - go to home screen for IP configuration
      Navigator.pushReplacementNamed(context, '/home-screen');
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryLight,
              AppTheme.primaryVariantLight,
              const Color(0xFF0A1929),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer to push content to center
              const Spacer(flex: 2),

              // Logo section
              AnimatedBuilder(
                animation: _logoAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacityAnimation.value,
                    child: Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: _buildLogoSection(),
                    ),
                  );
                },
              ),

              SizedBox(height: 8.h),

              // Loading section
              AnimatedBuilder(
                animation: _loadingAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _loadingOpacityAnimation.value,
                    child: _buildLoadingSection(),
                  );
                },
              ),

              // Spacer to balance layout
              const Spacer(flex: 3),

              // Version info
              _buildVersionInfo(),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Industrial IoT Logo
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'settings_input_antenna',
              color: AppTheme.lightTheme.colorScheme.surface,
              size: 12.w,
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // App title
        Text(
          'AI Industry',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.surface,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),

        SizedBox(height: 1.h),

        Text(
          'Fault Monitor',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color:
                AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.8,
          ),
        ),

        SizedBox(height: 2.h),

        // Subtitle
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Text(
            'Real-time ESP32 sensor monitoring\nfor industrial safety',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        // Loading indicator
        SizedBox(
          width: 8.w,
          height: 8.w,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.8),
            ),
            backgroundColor:
                AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.2),
          ),
        ),

        SizedBox(height: 3.h),

        // Status text
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            _initializationStatus,
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Progress indicators
        _buildProgressIndicators(),
      ],
    );
  }

  Widget _buildProgressIndicators() {
    final indicators = [
      {'label': 'Services', 'completed': true},
      {'label': 'Network', 'completed': _hasNetworkConnection},
      {'label': 'Devices', 'completed': _savedIpAddresses.isNotEmpty},
      {'label': 'Cache', 'completed': !_isInitializing},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: indicators.map((indicator) {
          final isCompleted = indicator['completed'] as bool;
          return Column(
            children: [
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppTheme.successLight
                      : AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.3),
                ),
                child: isCompleted
                    ? Center(
                        child: CustomIconWidget(
                          iconName: 'check',
                          color: AppTheme.lightTheme.colorScheme.surface,
                          size: 2.w,
                        ),
                      )
                    : null,
              ),
              SizedBox(height: 1.h),
              Text(
                indicator['label'] as String,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.6),
                  fontSize: 8.sp,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          Text(
            'Version 1.0.0',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.5),
              fontSize: 9.sp,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Industrial IoT Solutions',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.4),
              fontSize: 8.sp,
            ),
          ),
        ],
      ),
    );
  }
}
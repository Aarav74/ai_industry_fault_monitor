import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class SensorChartWidget extends StatefulWidget {
  final String sensorName;
  final List<Map<String, dynamic>> chartData;
  final String selectedPeriod;
  final bool isVisible;

  const SensorChartWidget({
    Key? key,
    required this.sensorName,
    required this.chartData,
    required this.selectedPeriod,
    required this.isVisible,
  }) : super(key: key);

  @override
  State<SensorChartWidget> createState() => _SensorChartWidgetState();
}

class _SensorChartWidgetState extends State<SensorChartWidget> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Container(
        height: 35.h,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                    color: _getSensorColor(widget.sensorName),
                    borderRadius: BorderRadius.circular(2))),
            SizedBox(width: 2.w),
            Text(widget.sensorName,
                style: AppTheme.lightTheme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            CustomIconWidget(
                iconName: 'info_outline',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 18),
          ]),
          SizedBox(height: 2.h),
          Expanded(
              child: LineChart(
                  LineChartData(
                      gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                                color: AppTheme.lightTheme.colorScheme.outline
                                    .withValues(alpha: 0.1),
                                strokeWidth: 1);
                          }),
                      titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                    if (value.toInt() >= 0 &&
                                        value.toInt() <
                                            widget.chartData.length) {
                                      final data =
                                          widget.chartData[value.toInt()];
                                      return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Text(data['label'] as String,
                                              style: AppTheme.lightTheme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(fontSize: 10.sp)));
                                    }
                                    return const Text('');
                                  })),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 5,
                                  reservedSize: 42,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                    return Text(value.toInt().toString(),
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(fontSize: 10.sp));
                                  }))),
                      borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.2))),
                      minX: 0,
                      maxX: (widget.chartData.length - 1).toDouble(),
                      minY: 0,
                      maxY: _getMaxValue(),
                      lineBarsData: [
                        LineChartBarData(
                            spots: _generateSpots(),
                            isCurved: true,
                            gradient: LinearGradient(colors: [
                              _getSensorColor(widget.sensorName),
                              _getSensorColor(widget.sensorName)
                                  .withValues(alpha: 0.3),
                            ]),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                      radius: touchedIndex == index ? 6 : 4,
                                      color: _getSensorColor(widget.sensorName),
                                      strokeWidth: 2,
                                      strokeColor: AppTheme
                                          .lightTheme.colorScheme.surface);
                                }),
                            belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                    colors: [
                                      _getSensorColor(widget.sensorName)
                                          .withValues(alpha: 0.2),
                                      _getSensorColor(widget.sensorName)
                                          .withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter))),
                      ],
                      lineTouchData: LineTouchData(
                          enabled: true,
                          touchCallback: (FlTouchEvent event,
                              LineTouchResponse? touchResponse) {
                            setState(() {
                              if (touchResponse != null &&
                                  touchResponse.lineBarSpots != null) {
                                touchedIndex =
                                    touchResponse.lineBarSpots!.first.spotIndex;
                              } else {
                                touchedIndex = null;
                              }
                            });
                          },
                          touchTooltipData: LineTouchTooltipData(
                              tooltipRoundedRadius: 8,
                              getTooltipItems:
                                  (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((barSpot) {
                                  final flSpot = barSpot;
                                  if (flSpot.x.toInt() >= 0 &&
                                      flSpot.x.toInt() <
                                          widget.chartData.length) {
                                    final data =
                                        widget.chartData[flSpot.x.toInt()];
                                    return LineTooltipItem(
                                        '${data['label']}\n${flSpot.y.toStringAsFixed(1)} ${_getUnit(widget.sensorName)}',
                                        AppTheme.lightTheme.textTheme.bodySmall
                                                ?.copyWith(
                                                    color: AppTheme
                                                        .lightTheme
                                                        .colorScheme
                                                        .onInverseSurface,
                                                    fontWeight:
                                                        FontWeight.w500) ??
                                            const TextStyle());
                                  }
                                  return null;
                                }).toList();
                              }))),
                  duration: AppTheme.normalAnimation,
                  curve: Curves.easeInOut)),
        ]));
  }

  List<FlSpot> _generateSpots() {
    return widget.chartData.asMap().entries.map((entry) {
      return FlSpot(
          entry.key.toDouble(), (entry.value['value'] as num).toDouble());
    }).toList();
  }

  double _getMaxValue() {
    if (widget.chartData.isEmpty) return 100;
    final maxValue = widget.chartData
        .map((data) => (data['value'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).ceilToDouble();
  }

  Color _getSensorColor(String sensorName) {
    switch (sensorName.toLowerCase()) {
      case 'temperature':
        return const Color(0xFFFF6B35);
      case 'humidity':
        return const Color(0xFF2E7D32);
      case 'gas (lpg)':
        return const Color(0xFFF57C00);
      case 'gas (co2)':
        return const Color(0xFF9C27B0);
      case 'current':
        return const Color(0xFF1976D2);
      case 'voltage':
        return const Color(0xFFD32F2F);
      case 'motion':
        return const Color(0xFF388E3C);
      case 'flame':
        return const Color(0xFFFF5722);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getUnit(String sensorName) {
    switch (sensorName.toLowerCase()) {
      case 'temperature':
        return '°C';
      case 'humidity':
        return '%';
      case 'gas (lpg)':
      case 'gas (co2)':
        return 'ppm';
      case 'current':
        return 'A';
      case 'voltage':
        return 'V';
      case 'motion':
      case 'flame':
        return '';
      default:
        return '';
    }
  }
}

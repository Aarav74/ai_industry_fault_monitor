import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AlertCardWidget extends StatefulWidget {
  final Map<String, dynamic> alert;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onSnooze;
  final VoidCallback? onViewDetails;
  final VoidCallback? onMarkResolved;
  final bool isExpanded;
  final VoidCallback? onTap;

  const AlertCardWidget({
    Key? key,
    required this.alert,
    this.onAcknowledge,
    this.onSnooze,
    this.onViewDetails,
    this.onMarkResolved,
    this.isExpanded = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<AlertCardWidget> createState() => _AlertCardWidgetState();
}

class _AlertCardWidgetState extends State<AlertCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(AlertCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final severity = widget.alert['severity'] as String? ?? 'low';
    final color = _getAlertColor(severity);
    final isResolved = widget.alert['status'] == 'resolved';

    return Dismissible(
      key: Key(widget.alert['id'].toString()),
      background: _buildSwipeBackground(true),
      secondaryBackground: _buildSwipeBackground(false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          widget.onAcknowledge?.call();
        } else {
          widget.onMarkResolved?.call();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: isResolved ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            child: Column(
              children: [
                _buildMainContent(color, isResolved),
                AnimatedBuilder(
                  animation: _expandAnimation,
                  builder: (context, child) {
                    return SizeTransition(
                      sizeFactor: _expandAnimation,
                      child: _buildExpandedContent(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(Color color, bool isResolved) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName:
                    _getAlertIcon(widget.alert['type'] as String? ?? 'info'),
                color: color,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.alert['sensorName'] as String? ??
                            'Unknown Sensor',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isResolved
                              ? AppTheme.textSecondaryLight
                              : AppTheme.textPrimaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isResolved)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.statusColors['success']!
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Text(
                          'Resolved',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.statusColors['success'],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  widget.alert['message'] as String? ?? 'No message available',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'access_time',
                      color: AppTheme.textSecondaryLight,
                      size: 14.sp,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _formatTimestamp(widget.alert['timestamp']),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    const Spacer(),
                    if (widget.alert['currentValue'] != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Text(
                          '${widget.alert['currentValue']} ${widget.alert['unit'] ?? ''}',
                          style: AppTheme.dataTextTheme(isLight: true)
                              .bodyMedium
                              ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          CustomIconWidget(
            iconName: widget.isExpanded ? 'expand_less' : 'expand_more',
            color: AppTheme.textSecondaryLight,
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: AppTheme.dividerLight,
            height: 2.h,
          ),
          if (widget.alert['thresholdExceeded'] != null) ...[
            Text(
              'Threshold Information',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Threshold',
                    '${widget.alert['thresholdExceeded']} ${widget.alert['unit'] ?? ''}',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Current',
                    '${widget.alert['currentValue']} ${widget.alert['unit'] ?? ''}',
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
          ],
          if (widget.alert['recommendedActions'] != null) ...[
            Text(
              'Recommended Actions',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            ...(widget.alert['recommendedActions'] as List<String>).map(
              (action) => Padding(
                padding: EdgeInsets.only(bottom: 0.5.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomIconWidget(
                      iconName: 'check_circle_outline',
                      color: AppTheme.statusColors['success'],
                      size: 16.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        action,
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onAcknowledge,
                  icon: CustomIconWidget(
                    iconName: 'check',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 16.sp,
                  ),
                  label: const Text('Acknowledge'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onSnooze,
                  icon: CustomIconWidget(
                    iconName: 'snooze',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 16.sp,
                  ),
                  label: const Text('Snooze'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.dataTextTheme(isLight: true).bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildSwipeBackground(bool isLeft) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft
            ? AppTheme.statusColors['success']
            : AppTheme.statusColors['error'],
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeft ? 'check' : 'close',
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isLeft ? 'Acknowledge' : 'Resolve',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAlertColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppTheme.statusColors['critical']!;
      case 'high':
        return AppTheme.statusColors['error']!;
      case 'medium':
        return AppTheme.statusColors['warning']!;
      case 'low':
        return AppTheme.statusColors['info']!;
      default:
        return AppTheme.statusColors['info']!;
    }
  }

  String _getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'temperature':
        return 'thermostat';
      case 'humidity':
        return 'water_drop';
      case 'gas':
        return 'air';
      case 'current':
        return 'electrical_services';
      case 'voltage':
        return 'bolt';
      case 'motion':
        return 'directions_run';
      case 'flame':
        return 'local_fire_department';
      case 'ir':
        return 'sensors';
      default:
        return 'warning';
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown time';

    try {
      DateTime dateTime;
      if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else {
        return 'Invalid time';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
      }
    } catch (e) {
      return 'Invalid time';
    }
  }
}

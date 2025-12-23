import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';

class StatusGauge extends StatefulWidget {
  final String label;
  final String status;
  final Color statusColor;
  final IconData icon;

  const StatusGauge({
    super.key,
    required this.label,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  @override
  State<StatusGauge> createState() => _StatusGaugeState();
}

class _StatusGaugeState extends State<StatusGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start animation after a brief delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppStyles.cardDecoration(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Label
          Text(
            widget.label,
            style: AppStyles.legendText(context).copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Status indicator
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with colored background
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.statusColor.withOpacity(0.15),
                        border: Border.all(
                          color: widget.statusColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Status text
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.status,
                        style: TextStyle(
                          color: widget.statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      ),
    );
  }
}

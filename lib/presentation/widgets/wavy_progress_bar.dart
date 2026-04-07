import 'dart:math' as math;
import 'package:flutter/material.dart';

class WavyProgressBar extends StatefulWidget {
  final double progress;
  final double height;
  final Color? color;

  const WavyProgressBar({
    super.key,
    required this.progress,
    this.height = 12.0,
    this.color,
  });

  @override
  State<WavyProgressBar> createState() => _WavyProgressBarState();
}

class _WavyProgressBarState extends State<WavyProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        // Don't draw negative widths
        final progressWidth = math.max((totalWidth * widget.progress).toDouble(), 0.0);

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: progressWidth,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(widget.height / 2),
                  boxShadow: [
                    BoxShadow(color: accentColor.withAlpha(100), blurRadius: 8, offset: const Offset(0, 2))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.height / 2),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return FractionalTranslation(
                        translation: Offset(_controller.value * 2 - 1, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withAlpha(0),
                                Colors.white.withAlpha(70),
                                Colors.white.withAlpha(0),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

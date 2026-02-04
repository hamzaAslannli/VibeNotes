import 'dart:math';
import 'package:flutter/material.dart';

class WaveformWidget extends StatefulWidget {
  final bool isRecording;
  final double amplitude; // 0.0 to 1.0
  final Color color;

  const WaveformWidget({
    super.key,
    this.isRecording = false,
    this.amplitude = 0.5,
    this.color = Colors.deepPurpleAccent,
  });

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _barHeights = List.generate(20, (_) => 0.3);
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(_updateBars);
    
    if (widget.isRecording) {
      _controller.repeat();
    }
  }

  void _updateBars() {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _barHeights.length; i++) {
        if (widget.isRecording) {
          // Animate bars based on amplitude
          final baseHeight = 0.2 + (widget.amplitude * 0.6);
          _barHeights[i] = baseHeight + (_random.nextDouble() * 0.3 * widget.amplitude);
        } else {
          // Settle to low height
          _barHeights[i] = 0.15 + (_random.nextDouble() * 0.1);
        }
      }
    });
  }

  @override
  void didUpdateWidget(WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRecording && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_barHeights.length, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: 60 * _barHeights[index],
            decoration: BoxDecoration(
              color: widget.color.withOpacity(widget.isRecording ? 1.0 : 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

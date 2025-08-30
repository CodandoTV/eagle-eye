import 'package:flutter/material.dart';

const double containerHeight = 9.0;

class ProgressWidget extends StatelessWidget {
  late final double _progress;
  late final Color _color;

  /// progress should be at max 1
  ProgressWidget({super.key, required double progress}) {
    _progress = progress.clamp(0.0, 1.0);

    if (progress == 1) {
      _color = Colors.green;
    } else {
      _color = Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: containerHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onTertiary,
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => _buildProgressBar(
            progress: _progress,
            maxWidth: constraints.maxWidth,
            color: _color,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar({
    required double progress,
    required double maxWidth,
    required Color color,
  }) {
    final double endWidth = maxWidth * progress;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: endWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        color: color,
      ),
    );
  }

  Color baseColor() {
    return _color;
  }
}

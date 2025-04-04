import 'package:flutter/material.dart';

import '../styles.dart';

class SparkleLeaf extends StatelessWidget {
  final double size;
  final Color color;
  final double leafSize;
  final double sparkleSize;

  const SparkleLeaf({
    super.key,
    this.size = 32,
    this.color = AppColors.appBackground,
    this.leafSize = 24,
    this.sparkleSize = 12,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      children: [
        Positioned(
          left: (size - leafSize) / 2,
          top: (size - leafSize) / 2,
          child: Icon(Icons.eco_outlined, color: color, size: leafSize),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Icon(Icons.auto_awesome, color: color, size: sparkleSize),
        ),
      ],
    ),
  );
}

class ProductPlaceholderSparkleLeaf extends StatelessWidget {
  final double size;
  final Color color;
  final double leafSize;
  final double sparkleSize;

  const ProductPlaceholderSparkleLeaf({
    super.key,
    this.size = 60,
    this.color = AppColors.primary,
    this.leafSize = 50,
    this.sparkleSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: AppColors.panelBackground),
        child: Stack(
          children: [
            Positioned(
              left: 10 + (size - leafSize) / 2,
              top: (size - leafSize) / 2,
              child: Icon(Icons.eco_outlined, color: color, size: leafSize),
            ),
            Positioned(
              top: 0,
              left: 10,
              child: Icon(Icons.auto_awesome, color: color, size: sparkleSize),
            ),
          ],
        ),
      ),
    );
  }
}

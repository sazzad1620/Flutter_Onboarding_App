import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;

  const GradientContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Figma design size
    const designWidth = 360;
    const designHeight = 800;

    double fracX(double px) => px / designWidth;
    double fracY(double px) => px / designHeight;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 11, 0, 36),
            Color.fromARGB(255, 8, 34, 87),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Ellipse left center
          Positioned(
            top: screenHeight * fracY(280),
            left: screenWidth * fracX(-210),
            child: Container(
              width: screenWidth * fracX(400),
              height: screenHeight * fracY(400),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color.fromRGBO(82, 0, 255, 0.2), Colors.transparent],
                  radius: 0.8,
                  center: Alignment.center,
                ),
              ),
            ),
          ),

          // Ellipse upper right
          Positioned(
            top: screenHeight * fracY(150),
            left: screenWidth * fracX(210),
            child: Container(
              width: screenWidth * fracX(200),
              height: screenHeight * fracY(200),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.fromRGBO(81, 0, 255, 0.12),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                  center: Alignment.center,
                ),
              ),
            ),
          ),

          // Ellipse 3 lower right
          Positioned(
            top: screenHeight * fracY(450),
            left: screenWidth * fracX(170),
            child: Container(
              width: screenWidth * fracX(400),
              height: screenHeight * fracY(400),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color.fromRGBO(82, 0, 255, 0.2), Colors.transparent],
                  radius: 0.8,
                  center: Alignment.center,
                ),
              ),
            ),
          ),

          // Child content
          child,
        ],
      ),
    );
  }
}

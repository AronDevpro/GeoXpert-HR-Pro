import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../main_image_with_logo.dart';

class BackgroundAndCard extends StatelessWidget {
  final Widget child;

  const BackgroundAndCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MainImageWithLogo(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: SECONDARY.withOpacity(0.95),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

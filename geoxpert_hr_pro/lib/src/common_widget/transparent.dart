// lib/widgets/transparent_card.dart
import 'package:flutter/material.dart';

import '../constants/colors.dart';

class TransparentCard extends StatelessWidget {
  final Widget child;

  const TransparentCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: SECONDARY.withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
        child: child,
      ),
    );
  }
}

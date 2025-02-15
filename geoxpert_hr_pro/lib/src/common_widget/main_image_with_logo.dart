import 'package:flutter/material.dart';
import '../constants/colors.dart';

class MainImageWithLogo extends StatelessWidget {
  final Widget child;

  const MainImageWithLogo({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [SLATE, SKY],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: child
            ),
          ),
        ),
      ),
    );
  }
}

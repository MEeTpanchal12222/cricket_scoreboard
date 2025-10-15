import 'package:flutter/material.dart';

const double kMobileBreakpoint = 700.0;

class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget mobileLayout;
  final Widget webLayout;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobileLayout,
    required this.webLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < kMobileBreakpoint) {
          return mobileLayout;
        } else {
          return webLayout;
        }
      },
    );
  }
}

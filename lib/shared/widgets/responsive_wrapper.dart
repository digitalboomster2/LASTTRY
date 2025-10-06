import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 400,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // For mobile (width < 768), use original padding
        if (constraints.maxWidth < 768) {
          return Padding(
            padding: padding,
            child: child,
          );
        }
        
        // For desktop, center the content with max width
        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

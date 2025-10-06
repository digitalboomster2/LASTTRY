import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final double maxWidth;
  final Color? backgroundColor;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.maxWidth = 400,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: appBar,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // For mobile (width < 768), use original body
          if (constraints.maxWidth < 768) {
            return body;
          }
          
          // For desktop, center the content with max width
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: body,
            ),
          );
        },
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

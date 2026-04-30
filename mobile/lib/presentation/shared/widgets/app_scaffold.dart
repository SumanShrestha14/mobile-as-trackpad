import 'package:flutter/material.dart';
import '../constants.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.child,
    this.body,
    this.title,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  final Widget? child;
  final Widget? body;
  final String? title;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(titleSpacing: kSpacingUnit * 2, title: Text(title!)),
      body: body ?? child,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

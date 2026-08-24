import 'package:flutter/material.dart';

class ThemedDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;

  const ThemedDialog({
    required this.title,
    required this.child,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF151B23),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: child,
      actions: actions,
    );
  }
}

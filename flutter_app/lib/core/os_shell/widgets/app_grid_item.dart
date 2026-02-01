import 'package:flutter/material.dart';
import '../../micro_app.dart';
import 'micro_app_icon_container.dart';

class OSShellAppItem extends StatelessWidget {
  final MicroApp app;
  final VoidCallback onTap;

  const OSShellAppItem({super.key, required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: MicroAppIconContainer(
          app: app,
          size: double.infinity,
          borderRadius: 18,
          showShadow: true,
        ),
      ),
    );
  }
}

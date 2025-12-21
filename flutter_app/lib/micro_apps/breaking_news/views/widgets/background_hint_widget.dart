import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';

class BackgroundHintWidget extends StatelessWidget {
  const BackgroundHintWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Left Hint (Refuse)
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Opacity(
              opacity: 0.4, // Increased visibility
              child: RotatedBox(
                quarterTurns: 0,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 64,
                  color: AppColors.breakingNewsRed,
                ),
              ),
            ),
          ),
        ),
        
        // Right Hint (Save)
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Opacity(
              opacity: 0.4, // Increased visibility
              child: Icon(
                Icons.arrow_forward_ios,
                size: 64,
                color: AppColors.brandBase, // Blue/Green brand
              ),
            ),
          ),
        ),
        
        // Top/Center Hint (Flip?) 
        // Or specific arrows like user drew?
        // Let's stick to simple side indicators as base, 
        // User drew curved arrows at top.
        // We can add those as custom painters later if needed, 
        // but simple icons are cleaner for now.
      ],
    );
  }
}

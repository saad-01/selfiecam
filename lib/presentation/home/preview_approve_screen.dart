import 'package:flutter/material.dart';

import '../../infrastructure/constants/app_assets.dart';

class PreviewApproveScreen extends StatelessWidget {
  const PreviewApproveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.background4, fit: BoxFit.fill),
          ),
        ],
      ),
    );
  }
}

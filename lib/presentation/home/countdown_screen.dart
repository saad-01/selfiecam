import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:selfiecam1/infrastructure/navigation/routes.dart';

import '../../infrastructure/constants/app_assets.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int _counter = 3;
  bool _isCounting = true;
  Timer? _timer;

  final Map<int, String> _countdownText = {
    3: "GET MOVING,\nIT'S A VIDEO!",
    2: "STRIKE A POSE!",
    1: "GET READY FOR\n4 QUICK SHOTS!",
  };

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 1) {
        setState(() {
          _counter--;
        });
      } else {
        setState(() {
          _isCounting = false;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.background4, fit: BoxFit.fill),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isCounting) ...[
                Text(
                  _countdownText[_counter] ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: 90,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                Gap(60),
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$_counter',
                      style: const TextStyle(
                        fontFamily: 'Akshar',
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const Text(
                  "GET READY FOR\n4 QUICK SHOTS!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: 90,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                Gap(120),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(Routes.PREVIEW);
                        },
                        child: Container(
                          width: 120,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(color: Colors.white, width: 2.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

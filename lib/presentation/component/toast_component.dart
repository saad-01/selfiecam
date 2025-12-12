import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- 1. The Custom Toast Widget with State Management ---
class CustomToastWithCheckbox extends StatefulWidget {
  final OverlayEntry overlayEntry;
  final Function onCheckedNavigate;

  const CustomToastWithCheckbox({
    super.key,
    required this.overlayEntry,
    required this.onCheckedNavigate,
  });

  @override
  State<CustomToastWithCheckbox> createState() =>
      _CustomToastWithCheckboxState();
}

class _CustomToastWithCheckboxState extends State<CustomToastWithCheckbox> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50.0, left: 20.0, right: 20.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: SizedBox(
                height: Get.height * 0.06,
                width: Get.width * 0.6,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Checkbox
                    SizedBox(
                      height: 24.0,
                      width: 24.0,
                      child: Checkbox(
                        value: _isChecked,
                        onChanged: (bool? newValue) {
                          if (newValue == true) {
                            setState(() {
                              _isChecked = true;
                            });

                            widget.overlayEntry.remove();
                            widget.onCheckedNavigate();
                          } else {
                            setState(() {
                              _isChecked = false;
                            });
                          }
                        },
                        activeColor: Colors.deepPurple,
                        checkColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    const SizedBox(width: 10),

                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Text(
                          "I have read and agree to the Privacy Policy and wish to receive the newsletter and other marketing communication as set out therein.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:selfiecam1/presentation/component/button_component1.dart';
import 'dart:ui'; // <<< ADD THIS IMPORT for ImageFilter.blur
import '../../infrastructure/constants/app_assets.dart' show AppAssets;

class Phone extends StatefulWidget {
  const Phone({super.key});

  @override
  State<Phone> createState() => _PhoneState();
}

class _PhoneState extends State<Phone> {
  String _phoneNumber = '0000000000';

  String _formatPhoneNumber(String number) {
    // Ensure the number is always 10 characters long, padding with '0's
    String display = number.padRight(10, '0');
    // Format: 000 000 0000
    return '${display.substring(0, 3)} ${display.substring(3, 6)} ${display.substring(6, 10)}';
  }

  // Handle key press from the dialer pad
  void _handleKeyPressed(String key) {
    setState(() {
      if (key == 'delete') {
        // Remove the last digit, if number is not just '0'
        if (_phoneNumber.length > 1) {
          _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
        } else if (_phoneNumber.length == 1 && _phoneNumber != '0') {
          _phoneNumber = '0';
        }
      } else if (key.length == 1 &&
          _phoneNumber.length < 10 &&
          RegExp(r'[0-9]').hasMatch(key)) {
        // Only append numbers (0-9) and limit to 10 digits
        if (_phoneNumber == '0') {
          _phoneNumber = key;
        } else {
          _phoneNumber += key;
        }
      } else if (key == '+' || key == '-') {
        // Handle '+' or '-' logic here if needed, but they won't change the number display format
        print('Key pressed: $key');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final List<String> dialerKeys = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '+',
      '0',
      '-',
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          Positioned.fill(
            // NOTE: Agar AppAssets.background3 PNG/JPG hai, toh BoxFit.cover use karein.
            child: Image.asset(AppAssets.background3, fit: BoxFit.cover),
          ),

          // 3. Main Content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 50.0,
            ),
            child: Column(
              children: <Widget>[
                // Phone Display
                Text(
                  "PHONE",
                  style: textTheme.headlineMedium!.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _formatPhoneNumber(_phoneNumber),
                  style: textTheme.labelLarge!.copyWith(letterSpacing: 1),
                ),
                Gap(40),

                // C. Dialer Pad Grid
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 60.0,
                          mainAxisSpacing: 20.0,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: dialerKeys.length,
                    itemBuilder: (context, index) {
                      return _buildDialerKey(dialerKeys[index]);
                    },
                  ),
                ),

                // D. Action Buttons
                _buildActionButtons(), Gap(10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom key button for the dialer pad
  Widget _buildDialerKey(String key) {
    // Focus effect on the key that was just pressed (or '3' for initial look)
    // To make this dynamic, you'd track the last pressed key in state.
    final isFocused =
        (key == _phoneNumber.substring(_phoneNumber.length - 1) && key != '0');

    return InkWell(
      onTap: () => _handleKeyPressed(key),
      customBorder: const CircleBorder(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          shape: BoxShape.circle,
          border: isFocused ? Border.all(color: Colors.white, width: 3) : null,
        ),
        child: Center(
          child: Text(
            key,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40, // <<< FONT SIZE INCREASED TO 40 HERE
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Custom action buttons at the bottom (Red X and White Arrow)
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Red 'X' Button (Delete/Cancel)
        _buildCircleButton(
          Colors.black,
          Icons.close,
          // Red button press: Delete last digit
          () => _handleKeyPressed('delete'),
          size: 70,
        ),
        const SizedBox(width: 40),
        // White Arrow Button (Continue/Submit)
        _buildCircleButton(
          Colors.white,
          Icons.arrow_forward,
          () => print('Submit/Continue Pressed: $_phoneNumber'),
          size: 70,
          iconColor: Colors.black,
        ),
      ],
    );
  }

  // Reusable Circle Button
  Widget _buildCircleButton(
    Color color,
    IconData icon,
    VoidCallback onPressed, {
    double size = 60,
    Color iconColor = Colors.white,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: Icon(icon, color: iconColor, size: size * 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

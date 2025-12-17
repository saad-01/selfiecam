import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';
import 'package:selfiecam1/presentation/component/button_component1.dart';
import '../../infrastructure/constants/app_assets.dart';

class Phone extends StatefulWidget {
  const Phone({super.key});

  @override
  State<Phone> createState() => _PhoneState();
}

class _PhoneState extends State<Phone> {
  String _phoneNumber = '0000000000';

  String _formatPhoneNumber(String number) {
    String display = number.padRight(10, '0');
    return '${display.substring(0, 3)} ${display.substring(3, 6)} ${display.substring(6, 10)}';
  }

  void _handleKeyPressed(String key) {
    setState(() {
      if (key == 'delete') {
        if (_phoneNumber.length > 1) {
          _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
        } else {
          _phoneNumber = '0';
        }
      } else if (RegExp(r'[0-9]').hasMatch(key) && _phoneNumber.length < 10) {
        _phoneNumber = _phoneNumber == '0' ? key : _phoneNumber + key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final dialerKeys = [
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
          Positioned.fill(
            child: Image.asset(AppAssets.background3, fit: BoxFit.cover),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            child: Column(
              children: [
                /// TITLE
                Text(
                  'PHONE',
                  style: textTheme.headlineMedium!.copyWith(
                    color: Colors.white,
                    fontSize: 22.sp,
                  ),
                ),

                Gap(1.h),

                /// PHONE NUMBER
                Text(
                  _formatPhoneNumber(_phoneNumber),
                  style: textTheme.labelLarge!.copyWith(
                    fontSize: 22.sp,
                    letterSpacing: 1.5,
                  ),
                ),

                Gap(4.h),

                /// DIALER
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 9.w,
                      mainAxisSpacing: 2.0.h,
                      childAspectRatio: 1,
                    ),
                    itemCount: dialerKeys.length,
                    itemBuilder: (_, index) =>
                        _buildDialerKey(dialerKeys[index]),
                  ),
                ),

                Gap(2.h),

                /// ACTION BUTTONS
                _buildActionButtons(),


              ],
            ),
          ),
        ],
      ),
    );
  }

  /// DIALER KEY
  Widget _buildDialerKey(String key) {
    final isFocused = (key == _phoneNumber.characters.last && key != '0');

    return InkWell(
      onTap: () => _handleKeyPressed(key),
      customBorder: const CircleBorder(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          shape: BoxShape.circle,
          border: isFocused
              ? Border.all(color: Colors.white, width: 0.5.w)
              : null,
        ),
        child: Center(
          child: Text(
            key,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// ACTION BUTTONS
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircleButton(
          color: Colors.black,
          icon: Icons.close,
          onPressed: () => _handleKeyPressed('delete'),
        ),
        Gap(6.w),
        _buildCircleButton(
          color: Colors.white,
          icon: Icons.arrow_forward,
          iconColor: Colors.black,
          onPressed: () {
            print('Continue: $_phoneNumber');
          },
        ),
      ],
    );
  }

  /// CIRCLE BUTTON
  Widget _buildCircleButton({
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
  }) {
    return Container(
      width: 8.h,
      height: 8.h,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Center(
          child: Icon(icon, size: 4.h, color: iconColor),
        ),
      ),
    );
  }
}

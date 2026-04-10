import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/presentation/component/back_button.dart';
import 'package:selfiecam1/presentation/home/countdown_screen.dart';
import 'package:sizer/sizer.dart';
import '../../infrastructure/constants/app_assets.dart';

class AiStylePreview extends StatefulWidget {
  const AiStylePreview({super.key, this.aiImageUrl, this.list});
  final dynamic list;
  final String? aiImageUrl;

  @override
  State<AiStylePreview> createState() => _AiStylePreviewState();
}

class _AiStylePreviewState extends State<AiStylePreview> {
  final camController = Get.find<CameraControllerX>();
  final RxInt _currentIndex = 0.obs;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get _totalItems => widget.list?.length ?? 1;

  String _styleName(int index) {
    if (widget.list == null) return '';
    final item = widget.list[index];
    return (item['name'] ?? item['id'] ?? 'STYLE ${index + 1}').toString().toUpperCase();
  }

  String _imageUrl(int index) {
    if (widget.list == null) return '';
    return widget.list[index]['referenceImage'] ?? '';
  }

  void _goTo(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // Positioned(child: child),
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                child: FadeInImage(
                  placeholder: AssetImage(AppAssets.background1), // same image
                  image: AssetImage(AppAssets.background1),
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 150),
                ),
              ),
            ),
            Obx(
              () => Column(
                children: [
                  // ── Header ──────────────────────────────────────────────
                  SizedBox(height: 4.h),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Align(alignment: Alignment.topLeft, child: CustomBackButton()),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Column(
                      children: [
                        Text(
                          'CHOOSE YOUR LOOK',
                          style: textTheme.displayLarge!.copyWith(fontSize: 25.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Tap an experience to let users choose',
                          style: textTheme.labelMedium!.copyWith(
                            letterSpacing: 0.3.w,
                            fontWeight: FontWeight.w100,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Main Image with arrows + badge ───────────────────────
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // PageView
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _totalItems,
                            onPageChanged: (i) => _currentIndex.value = i,
                            itemBuilder: (context, index) {
                              final url = _imageUrl(index);
                              return url.isNotEmpty
                                  ? Image.asset(url, fit: BoxFit.contain, width: double.infinity, height: double.infinity)
                                  : const SizedBox();
                            },
                          ),
                        ),

                        // "Style X of Y" badge — top-left
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              'Style ${_currentIndex.value + 1} of $_totalItems',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        // Left arrow
                        if (_currentIndex.value > 0)
                          Positioned(
                            left: 8,
                            child: _ArrowButton(icon: Icons.chevron_left, onTap: () => _goTo(_currentIndex.value - 1)),
                          ),

                        // Right arrow
                        if (_currentIndex.value < _totalItems - 1)
                          Positioned(
                            right: 8,
                            child: _ArrowButton(icon: Icons.chevron_right, onTap: () => _goTo(_currentIndex.value + 1)),
                          ),
                      ],
                    ),
                  ),

                  Gap(1.5.h),

                  // ── Style name ───────────────────────────────────────────
                  Text(
                    _styleName(_currentIndex.value),
                    style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800, letterSpacing: 1.4),
                  ),
                  Gap(0.4.h),
                  Text(
                    '↑ SWIPE OR TAP TO PICK A STYLE ↑',
                    style: textTheme.labelMedium!.copyWith(letterSpacing: 0.3.w, fontWeight: FontWeight.w100, fontSize: 15.sp),
                  ),

                  Gap(1.2.h),

                  // ── Thumbnail strip ──────────────────────────────────────
                  SizedBox(
                    height: 13.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      itemCount: _totalItems,
                      itemBuilder: (context, index) {
                        final isSelected = _currentIndex.value == index;
                        final url = _imageUrl(index);

                        return GestureDetector(
                          onTap: () => _goTo(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 18.w,
                            margin: EdgeInsets.only(right: 2.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2.5),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: url.isNotEmpty
                                      ? Image.asset(url, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                      : Container(color: Colors.white10),
                                ),
                                // Checkmark when selected
                                if (isSelected)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                      child: const Icon(Icons.check, size: 12, color: Colors.black),
                                    ),
                                  ),
                                // Label at bottom
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      _styleName(index),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 6.5.sp,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Gap(1.5.h),

                  // ── Bottom buttons ───────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      children: [
                        // Cancel
                        TextButton.icon(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close, color: Colors.white70, size: 16),
                          label: const Text('Cancel', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ),
                        const Spacer(),
                        // Use This Look
                        ElevatedButton(
                          onPressed: () {
                            DeviceController.to.styleId = widget.list[_currentIndex.value]['id'] ?? '';
                            Get.off(() => const CountdownScreen(type: 'Ai'));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.6.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'USE THIS LOOK',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.sp, letterSpacing: 0.8),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Gap(3.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable arrow button ─────────────────────────────────────────────────────
class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

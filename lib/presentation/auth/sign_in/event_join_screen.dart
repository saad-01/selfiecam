import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/infrastructure/constants/app_assets.dart';
import 'package:selfiecam1/controller/event_join_controller.dart';
import 'package:sizer/sizer.dart';

class EventDropdownView extends StatefulWidget {
  const EventDropdownView({super.key});

  @override
  State<EventDropdownView> createState() => _EventDropdownViewState();
}

class _EventDropdownViewState extends State<EventDropdownView> {
  final controller = Get.put(EventJoinController());
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getDeviceById();
      controller.getEvents();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
              child: Image.asset(AppAssets.background1, fit: BoxFit.cover),
            ),
          ),
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 100.h, // 🔥 full screen height
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Top Logo
                    SizedBox(
                      height: 18.h,
                      child: Center(
                        child: Image.asset(AppAssets.logo1, width: 60.w, fit: BoxFit.contain),
                      ),
                    ),

                    /// Center Form
                    Column(
                      children: [
                        Text('SELECT EVENT', style: textTheme.displayLarge),
                        SizedBox(height: 3.h),
                        Center(
                          child: Container(
                            width: 520, // iPad friendly width
                            padding: const EdgeInsets.all(24),
                            child: Obx(() {
                              return DropdownButtonFormField(
                                value: controller.selectedEvent.value,
                                isExpanded: true,
                                isDense: true, // 🔥 removes extra vertical padding
                                dropdownColor: Colors.white,
                                iconEnabledColor: Colors.black,

                                decoration: InputDecoration(
                                  hintText: "Select Event",
                                  hintStyle: const TextStyle(color: Colors.black54, fontSize: 18),

                                  filled: true,
                                  fillColor: Colors.white,

                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 18, // 👈 perfectly centered
                                  ),

                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Colors.white, width: 2),
                                  ),

                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Colors.white, width: 2),
                                  ),
                                ),

                                items: controller.eventsList.map((event) {
                                  return DropdownMenuItem(
                                    value: event,
                                    child: Text(event['eventName'], style: const TextStyle(color: Colors.black, fontSize: 20)),
                                  );
                                }).toList(),

                                onChanged: (event) {
                                  if (event != null) {
                                    controller.onEventSelected(event);
                                  }
                                },
                              );
                            }),
                          ),
                        ),
                        SizedBox(height: 4.h),

                        Divider(color: Colors.white, thickness: 0.3.h),
                      ],
                    ),

                    /// Bottom Logo
                    Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Image.asset(AppAssets.logo2, width: 55.w, height: 10.h, fit: BoxFit.contain),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:selfiecam1/controller/cam_controller.dart';
import 'package:selfiecam1/controller/device_controller.dart';
import 'package:selfiecam1/controller/leads_controller.dart';
import 'package:selfiecam1/data/models/lead_model.dart';
import 'package:selfiecam1/infrastructure/constants/app_assets.dart';
import 'package:selfiecam1/presentation/component/back_button.dart';
import 'package:selfiecam1/presentation/component/button_component.dart';
import 'package:selfiecam1/presentation/component/textfield_component.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

class LeadCaptureScreen extends StatefulWidget {
  const LeadCaptureScreen({super.key, this.capturedFile, required this.type, this.aiImageUrl});
  final XFile? capturedFile;
  final String type;
  final String? aiImageUrl;

  @override
  State<LeadCaptureScreen> createState() => _LeadCaptureScreenState();
}

class _LeadCaptureScreenState extends State<LeadCaptureScreen> {
  final camController = Get.find<CameraControllerX>();
  final controller = Get.put(LeadsController());

  bool _isImagePrecached = false;

  // ── Email dropdown state ──────────────────────────────────────────────────
  bool _isEmailFocused = false;
  TextEditingController? _focusedEmailController;
  List<String> _emailSuggestions = [];
  bool _isFetchingEmails = false;
  Timer? _debounce;

  // ── Email validation errors keyed by person index ─────────────────────────
  final Map<int, String?> _emailErrors = {};

  // ── Misc ──────────────────────────────────────────────────────────────────
  Timer? _popupTimer;
  var counter = 30.obs;

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns null when valid, error string when invalid.
  String? _validateEmail(String value) {
    if (value.trim().isEmpty) return null; // empty is handled by "required"
    final regex = RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(value.trim()) ? null : 'Enter a valid email address';
  }

  /// Debounced search: waits 500 ms of silence before hitting the API.
  void _onEmailChanged(String value) {
    _debounce?.cancel();

    // Clear suggestions immediately if field is blank
    if (value.trim().isEmpty) {
      setState(() {
        _emailSuggestions = [];
        _isFetchingEmails = false;
      });
      return;
    }

    setState(() => _isFetchingEmails = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _fetchEmailSuggestions(value.trim());
    });
  }

  Future<void> _fetchEmailSuggestions(String search) async {
    try {
      final results = await controller.dropdownApi(search); // returns List<String>
      if (mounted) {
        setState(() {
          _emailSuggestions = results;
          _isFetchingEmails = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isFetchingEmails = false);
    }
  }

  void _selectEmailSuggestion(String suggestion) {
    if (_focusedEmailController == null) return;
    _focusedEmailController!.value = TextEditingValue(
      text: suggestion,
      selection: TextSelection.collapsed(offset: suggestion.length),
    );
    setState(() {
      _emailSuggestions = [];
      _isEmailFocused = false;
    });
    FocusScope.of(context).unfocus();
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isImagePrecached) {
      precacheImage(AssetImage(AppAssets.background1), context);
      precacheImage(AssetImage(AppAssets.logo2), context);
      precacheImage(AssetImage(AppAssets.logo1), context);
      _isImagePrecached = true;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _popupTimer?.cancel();
    final vc = camController.videoController.value;
    if (vc != null && vc.value.isPlaying) {
      vc.pause();
      vc.seekTo(Duration.zero);
      camController.videoController.value = null;
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _emailSuggestions = [];
          _isEmailFocused = false;
        });
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // ── Background ──────────────────────────────────────────────────
            if ((widget.type == 'Photo' || widget.type == 'Ai') && widget.capturedFile != null)
              Positioned.fill(child: Image.file(File(camController.capturedFile!.value.path), fit: BoxFit.fill)),
            if (widget.type != 'Photo' && widget.type != 'Ai')
              Obx(() {
                if (!camController.isVideoInitialized.value || camController.videoController.value == null) {
                  return const SizedBox();
                }
                final vc = camController.videoController.value!;
                return Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(width: vc.value.size.width, height: vc.value.size.height, child: VideoPlayer(vc)),
                  ),
                );
              }),

            CustomScrollView(
              slivers: [
                // ── Sticky Back Button (SliverAppBar) ──────────────────────
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  pinned: true,
                  snap: true,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.only(left: 40, top: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CustomBackButton(
                        onTap: () {
                          Get.back();
                          Get.back();
                          Get.back();
                        },
                      ),
                    ),
                  ),
                ),

                // ── Main Scrollable Content ─────────────────────────────────
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  sliver: SliverToBoxAdapter(
                    child: Obx(() {
                      final config = controller.config.value;
                      if (config == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final fields = config.fields;
                      final hasAnyFieldEnabled =
                          fields.name.enabled ||
                          fields.email.enabled ||
                          fields.phone.enabled ||
                          fields.company.enabled ||
                          fields.instagram.enabled ||
                          fields.tiktok.enabled ||
                          fields.consent.enabled;

                      if (!hasAnyFieldEnabled) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("No information required"),
                            const SizedBox(height: 20),
                            ElevatedButton(onPressed: () => controller.submitLead(widget.type), child: const Text("Continue")),
                          ],
                        );
                      }

                      // ── Field builder ───────────────────────────────────
                      Widget buildField({
                        required String label,
                        required TextEditingController textController,
                        required LeadField field,
                        TextInputType keyboardType = TextInputType.text,
                        bool isEmail = false,
                        int personIndex = 0,
                      }) {
                        if (!field.enabled) return const SizedBox.shrink();

                        final fieldWidget = Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextfieldComponent(
                                controller: textController,
                                hintText: label,
                                isRequired: field.required,
                                keyboardType: keyboardType,
                                onChanged: isEmail
                                    ? (v) {
                                        _onEmailChanged(v);
                                        setState(() {
                                          _emailErrors[personIndex] = _validateEmail(v);
                                        });
                                      }
                                    : null,
                              ),
                              if (_isEmailFocused &&
                                  _focusedEmailController != null &&
                                  DeviceController.to.leadCaptureConfig.value?.emailAutoPopulate == true &&
                                  isEmail)
                                _buildApiEmailDropdown(),
                              if (isEmail && _emailErrors[personIndex] != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, top: 2, bottom: 6),
                                  child: Text(
                                    _emailErrors[personIndex]!,
                                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                  ),
                                )
                              else
                                const SizedBox(height: 8),
                            ],
                          ),
                        );

                        if (isEmail) {
                          return Focus(
                            onFocusChange: (focused) {
                              setState(() {
                                _isEmailFocused = focused;
                                if (focused) {
                                  _focusedEmailController = textController;
                                  if (textController.text.trim().isNotEmpty) {
                                    _onEmailChanged(textController.text);
                                  }
                                } else {
                                  _emailErrors[personIndex] = _validateEmail(textController.text);
                                  Future.delayed(const Duration(milliseconds: 200), () {
                                    if (mounted) setState(() => _emailSuggestions = []);
                                  });
                                }
                              });
                            },
                            child: fieldWidget,
                          );
                        }
                        return fieldWidget;
                      }

                      // ── Person card builder ──────────────────────────────
                      Widget buildPersonCard(int index) {
                        final p = controller.persons[index];

                        return Obx(
                          () => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Card Header ──────────────────────────
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Person ${index + 1}", style: textTheme.displayLarge!.copyWith(fontSize: 22)),
                                    if (controller.persons.length > 1)
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                        onPressed: () => controller.removePerson(index),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (index == controller.persons.length - 1)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Obx(() {
                                      final canAdd = controller.isPersonComplete(index, fields);
                                      return SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: canAdd ? () => controller.addPerson() : null,
                                          icon: const Icon(Icons.person_add_alt_1, size: 26, color: Colors.white),
                                          label: const Text(
                                            "Add Another Person",
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            backgroundColor: canAdd ? Colors.blue : Colors.grey.shade400,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            elevation: canAdd ? 4 : 0,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                const SizedBox(height: 12),

                                // ── Input Fields ─────────────────────────
                                buildField(label: "Name", textController: p['name']!, field: fields.name, personIndex: index),
                                buildField(
                                  label: "Email",
                                  textController: p['email']!,
                                  field: fields.email,
                                  keyboardType: TextInputType.emailAddress,
                                  isEmail: true,
                                  personIndex: index,
                                ),
                                buildField(
                                  label: "Phone",
                                  textController: p['phone']!,
                                  field: fields.phone,
                                  keyboardType: TextInputType.phone,
                                  personIndex: index,
                                ),
                                buildField(
                                  label: "Company",
                                  textController: p['company']!,
                                  field: fields.company,
                                  personIndex: index,
                                ),
                                buildField(
                                  label: "Instagram",
                                  textController: p['instagram']!,
                                  field: fields.instagram,
                                  personIndex: index,
                                ),
                                buildField(
                                  label: "TikTok",
                                  textController: p['tiktok']!,
                                  field: fields.tiktok,
                                  personIndex: index,
                                ),

                                // ── Consent Checkbox ─────────────────────
                                if (fields.consent.enabled)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 2,
                                        child: Checkbox(
                                          value: controller.consents[index].value,
                                          onChanged: (value) {
                                            controller.consents[index].value = value ?? false;
                                          },
                                          checkColor: Colors.white,
                                          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                                            if (states.contains(MaterialState.selected)) return Colors.blue;
                                            return Colors.grey;
                                          }),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        fields.consent.required
                                            ? "I agree to receive marketing communications (Required)"
                                            : "I agree to receive marketing communications",
                                        style: textTheme.displayLarge!.copyWith(
                                          fontSize: 25,
                                          shadows: [
                                            Shadow(
                                              offset: const Offset(0, 1),
                                              blurRadius: 6,
                                              color: Colors.black.withOpacity(0.6),
                                            ),
                                            Shadow(
                                              offset: const Offset(0, 2),
                                              blurRadius: 12,
                                              color: Colors.black.withOpacity(0.4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                // ── Add Another Person Button (last card only) ──
                              ],
                            ),
                          ),
                        );
                      }

                      return Obx(
                        () => Column(
                          children: [
                            ...controller.persons.asMap().entries.map((e) => buildPersonCard(e.key)),
                            const SizedBox(height: 20),
                            Obx(() {
                              final allDone = controller.persons.asMap().entries.every(
                                (e) => controller.isPersonComplete(e.key, fields),
                              );
                              final noEmailErrors = _emailErrors.values.every((e) => e == null);

                              return ButtonComponent(
                                text: 'SEND',
                                borderRadius: 0.0,
                                onPressed: (allDone && noEmailErrors)
                                    ? () async {
                                        FocusScope.of(context).unfocus();
                                        controller.submitLead(widget.type);
                                      }
                                    : null,
                              );
                            }),
                            SizedBox(height: 3.h),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            // ── Email suggestion dropdown ───────────────────────────────────
            if (_isEmailFocused && _focusedEmailController != null)
              Positioned(
                bottom: 320, // right above keyboard
                left: 0,
                right: 0,
                child: _buildStaticEmailStrip(),
              ),
          ],
        ),
      ),
    );
  }

  // ── Email dropdown widget ─────────────────────────────────────────────────

  /// Always-visible horizontal domain suffix strip
  Widget _buildStaticEmailStrip() {
    const staticSuggestions = [
      '@gmail.com',
      '@yahoo.com',
      '@outlook.com',
      '@live.com',
      '@hotmail.com',
      '@aol.com',
      '@me.com',
      '.com',
    ];

    return Container(
      height: 48,
      color: const Color(0xFFCDD0D6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: staticSuggestions.length,
        separatorBuilder: (_, __) => const VerticalDivider(color: Colors.grey, width: 1, indent: 8, endIndent: 8),
        itemBuilder: (context, index) {
          final suffix = staticSuggestions[index];
          return InkWell(
            onTap: () {
              final ctrl = _focusedEmailController!;
              final newText = ctrl.text + suffix;
              ctrl.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(offset: newText.length),
              );
              setState(() {
                _emailErrors[_getFocusedPersonIndex()] = _validateEmail(newText);
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: Text(
                  suffix,
                  style: const TextStyle(fontSize: 25, color: Color.fromARGB(255, 2, 122, 219), fontWeight: FontWeight.w400),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// API-driven vertical dropdown, only shows when there are results or loading
  Widget _buildApiEmailDropdown() {
    if (_isFetchingEmails) {
      return Container(
        height: 48,
        color: const Color(0xFFCDD0D6),
        child: const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    if (_emailSuggestions.isEmpty) return const SizedBox();

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: const Color(0xFFCDD0D6),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _emailSuggestions.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.grey),
        itemBuilder: (context, index) {
          final email = _emailSuggestions[index];
          return InkWell(
            onTap: () => _selectEmailSuggestion(email),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                email,
                style: const TextStyle(fontSize: 22, color: Color.fromARGB(255, 2, 122, 219), fontWeight: FontWeight.w400),
              ),
            ),
          );
        },
      ),
    );
  }

  int _getFocusedPersonIndex() {
    for (int i = 0; i < controller.persons.length; i++) {
      if (controller.persons[i]['email'] == _focusedEmailController) return i;
    }
    return 0;
  }
}

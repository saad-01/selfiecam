import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Height of the static email suffix strip shown above the keyboard.
const double _kStripHeight = 48.0;

/// Seconds of inactivity before auto-navigating back.
const int _kInactivitySeconds = 30;

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
  final Map<int, String?> _phoneErrors = {};

  // ── Misc ──────────────────────────────────────────────────────────────────
  Timer? _popupTimer;
  var counter = 30.obs;

  // ── FIX 2: Inactivity timer ───────────────────────────────────────────────
  Timer? _inactivityTimer;

  /// (Re-)starts the 30-second inactivity countdown.
  /// Call this on every user interaction.
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: _kInactivitySeconds), () {
      // Navigate back when inactivity timeout fires.
      if (mounted) {
        Get.back();
        Get.back();
        Get.back();
        camController.submitLead(widget.type);
      }
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns null when valid, error string when invalid.
  String? _validateEmail(String value) {
    if (value.trim().isEmpty) return null;
    final regex = RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(value.trim()) ? null : 'Enter a valid email address';
  }

  String? validatePhone(String value) {
    if (value.trim().isEmpty) return null;

    final regex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
    return regex.hasMatch(value.trim()) ? null : 'Enter a valid US phone number (123-456-7890)';
  }

  /// Debounced search: waits 500 ms of silence before hitting the API.
  void _onEmailChanged(String value) {
    _debounce?.cancel();

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
      final results = await controller.dropdownApi(search);
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
  void initState() {
    super.initState();
    // FIX 2: start inactivity timer as soon as the screen opens.
    _resetInactivityTimer();
  }

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
    // FIX 2: cancel inactivity timer on dispose.
    _inactivityTimer?.cancel();
    final vc = camController.videoController.value;
    if (vc != null && vc.value.isPlaying) {
      vc.pause();
      vc.seekTo(Duration.zero);
      // camController.videoController.value = null;
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // FIX 1 & 3: read current keyboard height once per build.
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // Extra bottom padding for the scroll area so fields scroll above keyboard.
    // Add strip height on top when email is focused.
    final scrollBottomPadding = keyboardHeight + (_isEmailFocused ? _kStripHeight : 0);

    // FIX 2: Wrap everything in a Listener so ANY pointer event resets the
    // inactivity timer — without disturbing existing tap / scroll behaviour.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetInactivityTimer(),
      onPointerMove: (_) => _resetInactivityTimer(),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            _emailSuggestions = [];
            _isEmailFocused = false;
          });
        },
        child: Scaffold(
          // Keep false so we control padding ourselves.
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // ── Background ─────────────────────────────────────────────
              // Positioned.fill keeps the image fixed behind everything else.
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

              // ── Scrollable content ──────────────────────────────────────
              // FIX 3: CustomScrollView sits on top of the background.
              // We inject dynamic bottom padding so the last field scrolls
              // above the keyboard + strip.  The background is NOT a child of
              // the scroll view, so it stays fixed.
              CustomScrollView(
                slivers: [
                  // ── Sticky Back Button ──────────────────────────────────
                  // SliverAppBar with pinned:true keeps the back button visible
                  // even when the list scrolls — this was already working fine.
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
                            camController.submitLead(widget.type);
                          },
                        ),
                      ),
                    ),
                  ),

                  // ── Main content ─────────────────────────────────────────
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      8.w,
                      0,
                      8.w,
                      // FIX 3: push content above keyboard + optional strip.
                      scrollBottomPadding,
                    ),
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

                        // ── Field builder ─────────────────────────────────
                        Widget buildField({
                          required String label,
                          required TextEditingController textController,
                          required LeadField field,
                          TextInputType keyboardType = TextInputType.text,
                          bool isEmail = false,
                          bool isPhone = false,
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
                                  inputFormatters: isPhone ? [PhoneFormatter()] : null,
                                  onChanged: isEmail
                                      ? (v) {
                                          _resetInactivityTimer(); // ADD THIS
                                          _onEmailChanged(v);
                                          setState(() {
                                            _emailErrors[personIndex] = _validateEmail(v);
                                          });
                                        }
                                      : isPhone
                                      ? (v) {
                                          _resetInactivityTimer(); // ADD THIS
                                          setState(() {
                                            _phoneErrors[personIndex] = validatePhone(v);
                                          });
                                        }
                                      : (v) {
                                          _resetInactivityTimer(); // ADD THIS
                                        },
                                ),
                                if (_isEmailFocused &&
                                    _focusedEmailController != null &&
                                    DeviceController.to.leadCaptureConfig.value?.emailAutoPopulate == true &&
                                    isEmail)
                                  _buildApiEmailDropdown(),
                                if ((isEmail && _emailErrors[personIndex] != null) ||
                                    (isPhone && _phoneErrors[personIndex] != null))
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, top: 2, bottom: 6),
                                    child: Text(
                                      _emailErrors[personIndex] ?? _phoneErrors[personIndex] ?? '',
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
                                      if (mounted) {
                                        setState(() => _emailSuggestions = []);
                                      }
                                    });
                                  }
                                });
                              },
                              child: fieldWidget,
                            );
                          }
                          return fieldWidget;
                        }

                        // ── Person card builder ───────────────────────────
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
                                  // ── Card Header ───────────────────────
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

                                  // ── Input Fields ──────────────────────
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
                                    isPhone: true,
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

                                  // ── Consent Checkbox ──────────────────
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
                                              if (states.contains(MaterialState.selected)) {
                                                return Colors.blue;
                                              }
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
                                final noPhoneErrors = _phoneErrors.values.every((e) => e == null);

                                return ButtonComponentIcon(
                                  iconPath: AppAssets.paperPlane,
                                  text: 'SEND IT',
                                  borderRadius: 0.0,
                                  onPressed: (allDone && noEmailErrors && noPhoneErrors)
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

              // FIX 1: Email suffix strip pinned exactly above the keyboard.
              // MediaQuery.viewInsets.bottom reflects the actual keyboard height
              // on every device because resizeToAvoidBottomInset is false.
              if (_isEmailFocused && _focusedEmailController != null)
                Positioned(bottom: keyboardHeight, left: 0, right: 0, child: _buildStaticEmailStrip()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Email strip widgets ───────────────────────────────────────────────────

  /// Horizontal domain-suffix strip, always shown while an email field is active.
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
      height: _kStripHeight,
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

  /// API-driven vertical dropdown, only shows when there are results or loading.
  Widget _buildApiEmailDropdown() {
    if (_isFetchingEmails) {
      return Container(
        height: _kStripHeight,
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

class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // remove all non-digits
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // limit to 10 digits
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    String formatted = '';

    if (digits.length >= 1) {
      formatted += digits.substring(0, digits.length >= 3 ? 3 : digits.length);
    }
    if (digits.length >= 4) {
      formatted += '-' + digits.substring(3, digits.length >= 6 ? 6 : digits.length);
    }
    if (digits.length >= 7) {
      formatted += '-' + digits.substring(6, digits.length);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

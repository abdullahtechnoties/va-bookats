// lib/app/modules/personalInfo/controllers/personal_info_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/mediaLibrary/controllers/media_library_controller.dart';
import 'package:va_bookats/app/modules/personalInfo/repositories/profile_repository.dart';
import 'package:va_bookats/models/lookup_option.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/media-selector-sheet.dart';

class PersonalInfoController extends GetxController {
  PersonalInfoController({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;
  final AuthService _auth = Get.find<AuthService>();

  // ─── Form controllers ──────────────────────────────────────────────────
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final emailSecondaryController = TextEditingController();
  final phonePrimaryController = TextEditingController();
  final phoneSecondaryController = TextEditingController();
  final dobController = TextEditingController();
  final qualificationController = TextEditingController();
  final zipController = TextEditingController();
  final addressController = TextEditingController();

  // Geo text controllers (for dropdown display)
  final countryCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final areaCtrl = TextEditingController();

  // ─── Geo selections ────────────────────────────────────────────────────
  final RxString selectedCountry = ''.obs;
  final RxnInt selectedCountryId = RxnInt();
  final RxString selectedState = ''.obs;
  final RxnInt selectedStateId = RxnInt();
  final RxString selectedCity = ''.obs;
  final RxnInt selectedCityId = RxnInt();
  final RxString selectedArea = ''.obs;
  final RxnInt selectedAreaId = RxnInt();

  // ─── Geo option lists ──────────────────────────────────────────────────
  final RxList<LookupOption> countryOptions = <LookupOption>[].obs;
  final RxList<LookupOption> stateOptions = <LookupOption>[].obs;
  final RxList<LookupOption> cityOptions = <LookupOption>[].obs;
  final RxList<LookupOption> areaOptions = <LookupOption>[].obs;

  List<String> get countryLabels => countryOptions.map((o) => o.label).toList();
  List<String> get countryValues => countryOptions.map((o) => o.value).toList();
  List<String> get stateLabels => stateOptions.map((o) => o.label).toList();
  List<String> get stateValues => stateOptions.map((o) => o.value).toList();
  List<String> get cityLabels => cityOptions.map((o) => o.label).toList();
  List<String> get cityValues => cityOptions.map((o) => o.value).toList();
  List<String> get areaLabels => areaOptions.map((o) => o.label).toList();
  List<String> get areaValues => areaOptions.map((o) => o.value).toList();

  // ─── Geo loading flags ─────────────────────────────────────────────────
  final RxBool isLoadingCountries = false.obs;
  final RxBool isLoadingStates = false.obs;
  final RxBool isLoadingCities = false.obs;
  final RxBool isLoadingAreas = false.obs;

  // ─── Media selections ──────────────────────────────────────────────────
  final Rxn<MediaItem> profileMedia = Rxn<MediaItem>();
  final Rxn<MediaItem> nicFrontMedia = Rxn<MediaItem>();
  final Rxn<MediaItem> nicBackMedia = Rxn<MediaItem>();

  // Existing image URLs (from current user data) for preview
  final RxnString existingProfileImageUrl = RxnString();
  final RxnString existingNicFrontUrl = RxnString();
  final RxnString existingNicBackUrl = RxnString();

  final RxString profileFileName = ''.obs;
  final RxString nicFrontFileName = ''.obs;
  final RxString nicBackFileName = ''.obs;

  // ─── States ────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _prefillFromCurrentUser();
    _loadGeoCascade();
  }

  void _prefillFromCurrentUser() {
    final user = _auth.currentUser.value;
    if (user == null) return;

    nameController.text = user.name ?? '';
    emailController.text = user.email ?? '';
    emailSecondaryController.text = user.emailSecondary ?? '';
    phonePrimaryController.text = user.phonePrimary ?? '';
    phoneSecondaryController.text = user.phoneSecondary ?? '';
    dobController.text = user.dateOfBirth ?? '';
    qualificationController.text = user.qualification ?? '';
    zipController.text = user.zipCode ?? '';
    addressController.text = user.address ?? '';

    // Geo IDs
    selectedCountryId.value = user.countryId;
    selectedStateId.value = user.stateId;
    selectedCityId.value = user.cityId;
    selectedAreaId.value = user.areaId;

    // Geo labels from nested objects
    if (user.country?.name != null) {
      selectedCountry.value = user.country!.name!;
      countryCtrl.text = user.country!.name!;
    }
    if (user.state?.name != null) {
      selectedState.value = user.state!.name!;
      stateCtrl.text = user.state!.name!;
    }
    if (user.city?.name != null) {
      selectedCity.value = user.city!.name!;
      cityCtrl.text = user.city!.name!;
    }
    if (user.area?.name != null) {
      selectedArea.value = user.area!.name!;
      areaCtrl.text = user.area!.name!;
    }

    // Existing images for preview
    existingProfileImageUrl.value =
        user.imageThumbUrl ?? user.imageUrl ?? user.image;
    existingNicFrontUrl.value =
        user.nicFrontThumbUrl ?? user.nicFrontUrl ?? user.nicFront;
    existingNicBackUrl.value =
        user.nicBackThumbUrl ?? user.nicBackUrl ?? user.nicBack;
  }

  Future<void> _loadGeoCascade() async {
    await fetchCountries();
    if (selectedCountryId.value != null) {
      await fetchStates(selectedCountryId.value!);
      _syncGeoLabel(
        options: stateOptions,
        id: selectedStateId.value,
        selected: selectedState,
        ctrl: stateCtrl,
      );
    }
    if (selectedStateId.value != null) {
      await fetchCities(selectedStateId.value!);
      _syncGeoLabel(
        options: cityOptions,
        id: selectedCityId.value,
        selected: selectedCity,
        ctrl: cityCtrl,
      );
    }
    if (selectedCityId.value != null) {
      await fetchAreas(selectedCityId.value!);
      _syncGeoLabel(
        options: areaOptions,
        id: selectedAreaId.value,
        selected: selectedArea,
        ctrl: areaCtrl,
      );
    }
  }

  void _syncGeoLabel({
    required List<LookupOption> options,
    required int? id,
    required RxString selected,
    required TextEditingController ctrl,
  }) {
    if (id == null) return;
    for (final o in options) {
      if (o.valueAsInt == id) {
        selected.value = o.label;
        ctrl.text = o.label;
        break;
      }
    }
  }

  // ─── Geo fetching ──────────────────────────────────────────────────────

  Future<void> fetchCountries() async {
    if (countryOptions.isNotEmpty) {
      _syncGeoLabel(
        options: countryOptions,
        id: selectedCountryId.value,
        selected: selectedCountry,
        ctrl: countryCtrl,
      );
      return;
    }
    isLoadingCountries.value = true;
    final response = await _repository.getCountries();
    isLoadingCountries.value = false;
    if (response.isCompleted && response.data != null) {
      countryOptions.assignAll(response.data!);
      _syncGeoLabel(
        options: countryOptions,
        id: selectedCountryId.value,
        selected: selectedCountry,
        ctrl: countryCtrl,
      );
    }
  }

  Future<void> fetchStates(int countryId) async {
    isLoadingStates.value = true;
    stateOptions.clear();
    final response = await _repository.getStates(countryId);
    isLoadingStates.value = false;
    if (response.isCompleted && response.data != null) {
      stateOptions.assignAll(response.data!);
    }
  }

  Future<void> fetchCities(int stateId) async {
    isLoadingCities.value = true;
    cityOptions.clear();
    final response = await _repository.getCities(stateId);
    isLoadingCities.value = false;
    if (response.isCompleted && response.data != null) {
      cityOptions.assignAll(response.data!);
    }
  }

  Future<void> fetchAreas(int cityId) async {
    isLoadingAreas.value = true;
    areaOptions.clear();
    final response = await _repository.getAreas(cityId);
    isLoadingAreas.value = false;
    if (response.isCompleted && response.data != null) {
      areaOptions.assignAll(response.data!);
    }
  }

  // ─── Geo cascade selection handlers ────────────────────────────────────

  void onCountrySelected(dynamic value) {
    selectedCountryId.value = value == null
        ? null
        : int.tryParse(value.toString());
    // Cascade reset
    selectedState.value = '';
    stateCtrl.clear();
    selectedStateId.value = null;
    stateOptions.clear();
    selectedCity.value = '';
    cityCtrl.clear();
    selectedCityId.value = null;
    cityOptions.clear();
    selectedArea.value = '';
    areaCtrl.clear();
    selectedAreaId.value = null;
    areaOptions.clear();
    final id = selectedCountryId.value;
    if (id != null) fetchStates(id);
  }

  void onStateSelected(dynamic value) {
    selectedStateId.value = value == null
        ? null
        : int.tryParse(value.toString());
    selectedCity.value = '';
    cityCtrl.clear();
    selectedCityId.value = null;
    cityOptions.clear();
    selectedArea.value = '';
    areaCtrl.clear();
    selectedAreaId.value = null;
    areaOptions.clear();
    final id = selectedStateId.value;
    if (id != null) fetchCities(id);
  }

  void onCitySelected(dynamic value) {
    selectedCityId.value = value == null
        ? null
        : int.tryParse(value.toString());
    selectedArea.value = '';
    areaCtrl.clear();
    selectedAreaId.value = null;
    areaOptions.clear();
    final id = selectedCityId.value;
    if (id != null) fetchAreas(id);
  }

  void onAreaSelected(dynamic value) {
    selectedAreaId.value = value == null
        ? null
        : int.tryParse(value.toString());
  }

  // ─── Image Pickers (via MediaSelectorSheet) ────────────────────────────

  void pickProfileImage(BuildContext context) {
    MediaSelectorSheet.show(
      context,
      allowMultiple: false,
      initialSelectedIds: profileMedia.value == null
          ? const []
          : [profileMedia.value!.mediaId],
      onConfirmed: (items) {
        if (items.isEmpty) return;
        profileMedia.value = items.first;
        profileFileName.value = items.first.name;
        existingProfileImageUrl.value = null;
      },
    );
  }

  void pickNicFront(BuildContext context) {
    MediaSelectorSheet.show(
      context,
      allowMultiple: false,
      initialSelectedIds: nicFrontMedia.value == null
          ? const []
          : [nicFrontMedia.value!.mediaId],
      onConfirmed: (items) {
        if (items.isEmpty) return;
        nicFrontMedia.value = items.first;
        nicFrontFileName.value = items.first.name;
        existingNicFrontUrl.value = null;
      },
    );
  }

  void pickNicBack(BuildContext context) {
    MediaSelectorSheet.show(
      context,
      allowMultiple: false,
      initialSelectedIds: nicBackMedia.value == null
          ? const []
          : [nicBackMedia.value!.mediaId],
      onConfirmed: (items) {
        if (items.isEmpty) return;
        nicBackMedia.value = items.first;
        nicBackFileName.value = items.first.name;
        existingNicBackUrl.value = null;
      },
    );
  }

  // ─── Date Picker ───────────────────────────────────────────────────────

  Future<void> pickDate(BuildContext context) async {
    DateTime initial = DateTime.now().subtract(const Duration(days: 365 * 30));
    final current = dobController.text.trim();
    if (current.isNotEmpty) {
      final parsed = _parseDob(current);
      if (parsed != null) initial = parsed;
    }
    if (initial.isAfter(DateTime.now())) initial = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      dobController.text =
          '${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}-${picked.year}';
    }
  }

  /// Parses both `MM-DD-YYYY` (app format) and ISO `YYYY-MM-DD`.
  DateTime? _parseDob(String text) {
    try {
      final dash = text.split('-');
      if (dash.length == 3) {
        if (dash[0].length == 4) {
          return DateTime(
            int.parse(dash[0]),
            int.parse(dash[1]),
            int.parse(dash[2]),
          );
        }
        return DateTime(
          int.parse(dash[2]),
          int.parse(dash[0]),
          int.parse(dash[1]),
        );
      }
      return DateTime.parse(text);
    } catch (_) {
      return null;
    }
  }

  // ─── Save ──────────────────────────────────────────────────────────────

  Future<void> save() async {
    if (nameController.text.trim().isEmpty) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'Please enter your name',
      );
      return;
    }
    if (emailController.text.trim().isEmpty) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'Please enter your email',
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _repository.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        emailSecondary: emailSecondaryController.text.trim().isEmpty
            ? null
            : emailSecondaryController.text.trim(),
        phonePrimary: phonePrimaryController.text.trim().isEmpty
            ? null
            : phonePrimaryController.text.trim(),
        phoneSecondary: phoneSecondaryController.text.trim().isEmpty
            ? null
            : phoneSecondaryController.text.trim(),
        dateOfBirth: dobController.text.trim().isEmpty
            ? null
            : dobController.text.trim(),
        qualification: qualificationController.text.trim().isEmpty
            ? null
            : qualificationController.text.trim(),
        countryId: selectedCountryId.value,
        stateId: selectedStateId.value,
        cityId: selectedCityId.value,
        areaId: selectedAreaId.value,
        zipCode: zipController.text.trim().isEmpty
            ? null
            : zipController.text.trim(),
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        mediaId: profileMedia.value?.mediaId,
        nicFrontMediaId: nicFrontMedia.value?.mediaId,
        nicBackMediaId: nicBackMedia.value?.mediaId,
      );

      if (response.isCompleted && response.data != null) {
        // Update AuthService with fresh user data
        await _auth.setCurrentUser(response.data!);
        _showSuccessDialog(response.message ?? 'Profile updated successfully.');
      } else {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: response.message ?? 'errors.requestFailed'.trns(),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccessDialog(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF8FC642).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF8FC642),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Success',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // close dialog
                    Get.back(); // pop screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    emailSecondaryController.dispose();
    phonePrimaryController.dispose();
    phoneSecondaryController.dispose();
    dobController.dispose();
    qualificationController.dispose();
    zipController.dispose();
    addressController.dispose();
    countryCtrl.dispose();
    stateCtrl.dispose();
    cityCtrl.dispose();
    areaCtrl.dispose();
    super.onClose();
  }
}

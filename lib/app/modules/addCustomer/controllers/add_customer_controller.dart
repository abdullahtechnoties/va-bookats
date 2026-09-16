// lib/app/modules/addCustomer/controllers/add_customer_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/customers/repositories/customer_repository.dart';
import 'package:va_bookats/app/modules/mediaLibrary/controllers/media_library_controller.dart';
import 'package:va_bookats/models/customer_model.dart';
import 'package:va_bookats/models/lookup_option.dart';
import 'package:va_bookats/utilities/navigation_helper.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/media-selector-sheet.dart';

/// A single attachment row: title + media-library reference.
class AttachmentInput {
  final TextEditingController titleCtrl;
  final Rxn<MediaItem> media = Rxn<MediaItem>();
  String? existingUrl;
  int? existingMediaId;

  AttachmentInput({String title = '', MediaItem? initial})
      : titleCtrl = TextEditingController(text: title) {
    media.value = initial;
    existingMediaId = initial?.mediaId;
    existingUrl = initial?.thumbnailUrl ?? initial?.networkUrl;
  }

  void dispose() => titleCtrl.dispose();

  bool get isComplete {
    final title = titleCtrl.text.trim();
    final mediaId = media.value?.mediaId ?? existingMediaId;
    return title.isNotEmpty && mediaId != null;
  }

  AttachmentDraft? toDraft() {
    final title = titleCtrl.text.trim();
    final mediaId = media.value?.mediaId ?? existingMediaId;
    if (title.isEmpty || mediaId == null) return null;
    return AttachmentDraft(title: title, mediaId: mediaId);
  }
}

class AddCustomerController extends GetxController {
  AddCustomerController({required CustomerRepository repository})
      : _repository = repository;

  final CustomerRepository _repository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // ─── Form controllers ──────────────────────────────────────────────────
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController genderCtrl = TextEditingController();
  final TextEditingController countryCtrl = TextEditingController();
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController areaCtrl = TextEditingController();
  final TextEditingController zipCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController latCtrl = TextEditingController();
  final TextEditingController lngCtrl = TextEditingController();

  final RxString selectedGender = ''.obs;
  final RxString selectedCountry = ''.obs;
  final RxnInt selectedCountryId = RxnInt();
  final RxString selectedState = ''.obs;
  final RxnInt selectedStateId = RxnInt();
  final RxString selectedCity = ''.obs;
  final RxnInt selectedCityId = RxnInt();
  final RxString selectedArea = ''.obs;
  final RxnInt selectedAreaId = RxnInt();

  List<String> get genderOptions => ['male', 'female', 'other'];

  // ─── Geo options ───────────────────────────────────────────────────────
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

  final RxBool isLoadingCountries = false.obs;
  final RxBool isLoadingStates = false.obs;
  final RxBool isLoadingCities = false.obs;
  final RxBool isLoadingAreas = false.obs;

  // ─── Profile image (media library) ─────────────────────────────────────
  final Rxn<MediaItem> selectedMedia = Rxn<MediaItem>();
  final RxString imageFileName = ''.obs;
  String? existingImageUrl;

  int? get selectedMediaId => selectedMedia.value?.mediaId;

  // ─── Attachments ───────────────────────────────────────────────────────
  final RxList<AttachmentInput> attachmentInputs = <AttachmentInput>[].obs;

  // ─── States ────────────────────────────────────────────────────────────
  final RxBool isSaving = false.obs;
  final RxBool isLoadingDetail = false.obs;

  CustomerModel? _editingCustomer;
  bool get isEditMode => _editingCustomer != null;

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    fetchCountries();
    if (isEditMode) {
      fetchDetail();
    }
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is CustomerModel) {
      _editingCustomer = args;
      _prefillBasic(args);
    }
  }

  void _prefillBasic(CustomerModel c) {
    nameCtrl.text = c.name;
    emailCtrl.text = c.email;
    phoneCtrl.text = c.phonePrimary;
    if ((c.gender ?? '').isNotEmpty) {
      selectedGender.value = c.gender!;
      genderCtrl.text = c.gender!;
    }
    zipCtrl.text = c.zipCode ?? '';
    addressCtrl.text = c.address ?? '';
    latCtrl.text = c.latitude ?? '';
    lngCtrl.text = c.longitude ?? '';
    existingImageUrl = (c.imageThumbUrl?.isNotEmpty == true)
        ? c.imageThumbUrl
        : (c.imageUrl?.isNotEmpty == true ? c.imageUrl : null);
    selectedCountryId.value = c.countryId;
    selectedStateId.value = c.stateId;
    selectedCityId.value = c.cityId;
    selectedAreaId.value = c.areaId;
    if ((c.country?.name ?? '').isNotEmpty) {
      selectedCountry.value = c.country!.name!;
      countryCtrl.text = c.country!.name!;
    }
    if ((c.state?.name ?? '').isNotEmpty) {
      selectedState.value = c.state!.name!;
      stateCtrl.text = c.state!.name!;
    }
    if ((c.city?.name ?? '').isNotEmpty) {
      selectedCity.value = c.city!.name!;
      cityCtrl.text = c.city!.name!;
    }
    if ((c.area?.name ?? '').isNotEmpty) {
      selectedArea.value = c.area!.name!;
      areaCtrl.text = c.area!.name!;
    }
  }

  Future<void> fetchDetail() async {
    final id = _editingCustomer?.id;
    if (id == null || id == 0) return;
    isLoadingDetail.value = true;
    final response = await _repository.getCustomerDetail(id);
    isLoadingDetail.value = false;
    if (!response.isCompleted || response.data == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
      return;
    }
    final detail = response.data!;
    _editingCustomer = detail.customer;
    _prefillBasic(detail.customer);
    // Prefill geo cascades so dropdowns resolve ids → labels.
    await fetchCountries();
    if (detail.customer.countryId != null) {
      await fetchStates(detail.customer.countryId!);
      _syncGeoLabel(
        options: stateOptions,
        id: detail.customer.stateId,
        selected: selectedState,
        ctrl: stateCtrl,
      );
    }
    if (detail.customer.stateId != null) {
      await fetchCities(detail.customer.stateId!);
      _syncGeoLabel(
        options: cityOptions,
        id: detail.customer.cityId,
        selected: selectedCity,
        ctrl: cityCtrl,
      );
    }
    if (detail.customer.cityId != null) {
      await fetchAreas(detail.customer.cityId!);
      _syncGeoLabel(
        options: areaOptions,
        id: detail.customer.areaId,
        selected: selectedArea,
        ctrl: areaCtrl,
      );
    }
    for (final input in attachmentInputs) {
      input.dispose();
    }
    attachmentInputs.clear();
    for (final a in detail.attachments) {
      final item = MediaItem(
        id: a.id,
        networkUrl: a.url,
        thumbnailUrl: a.thumbnailUrl,
        name: a.fileName.isEmpty ? a.title : a.fileName,
        uploadedDate: '',
        size: '',
        dimensions: '',
      );
      final row = AttachmentInput(title: a.title, initial: item);
      attachmentInputs.add(row);
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

  void onCountrySelected(dynamic value) {
    selectedCountryId.value =
        value == null ? null : int.tryParse(value.toString());
    // Cascade reset.
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
    selectedStateId.value =
        value == null ? null : int.tryParse(value.toString());
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
    selectedCityId.value =
        value == null ? null : int.tryParse(value.toString());
    selectedArea.value = '';
    areaCtrl.clear();
    selectedAreaId.value = null;
    areaOptions.clear();
    final id = selectedCityId.value;
    if (id != null) fetchAreas(id);
  }

  void onAreaSelected(dynamic value) {
    selectedAreaId.value =
        value == null ? null : int.tryParse(value.toString());
  }

  // ─── Profile image ─────────────────────────────────────────────────────

  void pickProfileImage(BuildContext context) {
    MediaSelectorSheet.show(
      context,
      allowMultiple: false,
      initialSelectedIds:
          selectedMedia.value == null ? const [] : [selectedMedia.value!.mediaId],
      onConfirmed: (items) {
        if (items.isEmpty) return;
        selectedMedia.value = items.first;
        imageFileName.value = items.first.name;
        existingImageUrl = null;
      },
    );
  }

  void clearProfileImage() {
    selectedMedia.value = null;
    imageFileName.value = '';
  }

  // ─── Attachments ───────────────────────────────────────────────────────

  void addAttachment() {
    attachmentInputs.add(AttachmentInput());
  }

  void removeAttachment(int index) {
    if (index < 0 || index >= attachmentInputs.length) return;
    attachmentInputs[index].dispose();
    attachmentInputs.removeAt(index);
  }

  void pickAttachmentMedia(BuildContext context, int index) {
    if (index < 0 || index >= attachmentInputs.length) return;
    final current = attachmentInputs[index].media.value ??
        (attachmentInputs[index].existingMediaId == null
            ? null
            : null);
    MediaSelectorSheet.show(
      context,
      allowMultiple: false,
      initialSelectedIds: current == null ? const [] : [current.mediaId],
      onConfirmed: (items) {
        if (items.isEmpty) return;
        attachmentInputs[index].media.value = items.first;
        attachmentInputs[index].existingMediaId = items.first.mediaId;
        attachmentInputs[index].existingUrl =
            items.first.thumbnailUrl ?? items.first.networkUrl;
        attachmentInputs.refresh();
      },
    );
  }

  void clearAttachmentMedia(int index) {
    if (index < 0 || index >= attachmentInputs.length) return;
    attachmentInputs[index].media.value = null;
    attachmentInputs[index].existingMediaId = null;
    attachmentInputs[index].existingUrl = null;
    attachmentInputs.refresh();
  }

  List<AttachmentDraft> _buildAttachmentDrafts() {
    final drafts = <AttachmentDraft>[];
    for (final input in attachmentInputs) {
      final draft = input.toDraft();
      if (draft != null) drafts.add(draft);
    }
    return drafts;
  }

  // ─── Validators ────────────────────────────────────────────────────────

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'addCustomer.validation.nameRequired'.trns() ==
              'addCustomer.validation.nameRequired'
          ? 'Please enter customer name'
          : 'addCustomer.validation.nameRequired'.trns();
    }
    return null;
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'addCustomer.validation.emailRequired'.trns() ==
              'addCustomer.validation.emailRequired'
          ? 'Please enter email address'
          : 'addCustomer.validation.emailRequired'.trns();
    }
    if (!GetUtils.isEmail(email)) {
      return 'addCustomer.validation.emailInvalid'.trns() ==
              'addCustomer.validation.emailInvalid'
          ? 'Please enter a valid email address'
          : 'addCustomer.validation.emailInvalid'.trns();
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'addCustomer.validation.phoneRequired'.trns() ==
              'addCustomer.validation.phoneRequired'
          ? 'Please enter phone number'
          : 'addCustomer.validation.phoneRequired'.trns();
    }
    return null;
  }

  // ─── Save ──────────────────────────────────────────────────────────────

  Future<void> save(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    // Attachments are optional, but a half-filled row is a user error.
    for (final input in attachmentInputs) {
      final title = input.titleCtrl.text.trim();
      final hasMedia = (input.media.value?.mediaId ??
              input.existingMediaId) !=
          null;
      if ((title.isEmpty && hasMedia) || (title.isNotEmpty && !hasMedia)) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: 'addCustomer.validation.attachmentIncomplete'.trns() ==
                  'addCustomer.validation.attachmentIncomplete'
              ? 'Each attachment needs both a title and an image.'
              : 'addCustomer.validation.attachmentIncomplete'.trns(),
        );
        return;
      }
    }

    isSaving.value = true;
    try {
      final drafts = _buildAttachmentDrafts();
      final id = _editingCustomer?.id;
      final response = id == null
          ? await _repository.createCustomer(
              name: nameCtrl.text.trim(),
              email: emailCtrl.text.trim(),
              phonePrimary: phoneCtrl.text.trim(),
              gender: selectedGender.value.isEmpty
                  ? null
                  : selectedGender.value,
              countryId: selectedCountryId.value,
              stateId: selectedStateId.value,
              cityId: selectedCityId.value,
              areaId: selectedAreaId.value,
              zipCode: zipCtrl.text.trim().isEmpty
                  ? null
                  : zipCtrl.text.trim(),
              address: addressCtrl.text.trim().isEmpty
                  ? null
                  : addressCtrl.text.trim(),
              latitude: latCtrl.text.trim().isEmpty
                  ? null
                  : latCtrl.text.trim(),
              longitude: lngCtrl.text.trim().isEmpty
                  ? null
                  : lngCtrl.text.trim(),
              mediaId: selectedMediaId,
              attachments: drafts,
            )
          : await _repository.updateCustomer(
              id: id,
              name: nameCtrl.text.trim(),
              email: emailCtrl.text.trim(),
              phonePrimary: phoneCtrl.text.trim(),
              gender: selectedGender.value.isEmpty
                  ? null
                  : selectedGender.value,
              countryId: selectedCountryId.value,
              stateId: selectedStateId.value,
              cityId: selectedCityId.value,
              areaId: selectedAreaId.value,
              zipCode: zipCtrl.text.trim().isEmpty
                  ? null
                  : zipCtrl.text.trim(),
              address: addressCtrl.text.trim().isEmpty
                  ? null
                  : addressCtrl.text.trim(),
              latitude: latCtrl.text.trim().isEmpty
                  ? null
                  : latCtrl.text.trim(),
              longitude: lngCtrl.text.trim().isEmpty
                  ? null
                  : lngCtrl.text.trim(),
              mediaId: selectedMediaId,
              attachments: drafts,
            );

      if (response.isCompleted) {
        SnackbarService.showSuccess(
          title: 'common.success'.trns(),
          message: response.message ??
              (id == null
                  ? ('addCustomer.createSuccess'.trns() ==
                          'addCustomer.createSuccess'
                      ? 'Customer created successfully.'
                      : 'addCustomer.createSuccess'.trns())
                  : ('addCustomer.updateSuccess'.trns() ==
                          'addCustomer.updateSuccess'
                      ? 'Customer updated successfully.'
                      : 'addCustomer.updateSuccess'.trns())),
        );
        // Let the snackbar paint before popping — avoids the race where an
        // instant pop swallows the success toast.
        if (!context.mounted) return;
        await NavigationHelper.safePop(context);
      } else {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: response.message ?? 'errors.requestFailed'.trns(),
        );
      }
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    genderCtrl.dispose();
    countryCtrl.dispose();
    stateCtrl.dispose();
    cityCtrl.dispose();
    areaCtrl.dispose();
    zipCtrl.dispose();
    addressCtrl.dispose();
    latCtrl.dispose();
    lngCtrl.dispose();
    for (final input in attachmentInputs) {
      input.dispose();
    }
    super.onClose();
  }
}

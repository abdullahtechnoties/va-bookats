// lib/app/modules/addCustomer/views/add_customer_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addCustomer/controllers/add_customer_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';
import 'package:va_bookats/widgets/app_touchable.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddCustomerView extends GetView<AddCustomerController> {
  const AddCustomerView({super.key});

  void _showDropdown(
    BuildContext context, {
    required String title,
    required List<String> items,
    required RxString selectedItem,
    required TextEditingController textCtrl,
    List<String>? values,
    Function(dynamic)? onValueSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheet(
        title: title,
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.5,
        dropdownItems: items,
        selectedValue: values,
        onValueSelected: onValueSelected,
        selectedItem: selectedItem,
        textController: textCtrl,
        currentlySelectedValue: selectedItem.value,
        showSearch: false,
      ),
    );
  }

  Widget _loaderSuffix() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  String _t(String key, String fallback) {
    final v = key.trns();
    return v == key ? fallback : v;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _AddCustomerHeader(
            title: controller.isEditMode ? _t('addCustomer.editTitle', 'Edit Customer') : _t('addCustomer.title', 'Add New Customer'),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingDetail.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.secondary,
                  ),
                );
              }
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: const Color(0xFFEEEEEE), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.isEditMode
                                ? _t('addCustomer.editFormTitle',
                                    'Edit Customer Information')
                                : _t('addCustomer.formTitle',
                                    'Customer Information'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Name
                          _FieldLabel(_t('addCustomer.name', 'Full Name')),
                          const SizedBox(height: 8),
                          CommonTextInputField(
                            hintTextColor: AppColors.grey,
                            hintText:
                                _t('addCustomer.enterName', 'Enter Full Name'),
                            controller: controller.nameCtrl,
                            height: 52,
                            hintTextSize: 13,
                            validator: controller.validateName,
                          ),
                          const SizedBox(height: 18),

                          // Email
                          _FieldLabel(_t('addCustomer.email', 'Email Address')),
                          const SizedBox(height: 8),
                          CommonTextInputField(
                            hintTextColor: AppColors.grey,
                            hintText: _t(
                                'addCustomer.enterEmail', 'Enter Email Address'),
                            controller: controller.emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            height: 52,
                            hintTextSize: 13,
                            validator: controller.validateEmail,
                          ),
                          const SizedBox(height: 18),

                          // Phone
                          _FieldLabel(_t('addCustomer.phone', 'Phone Number')),
                          const SizedBox(height: 8),
                          CommonTextInputField(
                            hintTextColor: AppColors.grey,
                            hintText: _t('addCustomer.enterPhone',
                                'Enter Phone Number'),
                            controller: controller.phoneCtrl,
                            keyboardType: TextInputType.phone,
                            height: 52,
                            hintTextSize: 13,
                            validator: controller.validatePhone,
                          ),
                          const SizedBox(height: 18),

                          // Gender
                          _FieldLabel(_t('addCustomer.gender', 'Gender')),
                          const SizedBox(height: 8),
                          Obx(
                            () => AppTouchable(
                              child: CommonTextInputField(
                                hintTextColor: AppColors.grey,
                                hintText: _t('addCustomer.selectGender',
                                    'Select Gender'),
                                controller: controller.genderCtrl,
                                readOnly: true,
                                height: 52,
                                hintTextSize: 13,
                                onTap: () => _showDropdown(
                                  context,
                                  title: _t(
                                      'addCustomer.gender', 'Gender'),
                                  items: controller.genderOptions,
                                  selectedItem: controller.selectedGender,
                                  textCtrl: controller.genderCtrl,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Profile image
                          _FieldLabel(
                              _t('addCustomer.profileImage', 'Profile Image')),
                          const SizedBox(height: 8),
                          _ProfileImageField(controller: controller),
                          const SizedBox(height: 18),

                          // Country
                          _FieldLabel(_t('addCustomer.country', 'Country')),
                          const SizedBox(height: 8),
                          Obx(
                            () => AppTouchable(
                              child: CommonTextInputField(
                                hintText: _t('addCustomer.selectCountry',
                                    'Select Country'),
                                controller: controller.countryCtrl,
                                readOnly: true,
                                height: 52,
                                hintTextSize: 13,
                                showSuffixIcon: true,
                                suffixIcon:
                                    controller.isLoadingCountries.value
                                        ? _loaderSuffix()
                                        : const SizedBox(),
                                onTap: controller.isLoadingCountries.value
                                    ? null
                                    : () => _showDropdown(
                                          context,
                                          title: _t('addCustomer.country',
                                              'Country'),
                                          items: controller.countryLabels,
                                          selectedItem:
                                              controller.selectedCountry,
                                          textCtrl: controller.countryCtrl,
                                          values: controller.countryValues,
                                          onValueSelected:
                                              controller.onCountrySelected,
                                        ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // State
                          _FieldLabel(_t('addCustomer.state', 'State')),
                          const SizedBox(height: 8),
                          Obx(
                            () => AppTouchable(
                              child: CommonTextInputField(
                                hintText: _t('addCustomer.selectState',
                                    'Select State'),
                                controller: controller.stateCtrl,
                                readOnly: true,
                                height: 52,
                                hintTextSize: 13,
                                showSuffixIcon: true,
                                suffixIcon: controller.isLoadingStates.value
                                    ? _loaderSuffix()
                                    : const SizedBox(),
                                onTap: controller.selectedCountryId.value ==
                                        null
                                    ? null
                                    : () => _showDropdown(
                                          context,
                                          title: _t('addCustomer.state',
                                              'State'),
                                          items: controller.stateLabels,
                                          selectedItem:
                                              controller.selectedState,
                                          textCtrl: controller.stateCtrl,
                                          values: controller.stateValues,
                                          onValueSelected:
                                              controller.onStateSelected,
                                        ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // City
                          _FieldLabel(_t('addCustomer.city', 'City')),
                          const SizedBox(height: 8),
                          Obx(
                            () => AppTouchable(
                              child: CommonTextInputField(
                                hintText: _t('addCustomer.selectCity',
                                    'Select City'),
                                controller: controller.cityCtrl,
                                readOnly: true,
                                height: 52,
                                hintTextSize: 13,
                                showSuffixIcon: true,
                                suffixIcon: controller.isLoadingCities.value
                                    ? _loaderSuffix()
                                    : const SizedBox(),
                                onTap:
                                    controller.selectedStateId.value == null
                                        ? null
                                        : () => _showDropdown(
                                              context,
                                              title: _t('addCustomer.city',
                                                  'City'),
                                              items: controller.cityLabels,
                                              selectedItem:
                                                  controller.selectedCity,
                                              textCtrl: controller.cityCtrl,
                                              values: controller.cityValues,
                                              onValueSelected:
                                                  controller.onCitySelected,
                                            ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Area
                          _FieldLabel(_t('addCustomer.area', 'Area')),
                          const SizedBox(height: 8),
                          Obx(
                            () => AppTouchable(
                              child: CommonTextInputField(
                                hintText: _t('addCustomer.selectArea',
                                    'Select Area'),
                                controller: controller.areaCtrl,
                                readOnly: true,
                                height: 52,
                                hintTextSize: 13,
                                showSuffixIcon: true,
                                suffixIcon: controller.isLoadingAreas.value
                                    ? _loaderSuffix()
                                    : const SizedBox(),
                                onTap: controller.selectedCityId.value == null
                                    ? null
                                    : () => _showDropdown(
                                          context,
                                          title: _t('addCustomer.area',
                                              'Area'),
                                          items: controller.areaLabels,
                                          selectedItem:
                                              controller.selectedArea,
                                          textCtrl: controller.areaCtrl,
                                          values: controller.areaValues,
                                          onValueSelected:
                                              controller.onAreaSelected,
                                        ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Zip
                          _FieldLabel(_t('addCustomer.zip', 'Zip Code')),
                          const SizedBox(height: 8),
                          CommonTextInputField(
                            hintTextColor: AppColors.grey,
                            hintText: _t(
                                'addCustomer.enterZip', 'Enter Zip Code'),
                            controller: controller.zipCtrl,
                            keyboardType: TextInputType.number,
                            height: 52,
                            hintTextSize: 13,
                          ),
                          const SizedBox(height: 18),

                          // Address
                          _FieldLabel(_t('addCustomer.address', 'Address')),
                          const SizedBox(height: 8),
                          CommonTextInputField(
                            hintTextColor: AppColors.grey,
                            hintText: _t('addCustomer.enterAddress',
                                'Enter Address'),
                            controller: controller.addressCtrl,
                            maxLines: 3,
                            height: 96,
                            hintTextSize: 13,
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                          ),
                          const SizedBox(height: 18),

                          // Lat / Lng
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(
                                        _t('addCustomer.latitude', 'Latitude')),
                                    const SizedBox(height: 8),
                                    CommonTextInputField(
                                      hintText: '21.406810',
                                      controller: controller.latCtrl,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true, signed: true),
                                      height: 52,
                                      hintTextSize: 13,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(_t('addCustomer.longitude',
                                        'Longitude')),
                                    const SizedBox(height: 8),
                                    CommonTextInputField(
                                      hintText: '126.845600',
                                      controller: controller.lngCtrl,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true, signed: true),
                                      height: 52,
                                      hintTextSize: 13,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // Attachments
                          _AttachmentsSection(controller: controller),
                          const SizedBox(height: 26),

                          // Save Button
                          Obx(
                            () => MainBtn(
                              text: controller.isEditMode
                                  ? _t('addCustomer.update', 'Update')
                                  : _t('addCustomer.save', 'Save'),
                              onPressed: controller.isSaving.value
                                  ? null
                                  : () => controller.save(context),
                              isLoading: controller.isSaving.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _AddCustomerHeader extends StatelessWidget {
  final String title;

  const _AddCustomerHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Profile Image Field ─────────────────────────────────────────────────────

class _ProfileImageField extends StatelessWidget {
  final AddCustomerController controller;

  const _ProfileImageField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final media = controller.selectedMedia.value;
      final imageUrl = media?.thumbnailUrl ??
          media?.networkUrl ??
          controller.existingImageUrl;
      final fileName = controller.imageFileName.value;
      return Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4E4E4), width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null
                ? AppCachedImage(imageUrl: imageUrl, fit: BoxFit.cover)
                : const Icon(
                    Icons.image_outlined,
                    color: Color(0xFFBBBBBB),
                    size: 24,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.black.withValues(alpha: 0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  fileName.isEmpty
                      ? (imageUrl ?? 'No File Chosen')
                      : fileName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777777),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AppTouchable(
            child: GestureDetector(
              onTap: () => controller.pickProfileImage(context),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'Choose File',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ─── Attachments Section ─────────────────────────────────────────────────────

class _AttachmentsSection extends StatelessWidget {
  final AddCustomerController controller;

  const _AttachmentsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final inputs = controller.attachmentInputs;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _FieldLabel('Attachments'),
              Text(
                '${inputs.length} item(s)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (inputs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: const Text(
                'No attachments added.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
            )
          else
            ...List.generate(inputs.length, (index) {
              final input = inputs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Attachment ${index + 1}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => controller.removeAttachment(index),
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppColors.secondary,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CommonTextInputField(
                      hintText: 'Title (e.g. NIC Front)',
                      controller: input.titleCtrl,
                      height: 48,
                      hintTextSize: 12,
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
                      final media = input.media.value;
                      final url = media?.thumbnailUrl ??
                          media?.networkUrl ??
                          input.existingUrl;
                      final name = media?.name ??
                          (input.titleCtrl.text.isEmpty
                              ? null
                              : input.titleCtrl.text);
                      return Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFE4E4E4)),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: url != null
                                ? AppCachedImage(
                                    imageUrl: url, fit: BoxFit.cover)
                                : const Icon(
                                    Icons.image_outlined,
                                    color: Color(0xFFBBBBBB),
                                    size: 22,
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              name ?? 'No File Chosen',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF777777),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => controller.pickAttachmentMedia(
                                context, index),
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  url == null ? 'Choose' : 'Change',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              );
            }),
          AppTouchable(
            child: GestureDetector(
              onTap: controller.addAttachment,
              child: Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: AppColors.secondary, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Add Attachment',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ─── Field Label ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),
    );
  }
}

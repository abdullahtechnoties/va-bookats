// lib/app/modules/personalInfo/views/personal_info_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/personalInfo/controllers/personal_info_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';
import 'package:va_bookats/widgets/app_touchable.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class PersonalInfoView extends GetView<PersonalInfoController> {
  const PersonalInfoView({super.key});

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
          _PersonalInfoHeader(
            title: _t('profile.personalInfo', 'Personal Information'),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('profile.editFormTitle', 'Edit Profile'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Name
                      _FieldLabel(_t('profile.name', 'Full Name')),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintTextColor: AppColors.grey,
                        hintText: _t('profile.enterName', 'Enter Full Name'),
                        controller: controller.nameController,
                        height: 52,
                        hintTextSize: 13,
                      ),
                      const SizedBox(height: 18),

                      // Email Primary
                      _FieldLabel(_t('profile.email', 'Email Address')),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintTextColor: AppColors.grey,
                        hintText: _t('profile.enterEmail', 'Enter Email Address'),
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        height: 52,
                        hintTextSize: 13,
                      ),
                      const SizedBox(height: 18),

                      // Email Secondary
                      _FieldLabel(_t('profile.emailSecondary', 'Email Secondary')),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintTextColor: AppColors.grey,
                        hintText: _t('profile.enterEmailSecondary', 'Enter Secondary Email'),
                        controller: controller.emailSecondaryController,
                        keyboardType: TextInputType.emailAddress,
                        height: 52,
                        hintTextSize: 13,
                      ),
                      const SizedBox(height: 18),

                      // Phone Primary
                      _FieldLabel(_t('profile.phone', 'Phone Number')),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintTextColor: AppColors.grey,
                        hintText: _t('profile.enterPhone', 'Enter Phone Number'),
                        controller: controller.phonePrimaryController,
                        keyboardType: TextInputType.phone,
                        height: 52,
                        hintTextSize: 13,
                      ),
                      const SizedBox(height: 18),

                      // Phone Secondary
                      _FieldLabel(_t('profile.phoneSecondary', 'Phone Secondary')),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintTextColor: AppColors.grey,
                        hintText: _t('profile.enterPhoneSecondary', 'Enter Secondary Phone'),
                        controller: controller.phoneSecondaryController,
                        keyboardType: TextInputType.phone,
                        height: 52,
                        hintTextSize: 13,
                      ),
                      const SizedBox(height: 18),

                      // Date of Birth
                      _FieldLabel(_t('profile.dob', 'Date of Birth')),
                      const SizedBox(height: 8),
                      AppTouchable(
                        child: CommonTextInputField(
                          hintTextColor: AppColors.grey,
                          hintText: _t('profile.selectDob', 'Select Date of Birth'),
                          controller: controller.dobController,
                          readOnly: true,
                          height: 52,
                          hintTextSize: 13,
                          onTap: () => controller.pickDate(context),
                          showSuffixIcon: true,
                          suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Qualification
                      _FieldLabel(_t('profile.qualification', 'Qualification')),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintTextColor: AppColors.grey,
                        hintText: _t('profile.enterQualification', 'Enter Qualification'),
                        controller: controller.qualificationController,
                        height: 52,
                        hintTextSize: 13,
                      ),
                      const SizedBox(height: 18),

                      // Profile Image
                      _FieldLabel(_t('profile.profileImage', 'Profile Image')),
                      const SizedBox(height: 8),
                      _ImagePickerField(
                        media: controller.profileMedia,
                        existingUrl: controller.existingProfileImageUrl,
                        fileName: controller.profileFileName,
                        onTap: () => controller.pickProfileImage(context),
                      ),
                      const SizedBox(height: 18),

                      // NIC Front
                      _FieldLabel(_t('profile.nicFront', 'NIC Front')),
                      const SizedBox(height: 8),
                      _ImagePickerField(
                        media: controller.nicFrontMedia,
                        existingUrl: controller.existingNicFrontUrl,
                        fileName: controller.nicFrontFileName,
                        onTap: () => controller.pickNicFront(context),
                      ),
                      const SizedBox(height: 18),

                      // NIC Back
                      _FieldLabel(_t('profile.nicBack', 'NIC Back')),
                      const SizedBox(height: 8),
                      _ImagePickerField(
                        media: controller.nicBackMedia,
                        existingUrl: controller.existingNicBackUrl,
                        fileName: controller.nicBackFileName,
                        onTap: () => controller.pickNicBack(context),
                      ),
                      const SizedBox(height: 18),

                      // Country
                      _FieldLabel(_t('profile.country', 'Country')),
                      const SizedBox(height: 8),
                      Obx(
                        () => AppTouchable(
                          child: CommonTextInputField(
                            hintText: _t('profile.selectCountry', 'Select Country'),
                            controller: controller.countryCtrl,
                            readOnly: true,
                            height: 52,
                            hintTextSize: 13,
                            showSuffixIcon: true,
                            suffixIcon: controller.isLoadingCountries.value
                                ? _loaderSuffix()
                                : const SizedBox(),
                            onTap: controller.isLoadingCountries.value
                                ? null
                                : () => _showDropdown(
                                      context,
                                      title: _t('profile.country', 'Country'),
                                      items: controller.countryLabels,
                                      selectedItem: controller.selectedCountry,
                                      textCtrl: controller.countryCtrl,
                                      values: controller.countryValues,
                                      onValueSelected: controller.onCountrySelected,
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // State
                      _FieldLabel(_t('profile.state', 'State')),
                      const SizedBox(height: 8),
                      Obx(
                        () => AppTouchable(
                          child: CommonTextInputField(
                            hintText: _t('profile.selectState', 'Select State'),
                            controller: controller.stateCtrl,
                            readOnly: true,
                            height: 52,
                            hintTextSize: 13,
                            showSuffixIcon: true,
                            suffixIcon: controller.isLoadingStates.value
                                ? _loaderSuffix()
                                : const SizedBox(),
                            onTap: controller.selectedCountryId.value == null
                                ? null
                                : () => _showDropdown(
                                      context,
                                      title: _t('profile.state', 'State'),
                                      items: controller.stateLabels,
                                      selectedItem: controller.selectedState,
                                      textCtrl: controller.stateCtrl,
                                      values: controller.stateValues,
                                      onValueSelected: controller.onStateSelected,
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // City
                      _FieldLabel(_t('profile.city', 'City')),
                      const SizedBox(height: 8),
                      Obx(
                        () => AppTouchable(
                          child: CommonTextInputField(
                            hintText: _t('profile.selectCity', 'Select City'),
                            controller: controller.cityCtrl,
                            readOnly: true,
                            height: 52,
                            hintTextSize: 13,
                            showSuffixIcon: true,
                            suffixIcon: controller.isLoadingCities.value
                                ? _loaderSuffix()
                                : const SizedBox(),
                            onTap: controller.selectedStateId.value == null
                                ? null
                                : () => _showDropdown(
                                      context,
                                      title: _t('profile.city', 'City'),
                                      items: controller.cityLabels,
                                      selectedItem: controller.selectedCity,
                                      textCtrl: controller.cityCtrl,
                                      values: controller.cityValues,
                                      onValueSelected: controller.onCitySelected,
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Area
                      _FieldLabel(_t('profile.area', 'Area')),
                      const SizedBox(height: 8),
                      Obx(
                        () => AppTouchable(
                          child: CommonTextInputField(
                            hintText: _t('profile.selectArea', 'Select Area'),
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
                                      title: _t('profile.area', 'Area'),
                                      items: controller.areaLabels,
                                      selectedItem: controller.selectedArea,
                                      textCtrl: controller.areaCtrl,
                                      values: controller.areaValues,
                                      onValueSelected: controller.onAreaSelected,
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Zip Code
                      _FieldLabel(_t('profile.zip', 'Zip Code')),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintTextColor: AppColors.grey,
                        hintText: _t('profile.enterZip', 'Enter Zip Code'),
                        controller: controller.zipController,
                        keyboardType: TextInputType.number,
                        height: 52,
                        hintTextSize: 13,
                      ),
                      const SizedBox(height: 18),

                      // Address
                      _FieldLabel(_t('profile.address', 'Address')),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintTextColor: AppColors.grey,
                        hintText: _t('profile.enterAddress', 'Enter Address'),
                        controller: controller.addressController,
                        maxLines: 3,
                        height: 96,
                        hintTextSize: 13,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      Obx(
                        () => MainBtn(
                          text: _t('profile.save', 'Save Changes'),
                          onPressed: controller.isLoading.value ? null : controller.save,
                          isLoading: controller.isLoading.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _PersonalInfoHeader extends StatelessWidget {
  final String title;

  const _PersonalInfoHeader({required this.title});

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

// ─── Image Picker Field ──────────────────────────────────────────────────────

class _ImagePickerField extends StatelessWidget {
  final Rxn<dynamic> media;
  final RxnString existingUrl;
  final RxString fileName;
  final VoidCallback onTap;

  const _ImagePickerField({
    required this.media,
    required this.existingUrl,
    required this.fileName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final m = media.value;
      // Depending on how MediaItem is structured in the app, usually it has networkUrl or thumbnailUrl
      final imageUrl = m?.thumbnailUrl ?? m?.networkUrl ?? existingUrl.value;
      final fName = fileName.value;

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
                  fName.isEmpty ? (imageUrl != null ? 'Existing Image' : 'No File Chosen') : fName,
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
              onTap: onTap,
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
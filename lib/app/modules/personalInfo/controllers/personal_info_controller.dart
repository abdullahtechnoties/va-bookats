import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class PersonalInfoController extends GetxController {
  final nameController = TextEditingController(text: '');
  final emailController = TextEditingController(text: 'demo@demo.com');
  final customerController = TextEditingController(text: 'demo@demo.com');
  final phonePrimaryController = TextEditingController(text: '1234567890');
  final phoneSecondaryController = TextEditingController(text: '1234567890');
  final dobController = TextEditingController(text: '');
  final qualificationController = TextEditingController(text: '');
  final zipController = TextEditingController(text: '127865');
  final addressController = TextEditingController(text: '');

  final RxString selectedCountry = 'Pakistan'.obs;
  final RxString selectedCity = 'Karachi'.obs;
  final RxString selectedState = 'Sindh'.obs;
  final RxString pickedFileName = 'No File Chosen'.obs;
  final RxBool isLoading = false.obs;

  // Dummy options
  final List<String> countries = ['Pakistan', 'UAE', 'Saudi Arabia', 'UK', 'USA'];
  final List<String> cities = ['Karachi', 'Lahore', 'Islamabad', 'Rawalpindi'];
  final List<String> states = ['Sindh', 'Punjab', 'KPK', 'Balochistan'];

  final ImagePicker _picker = ImagePicker();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    customerController.dispose();
    phonePrimaryController.dispose();
    phoneSecondaryController.dispose();
    dobController.dispose();
    qualificationController.dispose();
    zipController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    try {
      final XFile? file =
          await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        pickedFileName.value = file.name;
      }
    } catch (e) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'errors.imagePickerGallery'.trns(),
      );
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFF4D00),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      dobController.text =
          '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void save() {
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: 'personalInfo.savedSuccess'.trns(),
      );
    });
  }
}
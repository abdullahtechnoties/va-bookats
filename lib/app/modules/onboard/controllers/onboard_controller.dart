// lib/app/modules/onboard/controllers/onboard_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/service/auth_service.dart';

class OnboardController extends GetxController {
  final RxInt currentPage = 0.obs;
  late final PageController pageController;

  final List<Map<String, String>> slides = [
    {
      'titleKey': 'onboard.slide1.title',
      'descKey': 'onboard.slide1.desc',
      'image': 'assets/images/onboard.png',
    },
    {
      'titleKey': 'onboard.slide2.title',
      'descKey': 'onboard.slide2.desc',
      'image': 'assets/images/onboard.png',
    },
    {
      'titleKey': 'onboard.slide3.title',
      'descKey': 'onboard.slide3.desc',
      'image': 'assets/images/onboard.png',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void onContinue() async {
    if (currentPage.value < slides.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      await AuthService.firstTimeCompleted();
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  bool get isLastPage => currentPage.value == slides.length - 1;
}
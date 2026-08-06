import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/services/translation_service.dart';
import 'package:va_bookats/utilities/theme/dark_theme.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/utilities/theme/light_theme.dart';
import 'package:va_bookats/utilities/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VABookatsapp extends StatelessWidget {
  const VABookatsapp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      final locale = TranslationService.to.currentLocale.value;
      return GetMaterialApp(
        title: "app.name".trns(),
        initialRoute: AppPages.INITIAL,
        debugShowCheckedModeBanner: false,
        getPages: AppPages.routes,
        defaultTransition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 300),
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        theme: LightTheme().lightTheme(context),
        darkTheme: DarkTheme().darkTheme(context),
        locale: Locale(locale),
        fallbackLocale: const Locale('en'),
        builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(
             0.75,
          )),
          child: child!,
        );
      },
      );
    });
  }
}

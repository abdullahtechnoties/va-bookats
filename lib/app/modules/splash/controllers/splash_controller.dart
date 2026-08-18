import 'package:get/get.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/service/auth_service.dart';

class SplashController extends GetxController {
  final count = 0.obs;
    // logo opacity
  var logoOpacity = 0.0.obs;
  @override
  void onInit() {
    super.onInit();
    logoOpacity.value = 1.0;
    Future.delayed(const Duration(seconds: 3), () async {
      final initialRoute = await _resolveInitialRoute();
      Get.offAllNamed(initialRoute);
    });
    // final initialRoute = await _resolveInitialRoute();
  }

  Future<String> _resolveInitialRoute() async {
    final isFirstTime = AuthService.firstTimeOnApp();
    final token = await AuthService.getAuthBearerToken();
    final isAuthed = AuthService.authenticated();

    if (isFirstTime) return Routes.ONBOARD;
    if (isAuthed && token.isNotEmpty) return Routes.BOTTOMNAV;
    return Routes.LOGIN;
  }

}
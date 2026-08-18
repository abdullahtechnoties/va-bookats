import 'dart:convert';
import 'package:va_bookats/models/user_model.dart';
import 'package:va_bookats/network/service/local_storage.dart';
import 'package:va_bookats/utilities/app_strings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  static const String accessTokenKey = 'access_token';

  final Rx<String?> accessToken = Rx<String?>(null);
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<String?> companyId = Rx<String?>(null);
  late final Future<void> ready;
  static final RxBool _logoutInProgress = false.obs;


    // Role helpers
  // bool get isVendor => currentUser.value?.roles?.any((role) => role.name?.toLowerCase() == 'vendor') ?? false;
  // bool get isCompany => currentUser.value?.roles?.any((role) => role.name?.toLowerCase() == 'company') ?? false;
  bool get isCustomer => currentUser.value?.roles?.any((role) => role.name?.toLowerCase() == 'Customer') ?? false;
  bool get isOwner => currentUser.value?.roles?.any((role) => role.name?.toLowerCase() == 'owner') ?? false;

  // Check if user has allowed role for this app
  bool get hasAllowedRole => isOwner;


  @override
  void onInit() async {
    super.onInit();
    ready = _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      _loadAccessToken(),
      _loadCurrentUser(),
      _loadCompanyId(),
    ]);
    print({
      'AuthService init': '${accessToken.value}, ${currentUser.value}, ${companyId.value}'
    });
  }

  Future<void> _loadAccessToken() async {
    final token = await getAuthBearerToken();
    print('Loaded access token: $token');
    accessToken.value = token.isEmpty ? null : token;
  }

  Future<void> _loadCurrentUser() async {
    final raw = LocalStorageService.prefs?.getString(AppStrings.userKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      print('Loaded current user: $decoded');
      if (decoded is Map) {
        print('Decoded user data: $decoded');
        currentUser.value = UserModel.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      print('Failed to decode user data: $raw');
      currentUser.value = null;
    }
  }

  Future<void> _loadCompanyId() async {
    final id = await getSavedCompanyId();
    companyId.value = (id == null || id.isEmpty) ? null : id;
    print('Loaded company id: ${companyId.value}');
  }

  Future<void> setAccessToken(String token) async {
    await setAuthBearerToken(token);
    accessToken.value = token.isEmpty ? null : token;
  }

  Future<void> setCurrentUser(UserModel? user) async {
    if (user == null) {
      await LocalStorageService.prefs?.remove(AppStrings.userKey);
      currentUser.value = null;
      return;
    }

    await LocalStorageService.prefs?.setString(
      AppStrings.userKey,
      jsonEncode(user.toJson()),
    );
    currentUser.value = user;
  }

  static bool firstTimeOnApp() {
    return LocalStorageService.prefs?.getBool(AppStrings.firstTimeOnApp) ??
        true;
  }

  static Future<void> firstTimeCompleted() async {
    await LocalStorageService.prefs?.setBool(AppStrings.firstTimeOnApp, false);
  }

  static bool authenticated() {
    return LocalStorageService.prefs?.getBool(AppStrings.authenticated) ??
        false;
  }

  static Future<bool> isAuthenticated() async {
    await LocalStorageService.prefs?.setBool(AppStrings.authenticated, true);
    return LocalStorageService.prefs!.getBool(AppStrings.authenticated) ??
        false;
  }

  static Future<void> setAuthenticated(bool value) async {
    await LocalStorageService.prefs?.setBool(AppStrings.authenticated, value);
  }

  static Future<String> getAuthBearerToken() async {
    return LocalStorageService.prefs?.getString(AppStrings.userAuthToken) ?? "";
  }

  static Future<bool> setAuthBearerToken(String token) async {
    return LocalStorageService.prefs!.setString(
      AppStrings.userAuthToken,
      token,
    );
  }

  /// Persists the company id and exposes it reactively so the network
  /// interceptor can attach `X-Company-Id` to every outgoing request.
  Future<void> setCompanyId(String? id) async {
    await setSavedCompanyId(id ?? '');
    companyId.value = (id == null || id.isEmpty) ? null : id;
  }

  static Future<bool> setSavedCompanyId(String id) async {
    return LocalStorageService.prefs!.setString(AppStrings.userCompanyId, id);
  }

  static Future<String?> getSavedCompanyId() async {
    return LocalStorageService.prefs?.getString(AppStrings.userCompanyId);
  }

  static Future<void> saveLocale(String locale) async {
    await LocalStorageService.prefs?.setString(AppStrings.appLocale, locale);
  }

  static Future<String?> getSavedLocale() async {
    return LocalStorageService.prefs?.getString(AppStrings.appLocale);
  }


  static Future<void> logout() async {
    // Clear FCM token first
    // await NotificationService.instance.clearTokenOnLogout();
    await FirebaseMessaging.instance.deleteToken();
    await LocalStorageService.prefs?.clear();
    await LocalStorageService.prefs?.setBool(AppStrings.firstTimeOnApp, false);
  }

  bool get requiresProfileCompletion =>
      currentUser.value == null || !currentUser.value!.hasBasicDetails;

  static Future<void> forceLogout({bool showLogin = true}) async {
    if (_logoutInProgress.value) return;
    _logoutInProgress.value = true;

    try {
      await logout();
      if (Get.isRegistered<AuthService>()) {
        final service = Get.find<AuthService>();
        service.accessToken.value = null;
        service.currentUser.value = null;
      }
      // currentUser = null;
      if (showLogin && Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
    } finally {
      _logoutInProgress.value = false;
    }
  }

  static bool get isLogoutInProgress => _logoutInProgress.value;
  static RxBool get logoutInProgressObs => _logoutInProgress;
}

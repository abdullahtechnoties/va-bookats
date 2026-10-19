import 'dart:convert';
import 'dart:developer' as developer;
import 'package:va_bookats/models/user_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/service/local_storage.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/app_strings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  static const String accessTokenKey = 'access_token';

  final Rx<String?> accessToken = Rx<String?>(null);
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<String?> companyId = Rx<String?>(null);

  /// Laravel permissions from the login response (`resource.action`).
  /// Single source of truth — read via `Permissions.can()` /
  /// the `Can` widget, never directly.
  final RxSet<String> permissions = <String>{}.obs;

  /// Bumped on every permissions change so `Permissions.can()` calls
  /// inside `Obx` builders stay reactive. (Local tick — not to be
  /// confused with the backend `perm_version` below.)
  final RxInt permissionsVersion = 0.obs;

  /// Backend permission version (`perm_version`, e.g. `2:uuid`).
  /// Every API response carries it as the `X-Perm-Version` header;
  /// a mismatch triggers a background refresh from
  /// `GET /current-permissions`.
  final RxString permVersion = ''.obs;

  /// Whether permissions were loaded this session (fresh login or
  /// restored cache). Until then `can()` falls back to the legacy
  /// owner check so cached sessions never brick the UI.
  final RxBool permissionsLoaded = false.obs;
  late final Future<void> ready;
  static final RxBool _logoutInProgress = false.obs;

  // Role helpers
  // bool get isVendor => currentUser.value?.roles?.any((role) => role.name?.toLowerCase() == 'vendor') ?? false;
  // bool get isCompany => currentUser.value?.roles?.any((role) => role.name?.toLowerCase() == 'company') ?? false;
  bool get isCustomer =>
      currentUser.value?.roles?.any(
        (role) => role.name?.toLowerCase() == 'Customer',
      ) ??
      false;
  bool get isOwner =>
      currentUser.value?.roles?.any(
        (role) => role.name?.toLowerCase() == 'owner',
      ) ??
      false;

  // Check if user has allowed role for this app
  bool get hasAllowedRole => isOwner;

  /// Mirrors the admin panel `can("users.create")` check.
  /// Strict once permissions load; legacy owner fallback before that
  /// (e.g. cached sessions from before permissions existed).
  bool can(String permission) {
    if (permissionsLoaded.value) return permissions.contains(permission);
    return isOwner;
  }

  bool canAny(Iterable<String> perms) => perms.any(can);

  bool canAll(Iterable<String> perms) => perms.every(can);

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
      _loadPermissions(),
      _loadPermVersion(),
    ]);
    print({
      'AuthService init':
          '${accessToken.value}, ${currentUser.value}, ${companyId.value}',
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
        currentUser.value = UserModel.fromJson(
          Map<String, dynamic>.from(decoded),
        );
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

  Future<void> _loadPermissions() async {
    final stored =
        LocalStorageService.prefs?.getStringList(AppStrings.userPermissionsKey);
    if (stored == null) return;
    permissions.assignAll(stored.where((p) => p.isNotEmpty));
    permissionsLoaded.value = true;
    permissionsVersion.value++;
  }

  Future<void> _loadPermVersion() async {
    final stored =
        LocalStorageService.prefs?.getString(AppStrings.userPermVersionKey);
    if (stored == null || stored.isEmpty) return;
    permVersion.value = stored;
  }

  /// Persists + exposes the login response `perm_version`.
  Future<void> setPermVersion(String version) async {
    final clean = version.trim();
    await LocalStorageService.prefs?.setString(
      AppStrings.userPermVersionKey,
      clean,
    );
    permVersion.value = clean;
  }

  /// Persists + exposes the login response permissions.
  Future<void> setPermissions(Iterable<String> perms) async {
    final clean = perms.map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    await LocalStorageService.prefs?.setStringList(
      AppStrings.userPermissionsKey,
      clean,
    );
    permissions.assignAll(clean);
    permissionsLoaded.value = true;
    permissionsVersion.value++;
  }

  Future<void> clearPermissions() async {
    await LocalStorageService.prefs?.remove(AppStrings.userPermissionsKey);
    await LocalStorageService.prefs?.remove(AppStrings.userPermVersionKey);
    permissions.clear();
    permVersion.value = '';
    permissionsLoaded.value = false;
    permissionsVersion.value++;
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
    // await FirebaseMessaging.instance.deleteToken();
    if (Get.isRegistered<NetworkService>()) {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.logout,
      );
      if (!response.isCompleted) {
        developer.log(
          'Logout request failed: ${response.message}',
          name: 'AuthService',
        );
      }
    }
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
        service.companyId.value = null;
        service.permissions.clear();
        service.permVersion.value = '';
        service.permissionsLoaded.value = false;
        service.permissionsVersion.value++;
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

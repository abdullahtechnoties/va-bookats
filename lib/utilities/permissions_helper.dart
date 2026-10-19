// lib/utilities/permissions_helper.dart
//
// Single source of truth for Laravel-style permission gating in the app.
// Mirrors the admin panel hook:
//
//   const { can } = usePermissions();   // React
//   {can("users.create") && (<Button/>)}
//
//   if (Permissions.can('users.create')) ...   // Flutter
//   Can('users.create', child: ...),           // Flutter widget
//
// Permission names come from the login response top-level `permissions`
// array (`resource.action`: index/create/store/show/edit/update/destroy)
// and are stored on AuthService. UI mapping used across the app:
//   index   → menu entries / list screens
//   show    → view-details navigation
//   create  → add/new buttons (form entry)
//   edit    → edit buttons
//   update  → status toggles / in-place mutations
//   destroy → delete buttons

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// Laravel resource names, kept in one place so call-site strings
/// can't drift from the backend permission names.
abstract class AppPerm {
  static const String branches = 'branches';
  static const String packages = 'packages';
  static const String payments = 'payments';
  static const String users = 'users';
  static const String roles = 'roles';
  static const String customers = 'customers';
  static const String staffs = 'staffs';
  static const String expenses = 'expenses';
  static const String expenseCategories = 'expense-categories';
  static const String services = 'services';
  static const String serviceCategories = 'service-categories';
  static const String products = 'products';
  static const String productCategories = 'product-categories';
  static const String brands = 'brands';
  static const String tags = 'tags';
  static const String units = 'units';
  static const String productVariations = 'product-variations';
  static const String bookings = 'bookings';
  static const String media = 'media';
  static const String galleryImages = 'gallery-images';

  static String index(String resource) => '$resource.index';
  static String create(String resource) => '$resource.create';
  static String show(String resource) => '$resource.show';
  static String edit(String resource) => '$resource.edit';
  static String update(String resource) => '$resource.update';
  static String destroy(String resource) => '$resource.destroy';
}

class Permissions {
  Permissions._();

  static AuthService? get _auth =>
      Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;

  /// Whether the current user may do [permission] (e.g. `'users.create'`).
  ///
  /// Safe to call inside `Obx`/ reactive builders: it touches the
  /// permissions version counter, so gated widgets rebuild automatically
  /// whenever permissions load or change.
  static bool can(String permission) {
    final auth = _auth;
    if (auth == null) return false;
    // Touch the reactive version so Obx builders subscribe.
    auth.permissionsVersion.value;
    return auth.can(permission);
  }

  /// True when the user has at least one of [permissions].
  static bool canAny(Iterable<String> permissions) {
    final auth = _auth;
    if (auth == null) return false;
    auth.permissionsVersion.value;
    return permissions.any(auth.can);
  }

  /// True when the user has every permission in [permissions].
  static bool canAll(Iterable<String> permissions) {
    final auth = _auth;
    if (auth == null) return false;
    auth.permissionsVersion.value;
    return permissions.every(auth.can);
  }
}

/// Widget equivalent of `{can("users.create") && (<Button/>)}`.
///
/// Shows [child] when the user has [permission] (or [any]/[all] of
/// [permissions]), otherwise [fallback] (nothing by default).
class Can extends StatelessWidget {
  final String? permission;
  final List<String>? permissions;
  final bool requireAll;
  final Widget child;
  final Widget fallback;

  const Can(
    this.permission, {
    super.key,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  })  : permissions = null,
        requireAll = false;

  const Can.any(
    this.permissions, {
    super.key,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  })  : permission = null,
        requireAll = false;

  const Can.all(
    this.permissions, {
    super.key,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  })  : permission = null,
        requireAll = true;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final allowed = permission != null
          ? Permissions.can(permission!)
          : requireAll
              ? Permissions.canAll(permissions ?? const [])
              : Permissions.canAny(permissions ?? const []);
      return allowed ? child : fallback;
    });
  }
}

/// Graceful "no access" tooltip popup, shown when a visible-but-gated
/// control (e.g. a bottom-nav tab) is tapped without the permission.
/// Dismisses via OK or tapping outside.
Future<void> showNoAccessDialog() {
  if (Get.isDialogOpen == true) return Future.value();
  return Get.dialog(
    Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 48),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'permissions.noAccess.title'.trns(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'permissions.noAccess.message'.trns(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'permissions.noAccess.ok'.trns(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

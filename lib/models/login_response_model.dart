import 'package:va_bookats/models/user_model.dart';

/// Response model for the login endpoint:
///
/// ```json
/// {
///   "token": "1|...",
///   "user": { ... },
///   "companyId": null
/// }
/// ```
///
/// All fields are parsed defensively (null / wrong-type safe) so a partial
/// response never crashes the app.
class LoginResponse {
  final String? token;
  final UserModel? user;
  final String? companyId;
  final String? role;

  /// Flat Laravel permissions (`resource.action`) from the top-level
  /// `permissions` array. Empty when the backend omits it.
  final List<String> permissions;

  /// Backend permission version (`perm_version`, e.g. `2:uuid`).
  /// Every later API response echoes it as `X-Perm-Version`.
  final String permVersion;

  /// Account status from login (`active`, …). Informational only.
  final String status;

  const LoginResponse({
    this.token,
    this.user,
    this.companyId,
    this.role,
    this.permissions = const [],
    this.permVersion = '',
    this.status = '',
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final rawPerms = json['permissions'];

    return LoginResponse(
      token: json['token']?.toString(),
      user: rawUser is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(rawUser))
          : null,
      companyId: json['companyId']?.toString(),
      role: json['role']?.toString(),
      permissions: rawPerms is List
          ? rawPerms
              .map((e) => e?.toString().trim() ?? '')
              .where((p) => p.isNotEmpty)
              .toList()
          : const [],
      permVersion: json['perm_version']?.toString().trim() ?? '',
      status: json['status']?.toString().trim() ?? '',
    );
  }

  bool get hasCredentials => (token?.isNotEmpty ?? false) || user != null;
}

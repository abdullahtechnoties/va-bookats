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

  const LoginResponse({this.token, this.user, this.companyId, this.role});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];

    return LoginResponse(
      token: json['token']?.toString(),
      user: rawUser is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(rawUser))
          : null,
      companyId: json['companyId']?.toString(),
      role: json['role']?.toString(),
    );
  }

  bool get hasCredentials => (token?.isNotEmpty ?? false) || user != null;
}

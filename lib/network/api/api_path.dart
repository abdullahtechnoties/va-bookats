class ApiPath {
  // // Common Endpoints
  // static const String baseUrl = 'https://va_bookats.screenlinktechnologies.com/api/admin';
  // static const String imageUrl = 'https://va_bookats.screenlinktechnologies.com/storage';
  // Local Endpoints
  static const String baseUrl =
      'https://subregular-lauretta-nonprovocatively.ngrok-free.dev/api/admin';
  static const String imageUrl =
      'https://subregular-lauretta-nonprovocatively.ngrok-free.dev/storage';

  // Common Endpoints
  static const String getSetupFcm = '/users/fcm-token';
  static String userProfile(int userId) => '/users/$userId';
  static const String deleteAccount = '/users';

    // Lookup Endpoints


  // Auth Endpoints
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String resendCode = '/resend-code';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String profileUpdate = '/profile/update';
  static const String profileComplete = '/profile/complete';
  static const String sendResetCode = '/resend-code';

  // Data / Lookups
  static const String branches = '/data/branches';
  static String dataServices(int branchId) => '/data/services?branch_id=$branchId';

  // Service Categories
  static const String serviceCategories = '/service-categories';
  static String serviceCategory(int id) => '/service-categories/$id';
  static String serviceCategoryStatus(int id) => '/service-categories/$id/status';

  // Services
  static const String services = '/services';
  static String service(int id) => '/services/$id';
  static String serviceStatus(int id) => '/services/$id/status';

  // Packages
  static const String packages = '/packages';
  static String package(int id) => '/packages/$id';
  static String packageStatus(int id) => '/packages/$id/status';

  // Reports
  static const String revenueReport = '/reports/revenue';
  static const String revenueDetails = '/reports/revenue/show';

  // Geo (Unauthenticated)
  static const String countries = '/countries';
  static String countryStates(int countryId) => '/states?country_id=$countryId';
  static String stateCities(int stateId) => '/cities?state_id=$stateId';
  static String cityAreas(int cityId) => '/areas?city_id=$cityId';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(int id) => '/notifications/read/$id';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // Support Tickets
  static const String tickets = '/tickets';
  static String ticketById(int id) => '/tickets/$id';
  static String ticketSend(int id) => '/tickets/$id/send';
  static String ticketSendFile(int id) => '/tickets/$id/send-file';
  static String ticketSendVoice(int id) => '/tickets/$id/send-voice';
  static String ticketRead(int id) => '/tickets/$id/read';
  static const String supportUnreadCount = '/unread-count';

}


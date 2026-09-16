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
  static const String profile = '/profile';
  static const String profileUpdate = '/profile/update';
  static const String profileComplete = '/profile/complete';
  static const String sendResetCode = '/resend-code';

  // Data / Lookups
  static const String branches = '/data/branches';
  static String dataServices(int branchId) =>
      '/data/services?branch_id=$branchId';

  // Service Categories
  static const String serviceCategories = '/service-categories';
  static String serviceCategory(int id) => '/service-categories/$id';
  static String serviceCategoryStatus(int id) =>
      '/service-categories/$id/status';

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
  // Reports - Branch Comparison
  static const String branchComparisonReport = '/reports/branch/comparison';
  static String branchComparisonReportDetails =
      '/reports/branch/comparison/show';
  // Reports - ServiceRevenueReport
  static const String serviceRevenueReport = '/reports/services/revenue';
  static const String serviceRevenueReportDetails =
      '/reports/services/revenue/show';
  // Product Revenue Report
  static const String productRevenue = '/reports/products/revenue';
  static const String productRevenueDetails = '/reports/products/revenue/show';
  // Package Revenue Reports
  static const String packageRevenueReport = '/reports/packages/revenue';
  static const String packageRevenueDetails = '/reports/packages/revenue/show';
  // Commission Reports
  // Reports
  static const String commissionsReport = '/reports/commissions';
  static String commissionsReportDetails({
    required int branchId,
    required String fromDate,
    required String toDate,
    String? staffId,
    int page = 1,
  }) {
    final params = <String, String>{
      'branch_id': branchId.toString(),
      'from_date': fromDate,
      'to_date': toDate,
      'page': page.toString(),
    };
    if (staffId != null && staffId.isNotEmpty) {
      params['staff_id'] = staffId;
    }
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '/reports/commissions/show?$query';
  }

  // Geo (Unauthenticated)
  static const String countries = '/data/countries';
  static String countryStates(int countryId) =>
      '/data/states?country_id=$countryId';
  static String stateCities(int stateId) => '/data/cities?state_id=$stateId';
  static String cityAreas(int cityId) => '/data/areas?city_id=$cityId';

  // Media Library
  static const String media = '/media';

  // Customers
  static const String customers = '/customers';
  static String customer(int id) => '/customers/$id';
  static String customerStatus(int id) => '/customers/$id/status';

  // Geo (Authenticated select helpers — same unauthenticated endpoints)
  static const String geoCountries = '/countries';
  static String geoStates(int countryId) => '/states?country_id=$countryId';
  static String geoCities(int stateId) => '/cities?state_id=$stateId';
  static String geoAreas(int cityId) => '/areas?city_id=$cityId';

  // Bookings
  static const String bookings = '/bookings';
  static String booking(int id) => '/bookings/$id';
  static String bookingStatus(int id) => '/bookings/$id/status';

  // Booking lookups
  static const String bookingCustomers = '/data/customers';
  static String bookingPackages(int branchId) =>
      '/data/packages?branch_id=$branchId';
  static String bookingPackageStaffs(int packageId) =>
      '/data/packages/$packageId/staffs';
  static String bookingServices(int branchId) =>
      '/data/services?branch_id=$branchId';
  static String bookingServiceStaffs(int serviceId) =>
      '/data/services/$serviceId/staffs';
  static String bookingProducts(int branchId) =>
      '/data/products?branch_id=$branchId';

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

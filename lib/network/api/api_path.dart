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

  /// Live permission sync — returns `{role, permissions, perm_version,
  /// status}`. A deactivated account gets `{code: account_inactive, …}`.
  static const String currentPermissions = '/current-permissions';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String profile = '/profile';
  static const String profileUpdate = '/profile/update';
  static const String profileComplete = '/profile/complete';
  static const String sendResetCode = '/resend-code';

  // Data / Lookups
  static const String branches = '/data/branches';
  static String dataServiceCategories(int branchId) =>
      '/data/service-categories?branch_id=$branchId';
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

  // Products
  static const String products = '/products';
  static String product(int id) => '/products/$id';
  static String productStatus(int id) => '/products/$id/status';

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
  // Customer Reports
  static const String customersReport = '/reports/customers';
  static const String customersReportDetails = '/reports/customers/show';
  // Commission Reports
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
      // Always send staff_id: 'all' when nothing is selected.
      'staff_id': (staffId == null || staffId.isEmpty) ? 'all' : staffId,
      'page': page.toString(),
    };
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '/reports/commissions/show?$query';
  }

  // Expenses Reports
  static const String expenseReport = '/reports/expense';
  static String expenseReportDetails({
    required int branchId,
    required String expenseCategoryId,
    required String fromDate,
    required String toDate,
    int page = 1,
  }) =>
      '/reports/expense/show?branch_id=$branchId&expenseCategory_id=$expenseCategoryId&from_date=$fromDate&to_date=$toDate&page=$page';
  static String expenseCategories(int branchId) =>
      '/data/expense-categories?branch_id=$branchId';

  // Geo (Unauthenticated)
  static const String countries = '/data/countries';
  static String countryStates(int countryId) =>
      '/data/states?country_id=$countryId';
  static String stateCities(int stateId) => '/data/cities?state_id=$stateId';
  static String cityAreas(int cityId) => '/data/areas?city_id=$cityId';

  // Media Library
  static const String media = '/media';

  // Home dashboard (booking counts, revenue graph, and recent bookings)
  static const String home = '/home';

  // Customers
  static const String customers = '/customers';
  static String customer(int id) => '/customers/$id';
  static String customerStatus(int id) => '/customers/$id/status';

  // Bookings
  static const String bookings = '/bookings';
  static String booking(int id) => '/bookings/$id';
  static String bookingStatus(int id) => '/bookings/$id/status';
  static String bookingDetails(int id) => '/bookings/$id/details';

  // Payments
  static const String payments = '/payments';
  static String payment(int id) => '/payments/$id';

  // Product form lookups (all branch-scoped, all support runtime creation)
  static String dataBrands(int branchId) => '/data/brands?branch_id=$branchId';
  static const String brands = '/brands';
  static String dataProductCategories(int branchId) =>
      '/data/product-categories?branch_id=$branchId';
  static const String productCategories = '/product-categories';
  static String dataTags(int branchId) => '/data/tags?branch_id=$branchId';
  static const String tags = '/tags';
  static String dataUnits(int branchId) => '/data/units?branch_id=$branchId';
  static const String units = '/units';
  static String dataProductVariations(int branchId) =>
      '/data/product-variations?branch_id=$branchId';
  static const String productVariations = '/product-variations';

  /// Best-effort values lookup for one variation type. No documented
  /// endpoint exists, so the conventional show routes are probed in order;
  /// a miss degrades gracefully to an empty list.
  static String productVariationValues(int typeId) =>
      '/product-variations/$typeId';
  static String dataProductVariationValues(int typeId) =>
      '/data/product-variations/$typeId';

  // Inventory item + status routes (list consts live with the lookups above)
  static String brand(int id) => '/brands/$id';
  static String brandStatus(int id) => '/brands/$id/status';
  static String productCategory(int id) => '/product-categories/$id';
  static String productCategoryStatus(int id) =>
      '/product-categories/$id/status';
  static String tag(int id) => '/tags/$id';
  static String tagStatus(int id) => '/tags/$id/status';
  static String unit(int id) => '/units/$id';
  static String unitStatus(int id) => '/units/$id/status';
  static String productVariation(int id) => '/product-variations/$id';
  static String productVariationStatus(int id) =>
      '/product-variations/$id/status';

  // Booking lookups
  static String bookingCustomers({int? branchId}) => branchId == null
      ? '/data/customers'
      : '/data/customers?branch_id=$branchId';
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

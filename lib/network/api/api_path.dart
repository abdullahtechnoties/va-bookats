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
    static const String nationalities = '/nationalities';
    static const String religions = '/religions';
    static const String sects = '/sects';
    static const String ethnicities = '/ethnicities';
    static const String educations = '/educations';
    static const String occupations = '/occupations';
    static const String hairColors = '/hair-colors';
    static const String eyeColors = '/eye-colors';
    static const String skinColors = '/skin-colors';
    static const String maritalStatuses = '/marital-statuses';
    static const String prayerFrequencies = '/prayer-frequencies';
    static const String dressCodes = '/dress-codes';
    static const String dietaryPreferences = '/dietary-preferences';
    static const String bodyTypes = '/body-types';

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

  // Service Categories
  static const String serviceCategories = '/service-categories';
  static String serviceCategory(int id) => '/service-categories/$id';
  static String serviceCategoryStatus(int id) => '/service-categories/$id/status';

  // Services
  static const String services = '/services';
  static String service(int id) => '/services/$id';
  static String serviceStatus(int id) => '/services/$id/status';

  static const String winkTemplates = '/wink-templates';
  static const String winks = '/winks';
  static const String pings = '/pings';
  static const String profileImage = '/profile/image';

  // Blocks & Profile Visits
  static const String blocks = '/blocks';
  static String blockByUser(int userId) => '/blocks/$userId';
  static const String profileVisits = '/profile-visits';
  static const String profileVisitors = '/profile-visits/visitors';


  // Geo (Unauthenticated)
  static const String countries = '/countries';
  static String countryStates(int countryId) => '/states?country_id=$countryId';
  static String stateCities(int stateId) => '/cities?state_id=$stateId';
  static String cityAreas(int cityId) => '/areas?city_id=$cityId';

  // Activity / Swipe history
  static const String discover = '/discover';
  static const String likesMe = '/swipes/likes-me';
  static const String liked = '/swipes/liked';
  static const String passed = '/swipes/passed';
  static const String swipes = '/swipes'; 

  // Pings
  static const String pingsReceived = '/pings/received';
  static String pingRespond(int pingId) => '/pings/$pingId/respond';


  // Chat (Conversations)
  static const String chats = '/conversations';
  static String chatMessages(int chatId) =>
      '/conversations/$chatId/messages';
  static String chatSend(int chatId) => '/messages/$chatId/send';
  static String chatSendFile(int chatId) => '/messages/$chatId/send-file';
  static String chatSendVoice(int chatId) => '/messages/$chatId/send-voice';
  static String chatRead(int chatId) => '/conversations/$chatId/read';

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

  // Posts
  static const String posts = '/posts';
  static String postById(int id) => '/posts/$id';
  static String postLike(int id) => '/posts/$id/like';
  static String postSave(int id) => '/posts/$id/save';
  static String postComments(int id) => '/posts/$id/comments';

  // Comments
  static String commentById(int id) => '/comments/$id';
  static String commentLike(int id) => '/comments/$id/like';

  // Stories
  static const String stories = '/stories';
  static String storyById(int id) => '/stories/$id';
  static String storyViewers(int id) => '/stories/$id/viewers';

}


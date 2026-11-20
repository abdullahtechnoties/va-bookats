// lib/app/modules/dailyClosing/models/daily_closing_model.dart
//
// Models for the Daily Closing module.
//
// Shapes come straight from closing-api.txt:
//   GET  /daily-closings            → { dailyClosings: paginator, today, branch_id }
//   GET  /daily-closings/{id}       → { dailyClosing, activities, bookings, payments,
//                                       staffCommissions, expenses, serviceSummary,
//                                       productSummary, packageSummary, cashFlow,
//                                       cashFlowSummary, membershipSummary }
//   POST /daily-closings            → { message, daily_closing }
//   PUT  /daily-closings/{id}/status→ { message, status }
//   GET  /daily-closings/today      → { exists, opening_balance, status }

import 'package:va_bookats/network/response/pagination_helper.dart';

/// Branch information nested inside a daily closing.
class ClosingBranch {
  final int? id;
  final String name;
  final String emailPrimary;
  final String phonePrimary;
  final String currencySymbol;

  const ClosingBranch({
    this.id,
    this.name = '',
    this.emailPrimary = '',
    this.phonePrimary = '',
    this.currencySymbol = '',
  });

  factory ClosingBranch.fromJson(Map<String, dynamic> json) {
    final currency = json['currency'];
    return ClosingBranch(
      id: _int(json['id']),
      name: json['name']?.toString() ?? '',
      emailPrimary: json['email_primary']?.toString() ?? '',
      phonePrimary: json['phone_primary']?.toString() ?? '',
      currencySymbol: currency is Map
          ? currency['symbol']?.toString() ?? ''
          : '',
    );
  }
}

/// Lightweight user (creator / approver / activity author).
class ClosingUser {
  final int id;
  final String name;
  final String imageUrl;
  final String imageThumbUrl;

  const ClosingUser({
    this.id = 0,
    this.name = '',
    this.imageUrl = '',
    this.imageThumbUrl = '',
  });

  factory ClosingUser.fromJson(Map<String, dynamic> json) => ClosingUser(
    id: _int(json['id']) ?? 0,
    name: json['name']?.toString() ?? '',
    imageUrl: json['image_url']?.toString() ?? '',
    imageThumbUrl: json['image_thumb_url']?.toString() ?? '',
  );

  String get bestImageUrl =>
      imageThumbUrl.isNotEmpty ? imageThumbUrl : imageUrl;
}

/// One row of the daily closings list (and the create response).
class DailyClosingModel {
  final int id;
  final String status;
  final String closingDate;
  final int? branchId;
  final int? createdBy;
  final int? approvedBy;
  final String openingBalance;
  final ClosingBranch? branch;
  final ClosingUser? creator;
  final ClosingUser? approver;

  // ── Detail-only aggregates (default 0 so list rows stay cheap) ────────
  final int totalServicesSold;
  final String serviceRevenue;
  final int totalProductsSold;
  final String productRevenue;
  final int totalPackagesSold;
  final String packageRevenue;
  final int totalCustomers;
  final int guestBookingCount;
  final int totalBookings;
  final int repeatCustomers;
  final String staffCommissionTotal;
  final int cancelledBookings;
  final String cashPayment;
  final String cardPayment;
  final String onlinePayment;
  final String returnPayment;
  final String totalExpense;
  final String totalRevenue;
  final String totalAmount;
  final String totalDiscount;
  final String totalBalance;
  final int cashCount;
  final int cardCount;
  final int onlineCount;
  final int unpaidCount;
  final int paidCount;
  final int totalCount;
  final String unpaidAmount;
  final String remarks;
  final String serviceAdditionalAmount;
  final String packageAdditionalAmount;
  final String totalAdditionalAmount;
  final String topServiceName;
  final String topProductName;
  final String topPackageName;

  const DailyClosingModel({
    required this.id,
    this.status = '',
    this.closingDate = '',
    this.branchId,
    this.createdBy,
    this.approvedBy,
    this.openingBalance = '0',
    this.branch,
    this.creator,
    this.approver,
    this.totalServicesSold = 0,
    this.serviceRevenue = '0',
    this.totalProductsSold = 0,
    this.productRevenue = '0',
    this.totalPackagesSold = 0,
    this.packageRevenue = '0',
    this.totalCustomers = 0,
    this.guestBookingCount = 0,
    this.totalBookings = 0,
    this.repeatCustomers = 0,
    this.staffCommissionTotal = '0',
    this.cancelledBookings = 0,
    this.cashPayment = '0',
    this.cardPayment = '0',
    this.onlinePayment = '0',
    this.returnPayment = '0',
    this.totalExpense = '0',
    this.totalRevenue = '0',
    this.totalAmount = '0',
    this.totalDiscount = '0',
    this.totalBalance = '0',
    this.cashCount = 0,
    this.cardCount = 0,
    this.onlineCount = 0,
    this.unpaidCount = 0,
    this.paidCount = 0,
    this.totalCount = 0,
    this.unpaidAmount = '0',
    this.remarks = '',
    this.serviceAdditionalAmount = '0',
    this.packageAdditionalAmount = '0',
    this.totalAdditionalAmount = '0',
    this.topServiceName = '',
    this.topProductName = '',
    this.topPackageName = '',
  });

  factory DailyClosingModel.fromJson(Map<String, dynamic> json) {
    return DailyClosingModel(
      id: _int(json['id']) ?? 0,
      status: json['status']?.toString() ?? '',
      closingDate: json['closing_date']?.toString() ?? '',
      branchId: _int(json['branch_id']),
      createdBy: _int(json['created_by']),
      approvedBy: _int(json['approved_by']),
      openingBalance: _string(json['opening_balance'], '0'),
      branch: json['branch'] is Map
          ? ClosingBranch.fromJson(
              Map<String, dynamic>.from(json['branch'] as Map),
            )
          : null,
      creator: json['creator'] is Map
          ? ClosingUser.fromJson(
              Map<String, dynamic>.from(json['creator'] as Map),
            )
          : null,
      approver: json['approver'] is Map
          ? ClosingUser.fromJson(
              Map<String, dynamic>.from(json['approver'] as Map),
            )
          : null,
      totalServicesSold: _int(json['total_services_sold']) ?? 0,
      serviceRevenue: _string(json['service_revenue'], '0'),
      totalProductsSold: _int(json['total_products_sold']) ?? 0,
      productRevenue: _string(json['product_revenue'], '0'),
      totalPackagesSold: _int(json['total_packages_sold']) ?? 0,
      packageRevenue: _string(json['package_revenue'], '0'),
      totalCustomers: _int(json['total_customers']) ?? 0,
      guestBookingCount: _int(json['guest_booking_count']) ?? 0,
      totalBookings: _int(json['total_bookings']) ?? 0,
      repeatCustomers: _int(json['repeat_customers']) ?? 0,
      staffCommissionTotal: _string(json['staff_commission_total'], '0'),
      cancelledBookings: _int(json['cancelled_bookings']) ?? 0,
      cashPayment: _string(json['cash_payment'], '0'),
      cardPayment: _string(json['card_payment'], '0'),
      onlinePayment: _string(json['online_payment'], '0'),
      returnPayment: _string(json['return_payment'], '0'),
      totalExpense: _string(json['total_expense'], '0'),
      totalRevenue: _string(json['total_revenue'], '0'),
      totalAmount: _string(json['total_amount'], '0'),
      totalDiscount: _string(json['total_discount'], '0'),
      totalBalance: _string(json['total_balance'], '0'),
      cashCount: _int(json['cash_count']) ?? 0,
      cardCount: _int(json['card_count']) ?? 0,
      onlineCount: _int(json['online_count']) ?? 0,
      unpaidCount: _int(json['unpaid_count']) ?? 0,
      paidCount: _int(json['paid_count']) ?? 0,
      totalCount: _int(json['total_count']) ?? 0,
      unpaidAmount: _string(json['unpaid_amount'], '0'),
      remarks: json['remarks']?.toString() ?? '',
      serviceAdditionalAmount: _string(json['service_additional_amount'], '0'),
      packageAdditionalAmount: _string(json['package_additional_amount'], '0'),
      totalAdditionalAmount: _string(json['total_additional_amount'], '0'),
      topServiceName: _objectName(json['top_service']),
      topProductName: _objectName(json['top_product']),
      topPackageName: _objectName(json['top_package']),
    );
  }

  /// Local optimistic copy after a successful status update.
  DailyClosingModel copyWith({String? status, DailyClosingModel? detail}) {
    final d = detail ?? this;
    return DailyClosingModel(
      id: id,
      status: status ?? this.status,
      closingDate: closingDate,
      branchId: branchId,
      createdBy: createdBy,
      approvedBy: d.approvedBy,
      openingBalance: openingBalance,
      branch: branch,
      creator: creator,
      approver: d.approver,
      totalServicesSold: d.totalServicesSold,
      serviceRevenue: d.serviceRevenue,
      totalProductsSold: d.totalProductsSold,
      productRevenue: d.productRevenue,
      totalPackagesSold: d.totalPackagesSold,
      packageRevenue: d.packageRevenue,
      totalCustomers: d.totalCustomers,
      guestBookingCount: d.guestBookingCount,
      totalBookings: d.totalBookings,
      repeatCustomers: d.repeatCustomers,
      staffCommissionTotal: d.staffCommissionTotal,
      cancelledBookings: d.cancelledBookings,
      cashPayment: d.cashPayment,
      cardPayment: d.cardPayment,
      onlinePayment: d.onlinePayment,
      returnPayment: d.returnPayment,
      totalExpense: d.totalExpense,
      totalRevenue: d.totalRevenue,
      totalAmount: d.totalAmount,
      totalDiscount: d.totalDiscount,
      totalBalance: d.totalBalance,
      cashCount: d.cashCount,
      cardCount: d.cardCount,
      onlineCount: d.onlineCount,
      unpaidCount: d.unpaidCount,
      paidCount: d.paidCount,
      totalCount: d.totalCount,
      unpaidAmount: d.unpaidAmount,
      remarks: d.remarks,
      serviceAdditionalAmount: d.serviceAdditionalAmount,
      packageAdditionalAmount: d.packageAdditionalAmount,
      totalAdditionalAmount: d.totalAdditionalAmount,
      topServiceName: d.topServiceName,
      topProductName: d.topProductName,
      topPackageName: d.topPackageName,
    );
  }

  String get currencySymbol => branch?.currencySymbol ?? '';
  String get branchName => branch?.name ?? '';
  String get creatorName => creator?.name ?? '';
  String get approverName => approver?.name ?? '';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isPending => status.toLowerCase() == 'pending';

  double get openingBalanceValue =>
      double.tryParse(openingBalance.replaceAll(',', '')) ?? 0;
}

/// `today` block — present on both the list response and `/today`.
class TodayClosing {
  final bool exists;
  final int? id;
  final String status;
  final String openingBalance;

  const TodayClosing({
    this.exists = false,
    this.id,
    this.status = '',
    this.openingBalance = '0',
  });

  factory TodayClosing.fromJson(Map<String, dynamic> json) {
    final id = _int(json['id']);
    final hasId = id != null && id > 0;
    final explicit = json['exists'];
    final exists = explicit is bool ? explicit : hasId;
    return TodayClosing(
      exists: exists && (explicit is bool || hasId),
      id: id,
      status: json['status']?.toString() ?? '',
      openingBalance: _string(json['opening_balance'], '0'),
    );
  }

  double get openingBalanceValue =>
      double.tryParse(openingBalance.replaceAll(',', '')) ?? 0;
}

/// Paginated list payload.
class DailyClosingsPage {
  final List<DailyClosingModel> items;
  final PaginationMeta meta;
  final TodayClosing? today;
  final int? branchId;

  const DailyClosingsPage({
    required this.items,
    required this.meta,
    this.today,
    this.branchId,
  });
}

/// Minimal property bag for the detail screen's raw list sections.
///
/// Bookings / payments / staff commissions / summaries come back as
/// backend-specific objects; rendering them generically keeps the screen
/// resilient to shape changes instead of hard-coding every key.
class RawSection {
  final List<Map<String, dynamic>> items;
  final PaginationMeta meta;

  const RawSection({this.items = const [], required this.meta});

  static const empty = RawSection(
    meta: PaginationMeta(currentPage: 1, lastPage: 1, total: 0, perPage: 10),
  );
}

/// Per-section page size used when the detail endpoint paginates each tab.
class RawPage {
  final List<Map<String, dynamic>> items;
  final PaginationMeta meta;

  const RawPage({required this.items, required this.meta});
}

/// Extra activity entry (timeline tab).
class ClosingActivity {
  final int id;
  final String comment;
  final String createdAt;
  final ClosingUser? user;

  const ClosingActivity({
    required this.id,
    this.comment = '',
    this.createdAt = '',
    this.user,
  });

  factory ClosingActivity.fromJson(Map<String, dynamic> json) =>
      ClosingActivity(
        id: _int(json['id']) ?? 0,
        comment: json['comment']?.toString() ?? '',
        createdAt: json['created_at']?.toString() ?? '',
        user: json['user'] is Map
            ? ClosingUser.fromJson(
                Map<String, dynamic>.from(json['user'] as Map),
              )
            : null,
      );
}

/// Full `GET /daily-closings/{id}` payload.
class DailyClosingDetail {
  final DailyClosingModel closing;
  final List<ClosingActivity> activities;
  final RawSection bookings;
  final RawSection payments;
  final RawSection staffCommissions;
  final RawSection expenses;
  final RawSection serviceSummary;
  final RawSection productSummary;
  final RawSection packageSummary;
  final RawSection cashFlow;
  final String cashIn;
  final String cashOut;
  final String cashNet;

  const DailyClosingDetail({
    required this.closing,
    this.activities = const [],
    this.bookings = RawSection.empty,
    this.payments = RawSection.empty,
    this.staffCommissions = RawSection.empty,
    this.expenses = RawSection.empty,
    this.serviceSummary = RawSection.empty,
    this.productSummary = RawSection.empty,
    this.packageSummary = RawSection.empty,
    this.cashFlow = RawSection.empty,
    this.cashIn = '0',
    this.cashOut = '0',
    this.cashNet = '0',
  });
}

// ─── Parsing helpers ────────────────────────────────────────────────────────

int? closingInt(dynamic v) => _int(v);
String closingString(dynamic v, [String fallback = '']) => _string(v, fallback);

int? _int(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

String _string(dynamic v, String fallback) {
  if (v == null) return fallback;
  final s = v.toString().trim();
  return s.isEmpty ? fallback : s;
}

String _objectName(dynamic v) {
  if (v is Map) return v['name']?.toString() ?? '';
  if (v is String) return v;
  return '';
}

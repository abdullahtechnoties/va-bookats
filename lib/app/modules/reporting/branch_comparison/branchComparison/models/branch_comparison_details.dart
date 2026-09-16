import 'package:va_bookats/network/response/pagination_helper.dart';

class BranchComparisonDetailsModel {
  final BranchInfoModel branch;
  final String fromDate;
  final String toDate;
  final PaginatedResult<DailyClosingModel> dailyClosings;

  BranchComparisonDetailsModel({
    required this.branch,
    required this.fromDate,
    required this.toDate,
    required this.dailyClosings,
  });

  factory BranchComparisonDetailsModel.fromJson(Map<String, dynamic> json) {
    final closingsJson = json['dailyClosings'] as Map<String, dynamic>? ?? {};
    final closingsData = (closingsJson['data'] as List?)
            ?.map((e) => DailyClosingModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return BranchComparisonDetailsModel(
      branch: BranchInfoModel.fromJson(json['branch'] as Map<String, dynamic>? ?? {}),
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      dailyClosings: PaginatedResult(
        items: closingsData,
        meta: PaginationMeta.fromJson(closingsJson),
      ),
    );
  }
}

class BranchInfoModel {
  final int id;
  final String name;
  final String? emailPrimary;
  final String? emailSecondary;
  final String? phonePrimary;
  final String? phoneSecondary;
  final String? address;
  final String? zipCode;
  final String status;

  BranchInfoModel({
    required this.id,
    required this.name,
    this.emailPrimary,
    this.emailSecondary,
    this.phonePrimary,
    this.phoneSecondary,
    this.address,
    this.zipCode,
    required this.status,
  });

  factory BranchInfoModel.fromJson(Map<String, dynamic> json) {
    return BranchInfoModel(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      emailPrimary: json['email_primary']?.toString(),
      emailSecondary: json['email_secondary']?.toString(),
      phonePrimary: json['phone_primary']?.toString(),
      phoneSecondary: json['phone_secondary']?.toString(),
      address: json['address']?.toString(),
      zipCode: json['zip_code']?.toString(),
      status: json['status']?.toString() ?? 'active',
    );
  }
}

class DailyClosingModel {
  final int id;
  final int branchId;
  final String closingDate;
  final int totalCustomers;
  final int totalBookings;
  final int totalServicesSold;
  final String serviceAmount;
  final String serviceDiscount;
  final String serviceRevenue;
  final int totalProductsSold;
  final String productAmount;
  final String productDiscount;
  final String productRevenue;
  final int repeatCustomers;
  final String staffCommissionTotal;
  final int totalPackagesSold;
  final String packageAmount;
  final String packageDiscount;
  final String packageRevenue;
  final String cashPayment;
  final String cardPayment;
  final String onlinePayment;
  final String returnPayment;
  final int returnPaymentCount;
  final int cashCount;
  final int cardCount;
  final int onlineCount;
  final int unpaidCount;
  final int paidCount;
  final int totalCount;
  final String unpaidAmount;
  final String guestBookingCount;
  final String totalExpense;
  final String totalRevenue;
  final String totalAmount;
  final String totalDiscount;
  final String totalBalance;
  final int cancelledBookings;
  final String openingBalance;
  final String? remarks;
  final String status;
  final StaffModel? creator;
  final StaffModel? approver;

  DailyClosingModel({
    required this.id,
    required this.branchId,
    required this.closingDate,
    required this.totalCustomers,
    required this.totalBookings,
    required this.totalServicesSold,
    required this.serviceAmount,
    required this.serviceDiscount,
    required this.serviceRevenue,
    required this.totalProductsSold,
    required this.productAmount,
    required this.productDiscount,
    required this.productRevenue,
    required this.repeatCustomers,
    required this.staffCommissionTotal,
    required this.totalPackagesSold,
    required this.packageAmount,
    required this.packageDiscount,
    required this.packageRevenue,
    required this.cashPayment,
    required this.cardPayment,
    required this.onlinePayment,
    required this.returnPayment,
    required this.returnPaymentCount,
    required this.cashCount,
    required this.cardCount,
    required this.onlineCount,
    required this.unpaidCount,
    required this.paidCount,
    required this.totalCount,
    required this.unpaidAmount,
    required this.guestBookingCount,
    required this.totalExpense,
    required this.totalRevenue,
    required this.totalAmount,
    required this.totalDiscount,
    required this.totalBalance,
    required this.cancelledBookings,
    required this.openingBalance,
    this.remarks,
    required this.status,
    this.creator,
    this.approver,
  });

  factory DailyClosingModel.fromJson(Map<String, dynamic> json) {
    return DailyClosingModel(
      id: json['id'] as int? ?? 0,
      branchId: json['branch_id'] as int? ?? 0,
      closingDate: json['closing_date']?.toString() ?? '',
      totalCustomers: json['total_customers'] as int? ?? 0,
      totalBookings: json['total_bookings'] as int? ?? 0,
      totalServicesSold: json['total_services_sold'] as int? ?? 0,
      serviceAmount: json['service_amount']?.toString() ?? '0.00',
      serviceDiscount: json['service_discount']?.toString() ?? '0.00',
      serviceRevenue: json['service_revenue']?.toString() ?? '0.00',
      totalProductsSold: json['total_products_sold'] as int? ?? 0,
      productAmount: json['product_amount']?.toString() ?? '0.00',
      productDiscount: json['product_discount']?.toString() ?? '0.00',
      productRevenue: json['product_revenue']?.toString() ?? '0.00',
      repeatCustomers: json['repeat_customers'] as int? ?? 0,
      staffCommissionTotal: json['staff_commission_total']?.toString() ?? '0.00',
      totalPackagesSold: json['total_packages_sold'] as int? ?? 0,
      packageAmount: json['package_amount']?.toString() ?? '0.00',
      packageDiscount: json['package_discount']?.toString() ?? '0.00',
      packageRevenue: json['package_revenue']?.toString() ?? '0.00',
      cashPayment: json['cash_payment']?.toString() ?? '0.00',
      cardPayment: json['card_payment']?.toString() ?? '0.00',
      onlinePayment: json['online_payment']?.toString() ?? '0.00',
      returnPayment: json['return_payment']?.toString() ?? '0.00',
      returnPaymentCount: json['return_payment_count'] as int? ?? 0,
      cashCount: json['cash_count'] as int? ?? 0,
      cardCount: json['card_count'] as int? ?? 0,
      onlineCount: json['online_count'] as int? ?? 0,
      unpaidCount: json['unpaid_count'] as int? ?? 0,
      paidCount: json['paid_count'] as int? ?? 0,
      totalCount: json['total_count'] as int? ?? 0,
      unpaidAmount: json['unpaid_amount']?.toString() ?? '0.00',
      guestBookingCount: json['guest_booking_count']?.toString() ?? '0.00',
      totalExpense: json['total_expense']?.toString() ?? '0.00',
      totalRevenue: json['total_revenue']?.toString() ?? '0.00',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      totalDiscount: json['total_discount']?.toString() ?? '0.00',
      totalBalance: json['total_balance']?.toString() ?? '0.00',
      cancelledBookings: json['cancelled_bookings'] as int? ?? 0,
      openingBalance: json['opening_balance']?.toString() ?? '0.00',
      remarks: json['remarks']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
      creator: json['creator'] != null
          ? StaffModel.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      approver: json['approver'] != null
          ? StaffModel.fromJson(json['approver'] as Map<String, dynamic>)
          : null,
    );
  }
}

class StaffModel {
  final int id;
  final String name;
  final String email;
  final String? phonePrimary;
  final String? imageUrl;

  StaffModel({
    required this.id,
    required this.name,
    required this.email,
    this.phonePrimary,
    this.imageUrl,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phonePrimary: json['phone_primary']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }
}
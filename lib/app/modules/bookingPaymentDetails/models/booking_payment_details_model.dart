// lib/app/modules/bookingPaymentDetails/models/booking_payment_details_model.dart
//
// Models for `GET /bookings/{id}/details` (optional `payment_id`,
// `payments_page`, `activities_page` query params).

import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/utilities/image_path_helper.dart';

// ─── Shared bits ─────────────────────────────────────────────────────────────

class CurrencyInfo {
  final int id;
  final String symbol;

  CurrencyInfo({required this.id, required this.symbol});

  factory CurrencyInfo.fromJson(Map<String, dynamic> json) {
    return CurrencyInfo(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      symbol: json['symbol']?.toString() ?? '',
    );
  }
}

String? _img(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  return getImage(raw);
}

// ─── Booking ─────────────────────────────────────────────────────────────────

class DetailsBranch {
  final int id;
  final String name;
  final String? emailPrimary;
  final String? phonePrimary;
  final CurrencyInfo? currency;

  DetailsBranch({
    required this.id,
    required this.name,
    this.emailPrimary,
    this.phonePrimary,
    this.currency,
  });

  factory DetailsBranch.fromJson(Map<String, dynamic> json) {
    return DetailsBranch(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      emailPrimary: json['email_primary']?.toString(),
      phonePrimary: json['phone_primary']?.toString(),
      currency: json['currency'] is Map
          ? CurrencyInfo.fromJson(
              Map<String, dynamic>.from(json['currency'] as Map),
            )
          : null,
    );
  }
}

class DetailsCustomer {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? imageUrl;
  final String? imageThumbUrl;

  DetailsCustomer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.imageUrl,
    this.imageThumbUrl,
  });

  factory DetailsCustomer.fromJson(Map<String, dynamic> json) {
    return DetailsCustomer(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone_primary']?.toString(),
      imageUrl: _img(json['image_url']?.toString()),
      imageThumbUrl: _img(json['image_thumb_url']?.toString()),
    );
  }
}

class PackageStaffEntry {
  final int staffId;
  final String staffName;

  PackageStaffEntry({required this.staffId, required this.staffName});

  factory PackageStaffEntry.fromJson(Map<String, dynamic> json) {
    final staff = json['staff'] is Map
        ? Map<String, dynamic>.from(json['staff'] as Map)
        : <String, dynamic>{};
    return PackageStaffEntry(
      staffId: int.tryParse(
            (json['staff_id'] ?? staff['id'])?.toString() ?? '0',
          ) ??
          0,
      staffName: staff['name']?.toString() ?? '',
    );
  }
}

class BookingPackageLine {
  final int id;
  final int packageId;
  final String amount;
  final String discount;
  final String totalAmount;
  final String packageName;
  final List<PackageStaffEntry> staffs;

  BookingPackageLine({
    required this.id,
    required this.packageId,
    required this.amount,
    required this.discount,
    required this.totalAmount,
    required this.packageName,
    required this.staffs,
  });

  factory BookingPackageLine.fromJson(Map<String, dynamic> json) {
    final pkg = json['package'] is Map
        ? Map<String, dynamic>.from(json['package'] as Map)
        : <String, dynamic>{};
    return BookingPackageLine(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      packageId: int.tryParse(
            (json['package_id'] ?? pkg['id'])?.toString() ?? '0',
          ) ??
          0,
      amount: json['amount']?.toString() ?? '0',
      discount: json['discount']?.toString() ?? '0',
      totalAmount: json['total_amount']?.toString() ?? '0',
      packageName: pkg['name']?.toString() ?? '',
      staffs: (json['staffs'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => PackageStaffEntry.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          [],
    );
  }
}

class BookingServiceLine {
  final int id;
  final String amount;
  final String discount;
  final String totalAmount;
  final String serviceName;
  final String categoryName;
  final String employeeName;
  final String? variationName;

  BookingServiceLine({
    required this.id,
    required this.amount,
    required this.discount,
    required this.totalAmount,
    required this.serviceName,
    required this.categoryName,
    required this.employeeName,
    this.variationName,
  });

  factory BookingServiceLine.fromJson(Map<String, dynamic> json) {
    final svc = json['service'] is Map
        ? Map<String, dynamic>.from(json['service'] as Map)
        : <String, dynamic>{};
    final cat = svc['category'] is Map
        ? Map<String, dynamic>.from(svc['category'] as Map)
        : <String, dynamic>{};
    final emp = json['employee'] is Map
        ? Map<String, dynamic>.from(json['employee'] as Map)
        : <String, dynamic>{};
    final variation = json['variation'] is Map
        ? Map<String, dynamic>.from(json['variation'] as Map)
        : null;
    return BookingServiceLine(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      amount: json['amount']?.toString() ?? '0',
      discount: json['discount']?.toString() ?? '0',
      totalAmount: json['total_amount']?.toString() ?? '0',
      serviceName: svc['name']?.toString() ?? '',
      categoryName: cat['name']?.toString() ?? '',
      employeeName: emp['name']?.toString() ?? '',
      variationName: variation?['name']?.toString(),
    );
  }
}

class BookingProductLine {
  final int id;
  final String unitPrice;
  final int quantity;
  final String totalPrice;
  final String discount;
  final String afterDiscountPrice;
  final String productName;
  final List<String> categoryNames;
  final List<String> variantNames;

  BookingProductLine({
    required this.id,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.discount,
    required this.afterDiscountPrice,
    required this.productName,
    required this.categoryNames,
    required this.variantNames,
  });

  factory BookingProductLine.fromJson(Map<String, dynamic> json) {
    final product = json['product'] is Map
        ? Map<String, dynamic>.from(json['product'] as Map)
        : <String, dynamic>{};
    final variant = json['variant'] is Map
        ? Map<String, dynamic>.from(json['variant'] as Map)
        : <String, dynamic>{};
    return BookingProductLine(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      unitPrice: json['unit_price']?.toString() ?? '0',
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      totalPrice: json['total_price']?.toString() ?? '0',
      discount: json['discount']?.toString() ?? '0',
      afterDiscountPrice: json['after_discount_price']?.toString() ?? '0',
      productName: product['name']?.toString() ?? '',
      categoryNames:
          (product['categories'] as List?)
              ?.whereType<Map>()
              .map((e) => e['name']?.toString() ?? '')
              .where((n) => n.isNotEmpty)
              .toList() ??
          [],
      variantNames:
          (variant['variation_values'] as List?)
              ?.whereType<Map>()
              .map((e) => e['name']?.toString() ?? '')
              .where((n) => n.isNotEmpty)
              .toList() ??
          [],
    );
  }
}

class BookingDetailsData {
  final int id;
  final int branchId;
  final int? customerId;
  final String bookingDate;
  final String? startTime;
  final String? endTime;
  final String totalAmount;
  final String amountPaid;
  final String discount;
  final String remainingAmount;
  final String? paymentMethod;
  final String status;
  final int bookingSerial;
  final String? guestName;
  final String? guestEmail;
  final String? guestPhone;
  final DetailsBranch? branch;
  final DetailsCustomer? customer;
  final List<BookingPackageLine> packages;
  final List<BookingServiceLine> services;
  final List<BookingProductLine> products;

  BookingDetailsData({
    required this.id,
    required this.branchId,
    this.customerId,
    required this.bookingDate,
    this.startTime,
    this.endTime,
    required this.totalAmount,
    required this.amountPaid,
    required this.discount,
    required this.remainingAmount,
    this.paymentMethod,
    required this.status,
    required this.bookingSerial,
    this.guestName,
    this.guestEmail,
    this.guestPhone,
    this.branch,
    this.customer,
    required this.packages,
    required this.services,
    required this.products,
  });

  factory BookingDetailsData.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(
      dynamic raw,
      T Function(Map<String, dynamic>) parse,
    ) {
      if (raw is! List) return <T>[];
      return raw
          .whereType<Map>()
          .map((e) => parse(Map<String, dynamic>.from(e)))
          .toList();
    }

    return BookingDetailsData(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      branchId: int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      customerId: json['customer_id'] == null
          ? null
          : int.tryParse(json['customer_id'].toString()),
      bookingDate: json['booking_date']?.toString() ?? '',
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      totalAmount: json['total_amount']?.toString() ?? '0',
      amountPaid: json['amount_paid']?.toString() ?? '0',
      discount: json['discount']?.toString() ?? '0',
      remainingAmount: json['remaining_amount']?.toString() ?? '0',
      paymentMethod: json['payment_method']?.toString(),
      status: json['status']?.toString() ?? '',
      bookingSerial: int.tryParse(json['booking_serial']?.toString() ?? '0') ?? 0,
      guestName: json['guest_name']?.toString(),
      guestEmail: json['guest_email']?.toString(),
      guestPhone: json['guest_phone']?.toString(),
      branch: json['branch'] is Map
          ? DetailsBranch.fromJson(
              Map<String, dynamic>.from(json['branch'] as Map),
            )
          : null,
      customer: json['customer'] is Map
          ? DetailsCustomer.fromJson(
              Map<String, dynamic>.from(json['customer'] as Map),
            )
          : null,
      packages: parseList(json['packages'], BookingPackageLine.fromJson),
      services: parseList(json['services'], BookingServiceLine.fromJson),
      products: parseList(json['products'], BookingProductLine.fromJson),
    );
  }

  bool get isGuest => (customerId == null && guestName != null);

  String get displayName {
    if (customer?.name.isNotEmpty == true) return customer!.name;
    if ((guestName ?? '').isNotEmpty) return guestName!;
    return '';
  }
}

/// One flattened row for the details-tab lines table.
class BookingLineItem {
  final int index;
  final String name;
  final String staff;
  final String category;
  final String variation;
  final String price;
  final String qty;
  final String total;
  final String discount;
  final String afterDiscount;

  BookingLineItem({
    required this.index,
    required this.name,
    required this.staff,
    required this.category,
    required this.variation,
    required this.price,
    required this.qty,
    required this.total,
    required this.discount,
    required this.afterDiscount,
  });
}

// ─── Activities ──────────────────────────────────────────────────────────────

class ActivityUser {
  final int id;
  final String? imageUrl;
  final String? imageThumbUrl;

  ActivityUser({required this.id, this.imageUrl, this.imageThumbUrl});

  factory ActivityUser.fromJson(Map<String, dynamic> json) {
    return ActivityUser(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      imageUrl: _img(json['image_url']?.toString()),
      imageThumbUrl: _img(json['image_thumb_url']?.toString()),
    );
  }
}

class ActivityItem {
  final int id;
  final String comment;
  final String createdAt;
  final ActivityUser? user;

  ActivityItem({
    required this.id,
    required this.comment,
    required this.createdAt,
    this.user,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      user: json['user'] is Map
          ? ActivityUser.fromJson(
              Map<String, dynamic>.from(json['user'] as Map),
            )
          : null,
    );
  }
}

// ─── Payments ────────────────────────────────────────────────────────────────

class PaymentEntry {
  final int id;
  final int bookingId;
  final int branchId;
  final String totalAmount;
  final String discountAmount;
  final String paidAmount;
  final String balance;
  final String status;
  final String? paymentMethod;
  final String date;
  final String? slipUrl;
  final String? slipThumbUrl;
  final CurrencyInfo? currency;

  PaymentEntry({
    required this.id,
    required this.bookingId,
    required this.branchId,
    required this.totalAmount,
    required this.discountAmount,
    required this.paidAmount,
    required this.balance,
    required this.status,
    this.paymentMethod,
    required this.date,
    this.slipUrl,
    this.slipThumbUrl,
    this.currency,
  });

  factory PaymentEntry.fromJson(Map<String, dynamic> json) {
    final branch = json['branch'] is Map
        ? Map<String, dynamic>.from(json['branch'] as Map)
        : <String, dynamic>{};
    final currency = branch['currency'] is Map
        ? Map<String, dynamic>.from(branch['currency'] as Map)
        : null;
    return PaymentEntry(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      bookingId: int.tryParse(json['booking_id']?.toString() ?? '0') ?? 0,
      branchId: int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      totalAmount: json['total_amount']?.toString() ?? '0',
      discountAmount: json['discount_amount']?.toString() ?? '0',
      paidAmount: json['paid_amount']?.toString() ?? '0',
      balance: json['balance']?.toString() ?? '0',
      status: json['status']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString(),
      date: json['date']?.toString() ?? '',
      slipUrl: _img(json['payment_slip_url']?.toString()),
      slipThumbUrl: _img(json['payment_slip_thumb_url']?.toString()),
      currency: currency != null ? CurrencyInfo.fromJson(currency) : null,
    );
  }

  bool get isPaid => status.trim().toLowerCase() == 'paid';
}

// ─── Edit data (present when `payment_id` is sent) ───────────────────────────

class PaymentMediaItem {
  final int id;
  final String fileName;
  final String? url;
  final String? thumbnailUrl;

  PaymentMediaItem({
    required this.id,
    required this.fileName,
    this.url,
    this.thumbnailUrl,
  });

  factory PaymentMediaItem.fromJson(Map<String, dynamic> json) {
    return PaymentMediaItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fileName: json['file_name']?.toString() ?? '',
      url: _img(json['url']?.toString()),
      thumbnailUrl: _img(json['thumbnail_url']?.toString()),
    );
  }
}

class PaymentEditData {
  final int id;
  final int branchId;
  final int? customerId;
  final int bookingId;
  final String? transactionId;
  final String totalAmount;
  final String paidAmount;
  final String balance;
  final String date;
  final String status;
  final String discountAmount;
  final String? paymentMethod;
  final String? slipUrl;
  final String? slipThumbUrl;
  final List<PaymentMediaItem> media;

  PaymentEditData({
    required this.id,
    required this.branchId,
    this.customerId,
    required this.bookingId,
    this.transactionId,
    required this.totalAmount,
    required this.paidAmount,
    required this.balance,
    required this.date,
    required this.status,
    required this.discountAmount,
    this.paymentMethod,
    this.slipUrl,
    this.slipThumbUrl,
    required this.media,
  });

  factory PaymentEditData.fromJson(Map<String, dynamic> json) {
    return PaymentEditData(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      branchId: int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      customerId: json['customer_id'] == null
          ? null
          : int.tryParse(json['customer_id'].toString()),
      bookingId: int.tryParse(json['booking_id']?.toString() ?? '0') ?? 0,
      transactionId: json['transaction_id']?.toString(),
      totalAmount: json['total_amount']?.toString() ?? '',
      paidAmount: json['paid_amount']?.toString() ?? '',
      balance: json['balance']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      discountAmount: json['discount_amount']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString(),
      slipUrl: _img(json['payment_slip_url']?.toString()),
      slipThumbUrl: _img(json['payment_slip_thumb_url']?.toString()),
      media: (json['media'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => PaymentMediaItem.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          [],
    );
  }
}

// ─── Root ────────────────────────────────────────────────────────────────────

class BookingPaymentDetailsResponse {
  final BookingDetailsData booking;
  final PaginatedResult<ActivityItem> activities;
  final PaginatedResult<PaymentEntry> payments;
  final PaymentEditData? editData;

  BookingPaymentDetailsResponse({
    required this.booking,
    required this.activities,
    required this.payments,
    this.editData,
  });

  factory BookingPaymentDetailsResponse.fromJson(Map<String, dynamic> json) {
    List<T> parseItems<T>(
      dynamic raw,
      T Function(Map<String, dynamic>) parse,
    ) {
      final data = raw is Map ? raw['data'] : null;
      if (data is! List) return <T>[];
      return data
          .whereType<Map>()
          .map((e) => parse(Map<String, dynamic>.from(e)))
          .toList();
    }

    PaginationMeta parseMeta(dynamic raw) {
      if (raw is Map) {
        return PaginationMeta.fromJson(Map<String, dynamic>.from(raw));
      }
      return PaginationMeta(
        currentPage: 1,
        lastPage: 1,
        total: 0,
        perPage: 10,
      );
    }

    return BookingPaymentDetailsResponse(
      booking: BookingDetailsData.fromJson(
        Map<String, dynamic>.from(json['booking'] as Map? ?? {}),
      ),
      activities: PaginatedResult(
        items: parseItems(json['activities'], ActivityItem.fromJson),
        meta: parseMeta(json['activities']),
      ),
      payments: PaginatedResult(
        items: parseItems(json['payments'], PaymentEntry.fromJson),
        meta: parseMeta(json['payments']),
      ),
      editData: json['editData'] is Map
          ? PaymentEditData.fromJson(
              Map<String, dynamic>.from(json['editData'] as Map),
            )
          : null,
    );
  }
}

// lib/models/payment_model.dart

import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/models/branch_comparison_details.dart';
import 'package:va_bookats/widgets/Global-Widgets/payment_card.dart';

class PaymentCustomer {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? imageUrl;
  final String? imageThumbUrl;

  const PaymentCustomer({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.imageUrl,
    this.imageThumbUrl,
  });

  factory PaymentCustomer.fromJson(Map<String, dynamic> json) {
    return PaymentCustomer(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: (json['phone_primary'] ?? json['phone'])?.toString(),
      imageUrl: json['image_url']?.toString(),
      imageThumbUrl: json['image_thumb_url']?.toString(),
    );
  }

  String get displayImage =>
      (imageThumbUrl?.isNotEmpty == true ? imageThumbUrl! : (imageUrl ?? ''));
}

class PaymentBooking {
  final int? id;
  final int? customerId;
  final String? guestName;
  final String? guestEmail;
  final String? guestPhone;
  final PaymentCustomer? customer;

  const PaymentBooking({
    this.id,
    this.customerId,
    this.guestName,
    this.guestEmail,
    this.guestPhone,
    this.customer,
  });

  factory PaymentBooking.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? map(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v) : null;
    final customerJson = map(json['customer']);
    return PaymentBooking(
      id: _parseInt(json['id']),
      customerId: _parseInt(json['customer_id']),
      guestName: json['guest_name']?.toString(),
      guestEmail: json['guest_email']?.toString(),
      guestPhone: json['guest_phone']?.toString(),
      customer: customerJson == null
          ? null
          : PaymentCustomer.fromJson(customerJson),
    );
  }

  bool get isGuest => customer == null;

  String get displayName {
    if (!isGuest && (customer?.name ?? '').isNotEmpty) {
      return customer!.name!;
    }
    if ((guestName ?? '').isNotEmpty) return guestName!;
    return '—';
  }
}

class PaymentBranch {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;

  const PaymentBranch({this.id, this.name, this.email, this.phone});

  factory PaymentBranch.fromJson(Map<String, dynamic> json) {
    return PaymentBranch(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      email: (json['email_primary'] ?? json['email'])?.toString(),
      phone: (json['phone_primary'] ?? json['phone'])?.toString(),
    );
  }
}

class PaymentModel {
  final int id;
  final int? bookingId;
  final int? branchId;
  final int? customerId;
  final String? transactionId;
  final String? totalAmount;
  final String? paidAmount;
  final String? balance;
  final String? discountAmount;
  final String? paymentMethod;
  final String? date;
  final String status;
  final String? createdAt;
  final String? slipUrl;
  final String? slipThumbUrl;
  final PaymentBranch? branch;
  final ClosingBranchModel? branchh;
  final PaymentBooking? booking;

  const PaymentModel({
    required this.id,
    this.bookingId,
    this.branchId,
    this.customerId,
    this.transactionId,
    this.totalAmount,
    this.paidAmount,
    this.balance,
    this.discountAmount,
    this.paymentMethod,
    this.date,
    required this.status,
    this.createdAt,
    this.slipUrl,
    this.slipThumbUrl,
    this.branch,
    this.booking,
    this.branchh,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? map(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v) : null;
    final branchJson = map(json['branch']);
    final bookingJson = map(json['booking']);
    return PaymentModel(
      id: _parseInt(json['id']) ?? 0,
      bookingId: _parseInt(json['booking_id']),
      branchId: _parseInt(json['branch_id']),
      customerId: _parseInt(json['customer_id']),
      transactionId: json['transaction_id']?.toString(),
      totalAmount: json['total_amount']?.toString(),
      paidAmount: (json['paid_amount'] ?? json['amount_paid'])?.toString(),
      balance: json['balance']?.toString(),
      discountAmount: (json['discount_amount'] ?? json['discount'])?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      date: json['date']?.toString(),
      status: json['status']?.toString() ?? 'Unpaid',
      createdAt: json['created_at']?.toString(),
      slipUrl: json['payment_slip_url']?.toString(),
      slipThumbUrl: json['payment_slip_thumb_url']?.toString(),
      branch: branchJson == null ? null : PaymentBranch.fromJson(branchJson),
      booking: bookingJson == null
          ? null
          : PaymentBooking.fromJson(bookingJson),
      branchh: json['branch'] != null
          ? ClosingBranchModel.fromJson(
              json['branch'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  String get slipDisplayUrl =>
      (slipThumbUrl?.isNotEmpty == true ? slipThumbUrl! : (slipUrl ?? ''));

  bool get hasSlip => slipDisplayUrl.isNotEmpty;

  /// Maps onto the existing payment card (guest-safe fallbacks).
  PaymentCardModel toCardModel() {
    final booking = this.booking;
    final customer = booking?.customer;
    return PaymentCardModel(
      grandTotal: totalAmount ?? '0.00',
      status: status,
      customerName: booking?.displayName ?? '—',
      customerEmail: customer?.email ?? booking?.guestEmail ?? '—',
      customerPhone: customer?.phone ?? booking?.guestPhone ?? '—',
      branch: branch?.name ?? '—',
      total: totalAmount ?? '0.00',
      paid: paidAmount ?? '0.00',
      remaining: balance ?? '0.00',
    );
  }
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

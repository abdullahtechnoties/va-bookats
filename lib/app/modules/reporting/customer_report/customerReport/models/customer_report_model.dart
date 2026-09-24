// lib/models/customer_report_model.dart

import 'package:va_bookats/network/response/pagination_helper.dart';

class BranchOption {
  final String label;
  final int value;

  BranchOption({required this.label, required this.value});

  factory BranchOption.fromJson(Map<String, dynamic> json) {
    return BranchOption(
      label: json['label']?.toString() ?? '',
      value: int.tryParse(json['value'].toString()) ?? 0,
    );
  }
}

class CustomerOption {
  final String label;
  final dynamic value; // can be "all" or int

  CustomerOption({required this.label, required this.value});

  factory CustomerOption.fromJson(Map<String, dynamic> json) {
    return CustomerOption(
      label: json['label']?.toString() ?? '',
      value: json['value'], // keep as dynamic
    );
  }

  bool get isAll => value.toString().toLowerCase() == 'all';
}

class CustomerReportData {
  final String branchName;
  final String from;
  final String to;
  final dynamic customerId;
  final int branchId;
  final String totalAmount;
  final String totalDiscount;
  final String netRevenue;
  final String remainingAmount;
  final int totalBookings;
  final int completedBookings;
  final int pendingBookings;
  final int cancelledBookings;

  CustomerReportData({
    required this.branchName,
    required this.from,
    required this.to,
    required this.customerId,
    required this.branchId,
    required this.totalAmount,
    required this.totalDiscount,
    required this.netRevenue,
    required this.remainingAmount,
    required this.totalBookings,
    required this.completedBookings,
    required this.pendingBookings,
    required this.cancelledBookings,
  });

  factory CustomerReportData.fromJson(Map<String, dynamic> json) {
    return CustomerReportData(
      branchName: json['branch_name']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      customerId: json['customer_id'],
      branchId: int.tryParse(json['branch_id'].toString()) ?? 0,
      totalAmount: json['total_amount']?.toString() ?? '0',
      totalDiscount: json['total_discount']?.toString() ?? '0',
      netRevenue: json['net_revenue']?.toString() ?? '0',
      remainingAmount: json['remaining_amount']?.toString() ?? '0',
      totalBookings: int.tryParse(json['total_bookings'].toString()) ?? 0,
      completedBookings:
          int.tryParse(json['completed_bookings'].toString()) ?? 0,
      pendingBookings: int.tryParse(json['pending_bookings'].toString()) ?? 0,
      cancelledBookings:
          int.tryParse(json['cancelled_bookings'].toString()) ?? 0,
    );
  }
}

class CustomerReportResponse {
  final List<BranchOption> branches;
  final int branchId;
  final String fromDate;
  final String toDate;
  final List<CustomerReportData> monthlyData;
  final List<CustomerOption> customers;
  final dynamic customerId;

  CustomerReportResponse({
    required this.branches,
    required this.branchId,
    required this.fromDate,
    required this.toDate,
    required this.monthlyData,
    required this.customers,
    required this.customerId,
  });

  factory CustomerReportResponse.fromJson(Map<String, dynamic> json) {
    return CustomerReportResponse(
      branches:
          (json['branches'] as List?)
              ?.map((e) => BranchOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      branchId: int.tryParse(json['branch_id'].toString()) ?? 0,
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      monthlyData:
          (json['monthlyData'] as List?)
              ?.map(
                (e) => CustomerReportData.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      customers:
          (json['customers'] as List?)
              ?.map((e) => CustomerOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      customerId: json['customer_id'],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Customer Details Models
// ═══════════════════════════════════════════════════════════════════════════

class BranchDetails {
  final int id;
  final String name;
  final String? emailPrimary;
  final String? phonePrimary;
  final String? address;

  BranchDetails({
    required this.id,
    required this.name,
    this.emailPrimary,
    this.phonePrimary,
    this.address,
  });

  factory BranchDetails.fromJson(Map<String, dynamic> json) {
    return BranchDetails(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      emailPrimary: json['email_primary']?.toString(),
      phonePrimary: json['phone_primary']?.toString(),
      address: json['address']?.toString(),
    );
  }
}

class BookingCustomer {
  final int id;
  final String name;
  final String? email;
  final String? phonePrimary;
  final String? gender;

  BookingCustomer({
    required this.id,
    required this.name,
    this.email,
    this.phonePrimary,
    this.gender,
  });

  factory BookingCustomer.fromJson(Map<String, dynamic> json) {
    return BookingCustomer(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phonePrimary: json['phone_primary']?.toString(),
      gender: json['gender']?.toString(),
    );
  }
}

class BookingData {
  final int id;
  final int customerId;
  final String bookingType;
  final String bookingDate;
  final String source;
  final String startTime;
  final String endTime;
  final int bookingSerial;
  final String totalAmount;
  final String amountPaid;
  final String discount;
  final String remainingAmount;
  final String paymentMethod;
  final String status;
  final String? note;
  final int branchId;
  final BookingCustomer? customer;

  BookingData({
    required this.id,
    required this.customerId,
    required this.bookingType,
    required this.bookingDate,
    required this.source,
    required this.startTime,
    required this.endTime,
    required this.bookingSerial,
    required this.totalAmount,
    required this.amountPaid,
    required this.discount,
    required this.remainingAmount,
    required this.paymentMethod,
    required this.status,
    this.note,
    required this.branchId,
    this.customer,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      id: int.tryParse(json['id'].toString()) ?? 0,
      customerId: int.tryParse(json['customer_id'].toString()) ?? 0,
      bookingType: json['booking_type']?.toString() ?? '',
      bookingDate: json['booking_date']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      bookingSerial: int.tryParse(json['booking_serial'].toString()) ?? 0,
      totalAmount: json['total_amount']?.toString() ?? '0',
      amountPaid: json['amount_paid']?.toString() ?? '0',
      discount: json['discount']?.toString() ?? '0',
      remainingAmount: json['remaining_amount']?.toString() ?? '0',
      paymentMethod: json['payment_method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString(),
      branchId: int.tryParse(json['branch_id'].toString()) ?? 0,
      customer: json['customer'] != null
          ? BookingCustomer.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
}

class CustomerDetailsResponse {
  final BranchDetails branch;
  final String fromDate;
  final String toDate;
  final String customerName;
  final List<BookingData> bookings;
  final PaginationMeta paginationMeta;
  final dynamic customerId;

  CustomerDetailsResponse({
    required this.branch,
    required this.fromDate,
    required this.toDate,
    required this.customerName,
    required this.bookings,
    required this.paginationMeta,
    required this.customerId,
  });

  factory CustomerDetailsResponse.fromJson(Map<String, dynamic> json) {
    final bookingsJson = json['bookings'] as Map<String, dynamic>? ?? {};
    final bookingsData =
        (bookingsJson['data'] as List?)
            ?.map((e) => BookingData.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return CustomerDetailsResponse(
      branch: BranchDetails.fromJson(
        json['branch'] as Map<String, dynamic>? ?? {},
      ),
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      bookings: bookingsData,
      paginationMeta: PaginationMeta.fromJson(bookingsJson),
      customerId: json['customer_id'],
    );
  }
}

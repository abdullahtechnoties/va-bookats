class PaymentItem {
  final int id;
  final int branchId;
  final int? customerId;
  final int bookingId;
  final String? transactionId;
  final double totalAmount;
  final double paidAmount;
  final double balance;
  final String date;
  final String status;
  final double discountAmount;
  final String? paymentMethod;
  final String? paymentSlipUrl;
  final BookingInfo? booking;

  PaymentItem({
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
    this.paymentSlipUrl,
    this.booking,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['id'] ?? 0,
      branchId: json['branch_id'] ?? 0,
      customerId: json['customer_id'],
      bookingId: json['booking_id'] ?? 0,
      transactionId: json['transaction_id'],
      totalAmount: _parseDouble(json['total_amount']),
      paidAmount: _parseDouble(json['paid_amount']),
      balance: _parseDouble(json['balance']),
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      discountAmount: _parseDouble(json['discount_amount']),
      paymentMethod: json['payment_method'],
      paymentSlipUrl: json['payment_slip_url'],
      booking: json['booking'] != null
          ? BookingInfo.fromJson(json['booking'])
          : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class BookingInfo {
  final int id;
  final String? customerName;
  final String? guestName;
  final String? guestEmail;
  final String? guestPhone;
  final String bookingType;
  final String bookingDate;
  final String source;
  final String startTime;
  final String endTime;
  final int bookingSerial;
  final String status;

  BookingInfo({
    required this.id,
    this.customerName,
    this.guestName,
    this.guestEmail,
    this.guestPhone,
    required this.bookingType,
    required this.bookingDate,
    required this.source,
    required this.startTime,
    required this.endTime,
    required this.bookingSerial,
    required this.status,
  });

  factory BookingInfo.fromJson(Map<String, dynamic> json) {
    String? custName;
    if (json['customer'] != null && json['customer'] is Map) {
      custName = json['customer']['name'];
    }

    return BookingInfo(
      id: json['id'] ?? 0,
      customerName: custName,
      guestName: json['guest_name'],
      guestEmail: json['guest_email'],
      guestPhone: json['guest_phone'],
      bookingType: json['booking_type']?.toString() ?? '',
      bookingDate: json['booking_date']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      bookingSerial: json['booking_serial'] ?? 0,
      status: json['status']?.toString() ?? '',
    );
  }

  String get displayName => customerName ?? guestName ?? 'N/A';
}
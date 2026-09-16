// lib/models/booking_model.dart

/// Booking statuses used by the API (capitalized by backend).
class BookingStatus {
  static const String pending = 'Pending';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';

  static const List<String> all = [pending, completed, cancelled];
}

class BookingBranch {
  final int? id;
  final String? name;
  final String? phone;
  final String? address;
  final String? latitude;
  final String? longitude;

  const BookingBranch({
    this.id,
    this.name,
    this.address,
    this.phone,
    this.latitude,
    this.longitude,
  });

  factory BookingBranch.fromJson(Map<String, dynamic> json) {
    return BookingBranch(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      phone: json['phone_primary']?.toString(),
      address: json['address']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }
}

class BookingCustomerRef {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? imageUrl;
  final String? imageThumbUrl;

  const BookingCustomerRef({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.imageUrl,
    this.imageThumbUrl,
  });

  factory BookingCustomerRef.fromJson(Map<String, dynamic> json) {
    return BookingCustomerRef(
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

class BookingServiceLine {
  final int? id;
  final int? serviceId;
  final int? variationId;
  final int? employeeId;
  final String? amount;
  final String? discount;
  final String? totalAmount;
  final String? serviceName;
  final String? variationName;
  final String? employeeName;

  const BookingServiceLine({
    this.id,
    this.serviceId,
    this.variationId,
    this.employeeId,
    this.amount,
    this.discount,
    this.totalAmount,
    this.serviceName,
    this.variationName,
    this.employeeName,
  });

  factory BookingServiceLine.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? _map(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v) : null;
    final service = _map(json['service']);
    final variation = _map(json['variation']);
    final employee = _map(json['employee']);
    return BookingServiceLine(
      id: _parseInt(json['id']),
      serviceId: _parseInt(json['service_id']),
      variationId: _parseInt(json['variation_id']),
      employeeId: _parseInt(json['employee_id']),
      amount: json['amount']?.toString(),
      discount: json['discount']?.toString(),
      totalAmount: json['total_amount']?.toString(),
      serviceName: service?['name']?.toString(),
      variationName: variation?['name']?.toString(),
      employeeName: employee?['name']?.toString(),
    );
  }
}

class BookingPackageLine {
  final int? id;
  final int? packageId;
  final String? amount;
  final String? discount;
  final String? totalAmount;
  final String? packageName;
  final List<String> staffNames;

  const BookingPackageLine({
    this.id,
    this.packageId,
    this.amount,
    this.discount,
    this.totalAmount,
    this.packageName,
    this.staffNames = const [],
  });

  factory BookingPackageLine.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? _map(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v) : null;
    final pkg = _map(json['package']);
    final staffs = <String>[];
    final rawStaffs = json['staffs'];
    if (rawStaffs is List) {
      for (final e in rawStaffs) {
        if (e is Map) {
          final m = Map<String, dynamic>.from(e);
          final staff = _map(m['staff']);
          final name = staff?['name']?.toString();
          if (name != null && name.isNotEmpty) staffs.add(name);
        }
      }
    }
    return BookingPackageLine(
      id: _parseInt(json['id']),
      packageId: _parseInt(json['package_id']),
      amount: json['amount']?.toString(),
      discount: json['discount']?.toString(),
      totalAmount: json['total_amount']?.toString(),
      packageName: pkg?['name']?.toString(),
      staffNames: staffs,
    );
  }
}

class BookingProductLine {
  final int? id;
  final int? productId;
  final int? variantId;
  final int? quantity;
  final String? unitPrice;
  final String? discount;
  final String? totalPrice;
  final String? afterDiscountPrice;
  final String? productName;
  final String? variantName;

  const BookingProductLine({
    this.id,
    this.productId,
    this.variantId,
    this.quantity,
    this.unitPrice,
    this.discount,
    this.totalPrice,
    this.afterDiscountPrice,
    this.productName,
    this.variantName,
  });

  factory BookingProductLine.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? _map(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v) : null;
    final product = _map(json['product']);
    final variant = _map(json['variant']);
    String? variantLabel;
    if (variant != null) {
      final values = variant['variation_values'];
      if (values is List && values.isNotEmpty) {
        final names = <String>[];
        for (final e in values) {
          if (e is Map) {
            final m = Map<String, dynamic>.from(e);
            final n = m['name']?.toString();
            if (n != null && n.isNotEmpty) names.add(n);
          }
        }
        if (names.isNotEmpty) variantLabel = names.join(', ');
      }
    }
    return BookingProductLine(
      id: _parseInt(json['id']),
      productId: _parseInt(json['product_id']),
      variantId: _parseInt(json['product_variant_id']),
      quantity: _parseInt(json['quantity']),
      unitPrice: json['unit_price']?.toString(),
      discount: json['discount']?.toString(),
      totalPrice: json['total_price']?.toString(),
      afterDiscountPrice: json['after_discount_price']?.toString(),
      productName: product?['name']?.toString(),
      variantName: variantLabel,
    );
  }
}

class BookingPayment {
  final int? id;
  final String? totalAmount;
  final String? paidAmount;
  final String? balance;
  final String? discountAmount;
  final String? status;
  final String? paymentMethod;
  final String? transactionId;
  final String? date;
  final String? slipUrl;
  final String? slipThumbUrl;

  const BookingPayment({
    this.id,
    this.totalAmount,
    this.paidAmount,
    this.balance,
    this.discountAmount,
    this.status,
    this.paymentMethod,
    this.transactionId,
    this.date,
    this.slipUrl,
    this.slipThumbUrl,
  });

  factory BookingPayment.fromJson(Map<String, dynamic> json) {
    return BookingPayment(
      id: _parseInt(json['id']),
      totalAmount: json['total_amount']?.toString(),
      paidAmount:
          (json['paid_amount'] ?? json['amount_paid'])?.toString(),
      balance: json['balance']?.toString(),
      discountAmount:
          (json['discount_amount'] ?? json['discount'])?.toString(),
      status: json['status']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      date: json['date']?.toString(),
      slipUrl: json['payment_slip_url']?.toString(),
      slipThumbUrl: json['payment_slip_thumb_url']?.toString(),
    );
  }
}

class BookingModel {
  final int id;
  final int? serial;
  final int? branchId;
  final String? bookingDate;
  final String? startTime;
  final String? endTime;
  final String? totalAmount;
  final String? amountPaid;
  final String? discount;
  final String? remainingAmount;
  final String? paymentMethod;
  final String? transactionId;
  final String status;
  final String? bookingType;
  final int? customerId;
  final String? guestName;
  final String? guestEmail;
  final String? guestPhone;
  final String? note;
  final String? source;
  final String? createdAt;
  final BookingBranch? branch;
  final BookingCustomerRef? customer;
  final List<BookingServiceLine> services;
  final List<BookingPackageLine> packages;
  final List<BookingProductLine> products;
  final BookingPayment? payment;

  const BookingModel({
    required this.id,
    this.serial,
    this.branchId,
    this.bookingDate,
    this.startTime,
    this.endTime,
    this.totalAmount,
    this.amountPaid,
    this.discount,
    this.remainingAmount,
    this.paymentMethod,
    this.transactionId,
    required this.status,
    this.bookingType,
    this.customerId,
    this.guestName,
    this.guestEmail,
    this.guestPhone,
    this.note,
    this.source,
    this.createdAt,
    this.branch,
    this.customer,
    this.services = const [],
    this.packages = const [],
    this.products = const [],
    this.payment,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? _map(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v) : null;
    List<T> _list<T>(
        dynamic v, T Function(Map<String, dynamic>) f) {
      if (v is! List) return <T>[];
      return v
          .whereType<Map>()
          .map((e) => f(Map<String, dynamic>.from(e)))
          .toList();
    }

    return BookingModel(
      id: _parseInt(json['id']) ?? 0,
      serial: _parseInt(json['booking_serial']),
      branchId: _parseInt(json['branch_id']),
      bookingDate: json['booking_date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      totalAmount: json['total_amount']?.toString(),
      amountPaid:
          (json['amount_paid'] ?? json['paid_amount'])?.toString(),
      discount: json['discount']?.toString(),
      remainingAmount: (json['remaining_amount'] ?? json['balance'])
          ?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      status: json['status']?.toString() ?? BookingStatus.pending,
      bookingType: json['booking_type']?.toString(),
      customerId: _parseInt(json['customer_id']),
      guestName: json['guest_name']?.toString(),
      guestEmail: json['guest_email']?.toString(),
      guestPhone: json['guest_phone']?.toString(),
      note: json['note']?.toString(),
      source: json['source']?.toString(),
      createdAt: json['created_at']?.toString(),
      branch: _map(json['branch']) == null
          ? null
          : BookingBranch.fromJson(_map(json['branch'])!),
      customer: _map(json['customer']) == null
          ? null
          : BookingCustomerRef.fromJson(_map(json['customer'])!),
      services: _list(json['services'], BookingServiceLine.fromJson),
      packages: _list(json['packages'], BookingPackageLine.fromJson),
      products: _list(json['products'], BookingProductLine.fromJson),
      payment: _map(json['payment']) == null
          ? null
          : BookingPayment.fromJson(_map(json['payment'])!),
    );
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isEditable => isPending;

  bool get isGuest =>
      (bookingType ?? '').toLowerCase() == 'guest' || customer == null;

  String get displayName {
    if (!isGuest && (customer?.name ?? '').isNotEmpty) {
      return customer!.name!;
    }
    if ((guestName ?? '').isNotEmpty) return guestName!;
    return '—';
  }

  String get displayImage => customer?.displayImage ?? '';

  String get displayLocation => branch?.name ?? '';

  /// Service/package/product names for the card's services line.
  List<String> get serviceNames {
    final names = <String>[];
    for (final s in services) {
      if ((s.serviceName ?? '').isNotEmpty) names.add(s.serviceName!);
    }
    for (final p in packages) {
      if ((p.packageName ?? '').isNotEmpty) names.add(p.packageName!);
    }
    for (final p in products) {
      if ((p.productName ?? '').isNotEmpty) names.add(p.productName!);
    }
    return names;
  }

  String get dateTimeLabel {
    final d = _prettyDate(bookingDate);
    final t = _prettyTime(startTime);
    if (d.isEmpty) return createdAt ?? '';
    return t.isEmpty ? d : '$d | $t';
  }

  String get dateLabel {
    final d = _prettyDate(bookingDate);
    final t = _prettyTime(startTime);
    return t.isEmpty ? d : '$d | $t';
  }

  BookingModel copyWith({String? status}) {
    return BookingModel(
      id: id,
      serial: serial,
      branchId: branchId,
      bookingDate: bookingDate,
      startTime: startTime,
      endTime: endTime,
      totalAmount: totalAmount,
      amountPaid: amountPaid,
      discount: discount,
      remainingAmount: remainingAmount,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      status: status ?? this.status,
      bookingType: bookingType,
      customerId: customerId,
      guestName: guestName,
      guestEmail: guestEmail,
      guestPhone: guestPhone,
      note: note,
      source: source,
      createdAt: createdAt,
      branch: branch,
      customer: customer,
      services: services,
      packages: packages,
      products: products,
      payment: payment,
    );
  }

  static String _prettyDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  static String _prettyTime(String? t) {
    if (t == null || t.isEmpty) return '';
    try {
      final parts = t.split(':');
      var h = int.parse(parts[0]);
      final m = parts.length > 1 ? parts[1] : '00';
      final suffix = h >= 12 ? 'PM' : 'AM';
      h = h % 12;
      if (h == 0) h = 12;
      return '$h:$m $suffix';
    } catch (_) {
      return t;
    }
  }
}

// ─── Lookup models ───────────────────────────────────────────────────────────

class PackageLookup {
  final int value;
  final String label;
  final String cleanName;
  final String price;

  const PackageLookup({
    required this.value,
    required this.label,
    required this.cleanName,
    required this.price,
  });

  factory PackageLookup.fromJson(Map<String, dynamic> json) {
    final rawLabel = json['label']?.toString() ?? '';
    // Backend appends " - {json}" to the label; strip it for display.
    final dash = rawLabel.indexOf(' - {');
    final clean =
        dash == -1 ? rawLabel : rawLabel.substring(0, dash).trim();
    return PackageLookup(
      value: _parseInt(json['value']) ?? 0,
      label: rawLabel,
      cleanName: clean.isEmpty ? rawLabel : clean,
      price: json['price']?.toString() ?? '0',
    );
  }
}

class ServiceVariationLookup {
  final int id;
  final String name;
  final String price;

  const ServiceVariationLookup({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ServiceVariationLookup.fromJson(Map<String, dynamic> json) {
    return ServiceVariationLookup(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
    );
  }
}

class ServiceLookup {
  final int value;
  final String label;
  final String defaultPrice;
  final String type;
  final List<ServiceVariationLookup> variations;

  const ServiceLookup({
    required this.value,
    required this.label,
    required this.defaultPrice,
    required this.type,
    required this.variations,
  });

  factory ServiceLookup.fromJson(Map<String, dynamic> json) {
    final rawVar = json['variations'];
    final vars = rawVar is List
        ? rawVar
            .whereType<Map>()
            .map((e) =>
                ServiceVariationLookup.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ServiceVariationLookup>[];
    return ServiceLookup(
      value: _parseInt(json['value']) ?? 0,
      label: json['label']?.toString() ?? '',
      defaultPrice: json['default_price']?.toString() ?? '',
      type: json['type']?.toString() ?? 'normal',
      variations: vars,
    );
  }

  bool get isVariation => type.toLowerCase() == 'variation';
}

class ProductVariantLookup {
  final int id;
  final String name;
  final String price;
  final int stock;

  const ProductVariantLookup({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  factory ProductVariantLookup.fromJson(Map<String, dynamic> json) {
    return ProductVariantLookup(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      stock: _parseInt(json['stock']) ?? 0,
    );
  }

  String get displayName =>
      name.isEmpty ? 'Variant #$id' : name;
}

class ProductLookup {
  final int value;
  final String label;
  final String price;
  final int stock;
  final List<ProductVariantLookup> variants;

  const ProductLookup({
    required this.value,
    required this.label,
    required this.price,
    required this.stock,
    required this.variants,
  });

  factory ProductLookup.fromJson(Map<String, dynamic> json) {
    final rawVar = json['variants'];
    final vars = rawVar is List
        ? rawVar
            .whereType<Map>()
            .map((e) =>
                ProductVariantLookup.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ProductVariantLookup>[];
    return ProductLookup(
      value: _parseInt(json['value']) ?? 0,
      label: json['label']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      stock: _parseInt(json['stock']) ?? 0,
      variants: vars,
    );
  }

  bool get hasVariants => variants.isNotEmpty;
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';

// ─── Lookup Models ──────────────────────────────────────────────────────────

class BranchLookup {
  final String label;
  final int value;

  BranchLookup({required this.label, required this.value});

  factory BranchLookup.fromJson(Map<String, dynamic> json) {
    return BranchLookup(
      label: json['label']?.toString() ?? '',
      value: int.tryParse(json['value'].toString()) ?? 0,
    );
  }
}

class ProductLookup {
  final String label;
  final String value;

  ProductLookup({required this.label, required this.value});

  factory ProductLookup.fromJson(Map<String, dynamic> json) {
    return ProductLookup(
      label: json['label']?.toString() ?? '',
      value: json['value'].toString(),
    );
  }
}

// ─── Main Report Models ─────────────────────────────────────────────────────

class ProductRevenueData {
  final String branchName;
  final String from;
  final String to;
  final String productId;
  final int branchId;
  final double totalAmount;
  final double totalDiscount;
  final double netRevenue;

  ProductRevenueData({
    required this.branchName,
    required this.from,
    required this.to,
    required this.productId,
    required this.branchId,
    required this.totalAmount,
    required this.totalDiscount,
    required this.netRevenue,
  });

  factory ProductRevenueData.fromJson(Map<String, dynamic> json) {
    return ProductRevenueData(
      branchName: json['branch_name']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      branchId: int.tryParse(json['branch_id'].toString()) ?? 0,
      totalAmount: _parseDouble(json['total_amount']),
      totalDiscount: _parseDouble(json['total_discount']),
      netRevenue: _parseDouble(json['net_revenue']),
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

class ProductRevenueReport {
  final List<BranchLookup> branches;
  final int branchId;
  final String fromDate;
  final String toDate;
  final List<ProductRevenueData> monthlyData;
  final List<ProductLookup> products;
  final String productId;

  ProductRevenueReport({
    required this.branches,
    required this.branchId,
    required this.fromDate,
    required this.toDate,
    required this.monthlyData,
    required this.products,
    required this.productId,
  });

  factory ProductRevenueReport.fromJson(Map<String, dynamic> json) {
    return ProductRevenueReport(
      branches: (json['branches'] as List?)
              ?.map((e) => BranchLookup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      branchId: int.tryParse(json['branch_id'].toString()) ?? 0,
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      monthlyData: (json['monthlyData'] as List?)
              ?.map((e) => ProductRevenueData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      products: (json['products'] as List?)
              ?.map((e) => ProductLookup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      productId: json['product_id']?.toString() ?? '',
    );
  }
}

// ─── Details Models ─────────────────────────────────────────────────────────

class ReportBranch {
  final int id;
  final String name;
  final String? emailPrimary;
  final String? phonePrimary;
  final String? address;

  ReportBranch({
    required this.id,
    required this.name,
    this.emailPrimary,
    this.phonePrimary,
    this.address,
  });

  factory ReportBranch.fromJson(Map<String, dynamic> json) {
    return ReportBranch(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      emailPrimary: json['email_primary']?.toString(),
      phonePrimary: json['phone_primary']?.toString(),
      address: json['address']?.toString(),
    );
  }
}

class ReportProduct {
  final int id;
  final String name;
  final String? shortDescription;
  final String? productType;
  final double price;

  ReportProduct({
    required this.id,
    required this.name,
    this.shortDescription,
    this.productType,
    required this.price,
  });

  factory ReportProduct.fromJson(Map<String, dynamic> json) {
    return ReportProduct(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      shortDescription: json['short_description']?.toString(),
      productType: json['product_type']?.toString(),
      price: _parseDouble(json['price']),
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

class DailyProductSummary {
  final int id;
  final int dailyClosingId;
  final int productId;
  final int quantitySold;
  final double unitPrice;
  final double totalAmount;
  final double totalDiscount;
  final double netRevenue;
  final String createdAt;
  final ReportProduct? product;

  DailyProductSummary({
    required this.id,
    required this.dailyClosingId,
    required this.productId,
    required this.quantitySold,
    required this.unitPrice,
    required this.totalAmount,
    required this.totalDiscount,
    required this.netRevenue,
    required this.createdAt,
    this.product,
  });

  factory DailyProductSummary.fromJson(Map<String, dynamic> json) {
    return DailyProductSummary(
      id: json['id'] ?? 0,
      dailyClosingId: json['daily_closing_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantitySold: json['quantity_sold'] ?? 0,
      unitPrice: _parseDouble(json['unit_price']),
      totalAmount: _parseDouble(json['total_amount']),
      totalDiscount: _parseDouble(json['total_discount']),
      netRevenue: _parseDouble(json['net_revenue']),
      createdAt: json['created_at']?.toString() ?? '',
      product: json['product'] != null
          ? ReportProduct.fromJson(json['product'] as Map<String, dynamic>)
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

class ProductRevenueDetails {
  final ReportBranch branch;
  final String fromDate;
  final String toDate;
  final String productName;
  final String productId;
  final PaginatedResult<DailyProductSummary> dailyProductSummaries;

  ProductRevenueDetails({
    required this.branch,
    required this.fromDate,
    required this.toDate,
    required this.productName,
    required this.productId,
    required this.dailyProductSummaries,
  });

  factory ProductRevenueDetails.fromJson(Map<String, dynamic> json) {
    final summariesData =
        json['dailyProductSummaries'] as Map<String, dynamic>? ?? {};
    final items = (summariesData['data'] as List?)
            ?.map((e) => DailyProductSummary.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return ProductRevenueDetails(
      branch: ReportBranch.fromJson(
          json['branch'] as Map<String, dynamic>? ?? {}),
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      dailyProductSummaries: PaginatedResult(
        items: items,
        meta: PaginationMeta.fromJson(summariesData),
      ),
    );
  }
}
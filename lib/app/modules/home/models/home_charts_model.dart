// lib/app/modules/home/models/home_charts_model.dart
//
// Models for `GET /charts`:
// {
//   "totalBookingCount": 1,
//   "totalPendingBookingCount": 0,
//   "totalCancelBookingCount": 0,
//   "totalCompletedBookingCount": 1,
//   "salesData": [{"date": "2026-10-14", "total": "1750.00"}]
// }

class SalesPoint {
  final String date;
  final double total;

  SalesPoint({required this.date, required this.total});

  factory SalesPoint.fromJson(Map<String, dynamic> json) {
    return SalesPoint(
      date: json['date']?.toString() ?? '',
      total: double.tryParse(json['total']?.toString() ?? '') ?? 0.0,
    );
  }
}

class HomeChartsData {
  final int totalBookings;
  final int pendingBookings;
  final int cancelledBookings;
  final int completedBookings;
  final List<SalesPoint> salesData;

  HomeChartsData({
    required this.totalBookings,
    required this.pendingBookings,
    required this.cancelledBookings,
    required this.completedBookings,
    required this.salesData,
  });

  factory HomeChartsData.fromJson(Map<String, dynamic> json) {
    int count(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    final sales = json['salesData'];
    return HomeChartsData(
      totalBookings: count(json['totalBookingCount']),
      pendingBookings: count(json['totalPendingBookingCount']),
      cancelledBookings: count(json['totalCancelBookingCount']),
      completedBookings: count(json['totalCompletedBookingCount']),
      salesData: sales is List
          ? sales
              .whereType<Map>()
              .map((e) => SalesPoint.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  double get totalSales =>
      salesData.fold<double>(0, (sum, p) => sum + p.total);
}

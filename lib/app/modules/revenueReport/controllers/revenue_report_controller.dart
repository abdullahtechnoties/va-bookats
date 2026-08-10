import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RevenueColumn {
  final String key;
  final String label;
  final double width;
  bool isSelected;

  RevenueColumn({
    required this.key,
    required this.label,
    this.width = 130,
    this.isSelected = true,
  });
}

class RevenueRow {
  final int index;
  final String branch;
  final String from;
  final String to;
  final String totalAmount;
  final String totalDiscount;
  final String totalPaidAmount;
  final String totalBalanceAmount;
  final String cashCount;
  final String onlinePayment;
  final String serviceAmount;
  final String productAmount;
  final String packageAmount;

  RevenueRow({
    required this.index,
    required this.branch,
    required this.from,
    required this.to,
    required this.totalAmount,
    required this.totalDiscount,
    required this.totalPaidAmount,
    required this.totalBalanceAmount,
    this.cashCount = '\$0',
    this.onlinePayment = '\$0',
    this.serviceAmount = '\$0',
    this.productAmount = '\$0',
    this.packageAmount = '\$0',
  });
}

class RevenueReportController extends GetxController {
  // ── title passed from caller ──────────────────────────────────────────
  final String screenTitle;

  RevenueReportController({this.screenTitle = 'revenue.title'});

  // ── filter state ──────────────────────────────────────────────────────
  final Rx<DateTime> fromDate = DateTime(2026, 8, 1).obs;
  final Rx<DateTime> toDate = DateTime(2026, 8, 1).obs;
  final RxString selectedBranch = 'All Branches'.obs;

  // temp filter (inside sheet before apply)
  final Rx<DateTime> tempFromDate = DateTime(2026, 8, 1).obs;
  final Rx<DateTime> tempToDate = DateTime(2026, 8, 1).obs;
  final RxString tempBranch = 'All Branches'.obs;

  final List<String> branches = [
    'All Branches',
    'Branch A',
    'Branch B',
    'Branch C',
  ];

  // ── column selector state ─────────────────────────────────────────────
  final RxList<RevenueColumn> allColumns = <RevenueColumn>[
    RevenueColumn(key: 'branch', label: 'Branch', width: 110, isSelected: true),
    RevenueColumn(key: 'from', label: 'From', width: 110, isSelected: true),
    RevenueColumn(key: 'to', label: 'To', width: 110, isSelected: true),
    RevenueColumn(key: 'totalAmount', label: 'Total Amount', width: 130, isSelected: true),
    RevenueColumn(key: 'totalDiscount', label: 'Total Discount', width: 130, isSelected: true),
    RevenueColumn(key: 'totalPaidAmount', label: 'Total Paid Amount', width: 145, isSelected: true),
    RevenueColumn(key: 'totalBalanceAmount', label: 'Total Balance Amount', width: 165, isSelected: true),
    RevenueColumn(key: 'cashCount', label: 'Cash Count', width: 120, isSelected: false),
    RevenueColumn(key: 'onlinePayment', label: 'Online Payment', width: 140, isSelected: false),
    RevenueColumn(key: 'serviceAmount', label: 'Service Amount', width: 140, isSelected: false),
    RevenueColumn(key: 'productAmount', label: 'Product Amount', width: 140, isSelected: false),
    RevenueColumn(key: 'packageAmount', label: 'Package Amount', width: 140, isSelected: false),
  ].obs;

  // temp columns (inside sheet before apply)
  late RxList<bool> tempColumnSelected;

  // ── pagination ────────────────────────────────────────────────────────
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 10;

  // ── dummy data ────────────────────────────────────────────────────────
  final List<RevenueRow> _allData = List.generate(
    25,
    (i) => RevenueRow(
      index: i + 1,
      branch: 'Demo',
      from: 'Aug/1/2026',
      to: 'Aug/1/2026',
      totalAmount: '\$10,000',
      totalDiscount: '\$10,000',
      totalPaidAmount: '\$10,000',
      totalBalanceAmount: '\$10,000',
      cashCount: '\$5,000',
      onlinePayment: '\$5,000',
      serviceAmount: '\$3,000',
      productAmount: '\$4,000',
      packageAmount: '\$3,000',
    ),
  );

  RxList<RevenueRow> get pagedData {
    final start = (currentPage.value - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, _allData.length);
    return _allData.sublist(start, end).obs;
  }

  int get totalPages => (_allData.length / itemsPerPage).ceil();

  // ── computed ──────────────────────────────────────────────────────────
  List<RevenueColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => allColumns.where((c) => c.isSelected).length;

  String get dateRangeLabel {
    return '${_fmt(fromDate.value)} - ${_fmt(toDate.value)}';
  }

  String _fmt(DateTime d) =>
      '${_monthAbbr(d.month)}/${d.day}/${d.year}';

  String _monthAbbr(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];

  // ── actions ───────────────────────────────────────────────────────────
  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranch.value = tempBranch.value;
    currentPage.value = 1;
  }

  void resetFilter() {
    tempFromDate.value = DateTime(2026, 8, 1);
    tempToDate.value = DateTime(2026, 8, 1);
    tempBranch.value = 'All Branches';
  }

  void initTempFilter() {
    tempFromDate.value = fromDate.value;
    tempToDate.value = toDate.value;
    tempBranch.value = selectedBranch.value;
  }

  void initTempColumns() {
    tempColumnSelected =
        allColumns.map((c) => c.isSelected).toList().obs;
  }

  void applyColumnSelection() {
    for (int i = 0; i < allColumns.length; i++) {
      allColumns[i].isSelected = tempColumnSelected[i];
    }
    allColumns.refresh();
  }

  void resetColumnSelection() {
    for (int i = 0; i < tempColumnSelected.length; i++) {
      tempColumnSelected[i] = true;
    }
    tempColumnSelected.refresh();
  }

  void selectAllColumns() {
    for (int i = 0; i < tempColumnSelected.length; i++) {
      tempColumnSelected[i] = true;
    }
    tempColumnSelected.refresh();
  }

  void toggleTempColumn(int index) {
    tempColumnSelected[index] = !tempColumnSelected[index];
    tempColumnSelected.refresh();
  }

  void nextPage() {
    if (currentPage.value < totalPages) currentPage.value++;
  }

  void prevPage() {
    if (currentPage.value > 1) currentPage.value--;
  }

  String getCellValue(RevenueRow row, String key) {
    switch (key) {
      case 'branch': return row.branch;
      case 'from': return row.from;
      case 'to': return row.to;
      case 'totalAmount': return row.totalAmount;
      case 'totalDiscount': return row.totalDiscount;
      case 'totalPaidAmount': return row.totalPaidAmount;
      case 'totalBalanceAmount': return row.totalBalanceAmount;
      case 'cashCount': return row.cashCount;
      case 'onlinePayment': return row.onlinePayment;
      case 'serviceAmount': return row.serviceAmount;
      case 'productAmount': return row.productAmount;
      case 'packageAmount': return row.packageAmount;
      default: return '-';
    }
  }
}
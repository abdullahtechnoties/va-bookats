// lib/app/modules/reports/payment_details/views/widgets/payment_table.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/paymentDetails/controllers/payment_details_controller.dart';
import 'package:va_bookats/models/payment_item.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class PaymentTableWidget extends StatelessWidget {
  final PaymentDetailsController controller;

  const PaymentTableWidget({super.key, required this.controller});

  static const double _indexColWidth = 44.0;
  static const double _rowHeight = 46.0;
  static const double _headerHeight = 48.0;

  // Define columns
  static final List<_ColDef> _columns = [
    _ColDef(key: 'customer', label: 'reports.paymentDetails.columns.customer', width: 130),
    _ColDef(key: 'bookingSerial', label: 'reports.paymentDetails.columns.bookingId', width: 110),
    _ColDef(key: 'date', label: 'reports.paymentDetails.columns.date', width: 110),
    _ColDef(key: 'totalAmount', label: 'reports.paymentDetails.columns.totalAmount', width: 130),
    _ColDef(key: 'paidAmount', label: 'reports.paymentDetails.columns.paidAmount', width: 130),
    _ColDef(key: 'balance', label: 'reports.paymentDetails.columns.balance', width: 120),
    _ColDef(key: 'paymentMethod', label: 'reports.paymentDetails.columns.paymentMethod', width: 140),
    _ColDef(key: 'status', label: 'reports.paymentDetails.columns.status', width: 100),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Obx(() {
          final items = controller.currentList;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTableHeader(),
                ...items.asMap().entries.map((entry) {
                  final isEven = entry.key % 2 == 0;
                  return _buildTableRow(entry.value, isEven, entry.key + 1);
                }),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: _headerHeight,
      color: AppColors.primary,
      child: Row(
        children: [
          _HeaderCell(label: '#', width: _indexColWidth, isFirst: true),
          ..._columns.map((c) => _HeaderCell(label: c.label.trns(), width: c.width)),
        ],
      ),
    );
  }

  Widget _buildTableRow(PaymentItem item, bool isEven, int index) {
    final bg = isEven ? AppColors.white : const Color(0xFFFFF5F2);
    return Container(
      height: _rowHeight,
      color: bg,
      child: Row(
        children: [
          _DataCell(
            width: _indexColWidth,
            showDivider: true,
            child: Text(
              '$index',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          ..._columns.map(
            (c) => _DataCell(
              width: c.width,
              showDivider: true,
              child: Text(
                controller.getCellValue(item, c.key),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Column Definition ─────────────────────────────────────────────────────────
class _ColDef {
  final String key;
  final String label;
  final double width;
  const _ColDef({required this.key, required this.label, required this.width});
}

// ── Table Cells ───────────────────────────────────────────────────────────────
class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;
  final bool isFirst;

  const _HeaderCell({
    required this.label,
    required this.width,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: PaymentTableWidget._headerHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.white.withValues(alpha: 0.25), width: 0.5),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final double width;
  final Widget child;
  final bool showDivider;

  const _DataCell({
    required this.width,
    required this.child,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: PaymentTableWidget._rowHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          right: showDivider
              ? const BorderSide(color: Color(0xFFE5E7EB), width: 0.5)
              : BorderSide.none,
          bottom: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
        ),
      ),
      child: child,
    );
  }
}
// lib/app/modules/customerReport/views/widgets/customer_table.dart

import 'package:flutter/material.dart';
import 'package:va_bookats/app/modules/reporting/customer_report/customerReport/controller/customer_report_controller.dart';
import 'package:va_bookats/app/modules/reporting/customer_report/customerReport/models/customer_report_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class CustomerReportTable extends StatelessWidget {
  final CustomerReportController controller;
  final List<CustomerReportData> rows;

  const CustomerReportTable({
    super.key,
    required this.controller,
    required this.rows,
  });

  static const double _indexColWidth = 44.0;
  static const double _actionsColWidth = 110.0;
  static const double _rowHeight = 46.0;
  static const double _headerHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final cols = controller.selectedColumns;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TableHeader(cols: cols),
            ...rows.asMap().entries.map((entry) {
              final isEven = entry.key % 2 == 0;
              return _TableDataRow(
                row: entry.value,
                cols: cols,
                isEven: isEven,
                controller: controller,
                index:
                    entry.key +
                    1 +
                    (controller.currentPage.value - 1) *
                        controller.itemsPerPage,
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  final List<CustomerReportColumn> cols;

  const _TableHeader({required this.cols});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: CustomerReportTable._headerHeight,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          _HeaderCell(
            label: '#',
            width: CustomerReportTable._indexColWidth,
            isFirst: true,
          ),
          ...cols.map((c) => _HeaderCell(label: c.label, width: c.width)),
          _HeaderCell(
            label: 'customerReport.table.actions'.trns(),
            width: CustomerReportTable._actionsColWidth,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;
  final bool isFirst;
  final bool isLast;

  const _HeaderCell({
    required this.label,
    required this.width,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: CustomerReportTable._headerHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : BorderSide(
                  color: AppColors.white.withValues(alpha: 0.25),
                  width: 0.5,
                ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Data Row ──────────────────────────────────────────────────────────────────
class _TableDataRow extends StatelessWidget {
  final CustomerReportData row;
  final List<CustomerReportColumn> cols;
  final bool isEven;
  final CustomerReportController controller;
  final int index;

  const _TableDataRow({
    required this.row,
    required this.cols,
    required this.isEven,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isEven ? AppColors.white : const Color(0xFFFFF5F2);

    return Container(
      height: CustomerReportTable._rowHeight,
      color: bgColor,
      child: Row(
        children: [
          // Index
          _DataCell(
            width: CustomerReportTable._indexColWidth,
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
          // Dynamic columns
          ...cols.map(
            (c) => _DataCell(
              width: c.width,
              showDivider: true,
              child: Text(
                controller.getCellValue(row, c.key),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF374151),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Actions
          _DataCell(
            width: CustomerReportTable._actionsColWidth,
            showDivider: false,
            child: GestureDetector(
              onTap: () => controller.viewDetails(row),
              child: Text(
                'customerReport.table.viewDetails'.trns(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
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
      height: CustomerReportTable._rowHeight,
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

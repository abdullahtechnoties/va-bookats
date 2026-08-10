import 'package:flutter/material.dart';
import 'package:va_bookats/app/modules/revenueReport/controllers/revenue_report_controller.dart';
import 'package:va_bookats/utilities/colors.dart';

class RevenueTableWidget extends StatelessWidget {
  final RevenueReportController controller;
  final List<RevenueRow> rows;

  const RevenueTableWidget({
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
            // ── header row ──────────────────────────────────────────────
            _TableHeader(cols: cols),
            // ── data rows ───────────────────────────────────────────────
            ...rows.asMap().entries.map((entry) {
              final isEven = entry.key % 2 == 0;
              return _TableDataRow(
                row: entry.value,
                cols: cols,
                isEven: isEven,
                controller: controller,
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  final List<RevenueColumn> cols;

  const _TableHeader({required this.cols});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: RevenueTableWidget._headerHeight,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          // # col
          _HeaderCell(
            label: '#',
            width: RevenueTableWidget._indexColWidth,
            isFirst: true,
          ),
          // dynamic cols
          ...cols.map((c) => _HeaderCell(label: c.label, width: c.width)),
          // actions col
          _HeaderCell(
            label: 'Actions',
            width: RevenueTableWidget._actionsColWidth,
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
      height: RevenueTableWidget._headerHeight,
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

// ── Data Row ────────────────────────────────────────────────────────────────
class _TableDataRow extends StatelessWidget {
  final RevenueRow row;
  final List<RevenueColumn> cols;
  final bool isEven;
  final RevenueReportController controller;

  const _TableDataRow({
    required this.row,
    required this.cols,
    required this.isEven,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isEven ? AppColors.white : const Color(0xFFFFF5F2);

    return Container(
      height: RevenueTableWidget._rowHeight,
      color: bgColor,
      child: Row(
        children: [
          // index
          _DataCell(
            width: RevenueTableWidget._indexColWidth,
            showDivider: true,
            child: Text(
              '${row.index}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          // dynamic columns
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
          // actions
          _DataCell(
            width: RevenueTableWidget._actionsColWidth,
            showDivider: false,
            child: GestureDetector(
              onTap: () {
                // navigate to detail
              },
              child: Text(
                'View Details',
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
      height: RevenueTableWidget._rowHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          right: showDivider
              ? BorderSide(
                  color: const Color(0xFFE5E7EB),
                  width: 0.5,
                )
              : BorderSide.none,
          bottom: BorderSide(
            color: const Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
      ),
      child: child,
    );
  }
}
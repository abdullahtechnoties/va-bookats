// lib/app/modules/service_revenue_report/views/widgets/service_revenue_table.dart

import 'package:flutter/material.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueReport/controller/service_revenue_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import '../../models/service_revenue_models.dart';

class ServiceRevenueTable extends StatelessWidget {
  final ServiceRevenueReportController controller;
  final List<ServiceRevenueData> data;

  const ServiceRevenueTable({
    super.key,
    required this.controller,
    required this.data,
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
            _buildHeader(cols),
            ...data.asMap().entries.map((entry) {
              return _buildDataRow(entry.value, entry.key % 2 == 0, cols);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(List<ServiceRevenueColumn> cols) {
    return Container(
      height: _headerHeight,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          _HeaderCell(label: '#', width: _indexColWidth, isFirst: true),
          ...cols.map((c) => _HeaderCell(label: c.label, width: c.width)),
          _HeaderCell(label: 'Actions', width: _actionsColWidth, isLast: true),
        ],
      ),
    );
  }

  Widget _buildDataRow(ServiceRevenueData row, bool isEven, List<ServiceRevenueColumn> cols) {
    final bgColor = isEven ? AppColors.white : const Color(0xFFFFF5F2);
    final index = data.indexOf(row) + 1;

    return Container(
      height: _rowHeight,
      color: bgColor,
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
          ...cols.map(
            (c) => _DataCell(
              width: c.width,
              showDivider: true,
              child: Text(
                controller.getCellValue(row, c.key),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          _DataCell(
            width: _actionsColWidth,
            showDivider: false,
            child: GestureDetector(
              onTap: () => controller.navigateToDetails(row),
              child: const Text(
                'View Details',
                textAlign: TextAlign.center,
                style: TextStyle(
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
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : BorderSide(color: AppColors.white.withValues(alpha: 0.25), width: 0.5),
        ),
      ),
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

class _DataCell extends StatelessWidget {
  final double width;
  final Widget child;
  final bool showDivider;

  const _DataCell({required this.width, required this.child, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 46,
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
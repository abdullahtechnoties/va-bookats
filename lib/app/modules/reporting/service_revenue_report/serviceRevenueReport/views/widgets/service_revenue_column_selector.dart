// lib/app/modules/service_revenue_report/views/widgets/service_revenue_column_selector.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueReport/controller/service_revenue_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class ServiceRevenueColumnSelector extends StatelessWidget {
  final ServiceRevenueReportController controller;

  const ServiceRevenueColumnSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    controller.initTempColumns();
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.72,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildHandle(),
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 12),
          _buildSubHeader(),
          const SizedBox(height: 8),
          Expanded(child: _buildList()),
          _buildButtons(context),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text(
                '${'reports.columns.title'.trns()} (${controller.tempColumnSelected.where((e) => e).length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              )),
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.close, color: AppColors.black, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'reports.columns.selectColumns'.trns(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          GestureDetector(
            onTap: controller.selectAllColumns,
            child: Text(
              'reports.columns.selectAll'.trns(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Obx(() => ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: controller.allColumns.length,
          itemBuilder: (ctx, i) {
            final col = controller.allColumns[i];
            final checked = controller.tempColumnSelected[i];
            return GestureDetector(
              onTap: () => controller.toggleTempColumn(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    _AppCheckbox(
                      value: checked,
                      onChanged: (_) => controller.toggleTempColumn(i),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      col.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: _OutlineBtn(
              label: 'reports.filter.reset'.trns(),
              onTap: controller.resetColumnSelection,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MainBtn(
              text: 'reports.filter.apply'.trns(),
              onPressed: () {
                controller.applyColumnSelection();
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _AppCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: value ? AppColors.primary : const Color(0xFFD1D5DB),
            width: 1.5,
          ),
        ),
        child: value ? const Icon(Icons.check, color: AppColors.white, size: 14) : null,
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
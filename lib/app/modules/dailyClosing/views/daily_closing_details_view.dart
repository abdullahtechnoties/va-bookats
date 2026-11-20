// lib/app/modules/dailyClosing/views/daily_closing_details_view.dart
//
// Read-only detail screen. The API returns one paginator per section, so the
// data is split into tabs: Overview, Bookings, Payments, Staff, Expenses,
// Sales summary and Activity. Every section can append its own next page.
// Details are never editable — only the status can be toggled, and only with
// `daily-closings.update`.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/dailyClosing/controllers/daily_closing_details_controller.dart';
import 'package:va_bookats/app/modules/dailyClosing/models/daily_closing_model.dart';
import 'package:va_bookats/app/modules/dailyClosing/repositories/daily_closing_repository.dart';
import 'package:va_bookats/app/modules/dailyClosing/utilities/closing_formatters.dart';
import 'package:va_bookats/app/modules/dailyClosing/views/widgets/daily_closing_card.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class DailyClosingDetailsView extends GetView<DailyClosingDetailsController> {
  const DailyClosingDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Obx(() {
          final closing = controller.closing.value;
          return Column(
            children: [
              _Header(
                closing: closing,
                isBusy: controller.busyStatusId.value != null,
                onChangeStatus: controller.changeStatus,
              ),
              if (controller.isLoading.value && closing == null)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  ),
                )
              else if (closing == null)
                Expanded(child: _ErrorState(onRetry: controller.retry))
              else
                Expanded(child: _body(closing)),
            ],
          );
        }),
      ),
    );
  }

  Widget _body(DailyClosingModel closing) {
    return Column(
      children: [
        _SummaryCard(closing: closing),
        Container(
          color: AppColors.white,
          child: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.secondary,
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: AppColors.secondary,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: 'dailyClosing.tab.overview'.trns()),
              Tab(
                text:
                    '${'dailyClosing.tab.bookings'.trns()} (${closing.totalBookings})',
              ),
              Tab(text: 'dailyClosing.tab.payments'.trns()),
              Tab(text: 'dailyClosing.tab.staff'.trns()),
              Tab(text: 'dailyClosing.tab.expenses'.trns()),
              Tab(text: 'dailyClosing.tab.sales'.trns()),
              Tab(text: 'dailyClosing.tab.activity'.trns()),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              _OverviewTab(controller: controller, closing: closing),
              _RawTab(
                controller: controller,
                section: ClosingSection.bookings,
                sectionRx: controller.bookings,
                emptyLabel: 'dailyClosing.empty.bookings'.trns(),
              ),
              _RawTab(
                controller: controller,
                section: ClosingSection.payments,
                sectionRx: controller.payments,
                emptyLabel: 'dailyClosing.empty.payments'.trns(),
              ),
              _RawTab(
                controller: controller,
                section: ClosingSection.staffCommissions,
                sectionRx: controller.staffCommissions,
                emptyLabel: 'dailyClosing.empty.staff'.trns(),
              ),
              _RawTab(
                controller: controller,
                section: ClosingSection.expenses,
                sectionRx: controller.expenses,
                emptyLabel: 'dailyClosing.empty.expenses'.trns(),
              ),
              _SalesTab(controller: controller),
              _ActivityTab(controller: controller),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final DailyClosingModel? closing;
  final bool isBusy;
  final VoidCallback onChangeStatus;

  const _Header({
    required this.closing,
    required this.isBusy,
    required this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'dailyClosing.detailsTitle'.trns(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (closing != null && closing!.closingDate.isNotEmpty)
                      Text(
                        closingDisplayDate(closing!.closingDate),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              Can(
                AppPerm.update(AppPerm.dailyClosings),
                child: GestureDetector(
                  onTap: isBusy ? null : onChangeStatus,
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: isBusy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.secondary,
                            ),
                          )
                        : Row(
                            children: [
                              const Icon(
                                Icons.sync_alt_rounded,
                                size: 15,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'dailyClosing.changeStatus'.trns(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Summary card (always visible above the tabs) ───────────────────────────

class _SummaryCard extends StatelessWidget {
  final DailyClosingModel closing;

  const _SummaryCard({required this.closing});

  @override
  Widget build(BuildContext context) {
    final symbol = closing.currencySymbol;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'dailyClosing.openingBalance'.trns(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      closingMoney(closing.openingBalance, symbol),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              ClosingStatusChip(status: closing.status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _Info(
                icon: Icons.storefront_outlined,
                label: closing.branchName.isEmpty ? '—' : closing.branchName,
              ),
              _Info(
                icon: Icons.person_outline,
                label: closing.creatorName.isEmpty
                    ? 'dailyClosing.unknownUser'.trns()
                    : '${'dailyClosing.createdBy'.trns()}: ${closing.creatorName}',
              ),
              if (closing.isApproved)
                _Info(
                  icon: Icons.verified_outlined,
                  label: closing.approverName.isEmpty
                      ? 'dailyClosing.status.approved'.trns()
                      : '${'dailyClosing.approvedBy'.trns()}: ${closing.approverName}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Info({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Overview tab ───────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final DailyClosingDetailsController controller;
  final DailyClosingModel closing;

  const _OverviewTab({required this.controller, required this.closing});

  @override
  Widget build(BuildContext context) {
    final symbol = closing.currencySymbol;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      children: [
        _SectionHeader(title: 'dailyClosing.section.revenue'.trns()),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.15,
          children: [
            _Metric(
              label: 'dailyClosing.metric.totalRevenue'.trns(),
              value: closingMoney(closing.totalRevenue, symbol),
              highlight: true,
            ),
            _Metric(
              label: 'dailyClosing.metric.totalAmount'.trns(),
              value: closingMoney(closing.totalAmount, symbol),
            ),
            _Metric(
              label: 'dailyClosing.metric.totalDiscount'.trns(),
              value: closingMoney(closing.totalDiscount, symbol),
            ),
            _Metric(
              label: 'dailyClosing.metric.totalBalance'.trns(),
              value: closingMoney(closing.totalBalance, symbol),
            ),
            _Metric(
              label: 'dailyClosing.metric.totalExpense'.trns(),
              value: closingMoney(closing.totalExpense, symbol),
            ),
            _Metric(
              label: 'dailyClosing.metric.unpaidAmount'.trns(),
              value: closingMoney(closing.unpaidAmount, symbol),
            ),
            _Metric(
              label: 'dailyClosing.metric.staffCommission'.trns(),
              value: closingMoney(closing.staffCommissionTotal, symbol),
            ),
            _Metric(
              label: 'dailyClosing.metric.additionalAmount'.trns(),
              value: closingMoney(closing.totalAdditionalAmount, symbol),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionHeader(title: 'dailyClosing.section.payments'.trns()),
        _valueGrid([
          (
            'dailyClosing.metric.cash'.trns(),
            closingMoney(closing.cashPayment, symbol),
            '${closing.cashCount}',
          ),
          (
            'dailyClosing.metric.card'.trns(),
            closingMoney(closing.cardPayment, symbol),
            '${closing.cardCount}',
          ),
          (
            'dailyClosing.metric.online'.trns(),
            closingMoney(closing.onlinePayment, symbol),
            '${closing.onlineCount}',
          ),
          (
            'dailyClosing.metric.return'.trns(),
            closingMoney(closing.returnPayment, symbol),
            '',
          ),
        ]),
        const SizedBox(height: 16),
        _SectionHeader(title: 'dailyClosing.section.activityCounts'.trns()),
        _valueGrid([
          (
            'dailyClosing.metric.totalBookings'.trns(),
            '${closing.totalBookings}',
            '',
          ),
          (
            'dailyClosing.metric.customers'.trns(),
            '${closing.totalCustomers}',
            '',
          ),
          (
            'dailyClosing.metric.repeatCustomers'.trns(),
            '${closing.repeatCustomers}',
            '',
          ),
          (
            'dailyClosing.metric.cancelled'.trns(),
            '${closing.cancelledBookings}',
            '',
          ),
          ('dailyClosing.metric.paid'.trns(), '${closing.paidCount}', ''),
          ('dailyClosing.metric.unpaid'.trns(), '${closing.unpaidCount}', ''),
        ]),
        const SizedBox(height: 16),
        _SectionHeader(title: 'dailyClosing.section.cashFlow'.trns()),
        Row(
          children: [
            Expanded(
              child: _Metric(
                label: 'dailyClosing.cashFlow.in'.trns(),
                value: closingMoney(controller.cashIn.value, symbol),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Metric(
                label: 'dailyClosing.cashFlow.out'.trns(),
                value: closingMoney(controller.cashOut.value, symbol),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Metric(
                label: 'dailyClosing.cashFlow.net'.trns(),
                value: closingMoney(controller.cashNet.value, symbol),
                highlight: true,
              ),
            ),
          ],
        ),
        if (closing.remarks.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(title: 'dailyClosing.section.remarks'.trns()),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              closing.remarks,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ),
        ],
        if (closing.topServiceName.isNotEmpty ||
            closing.topProductName.isNotEmpty ||
            closing.topPackageName.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(title: 'dailyClosing.section.topSellers'.trns()),
          _valueGrid([
            if (closing.topServiceName.isNotEmpty)
              (
                'dailyClosing.top.service'.trns(),
                closing.topServiceName,
                '${closing.totalServicesSold}',
              ),
            if (closing.topProductName.isNotEmpty)
              (
                'dailyClosing.top.product'.trns(),
                closing.topProductName,
                '${closing.totalProductsSold}',
              ),
            if (closing.topPackageName.isNotEmpty)
              (
                'dailyClosing.top.package'.trns(),
                closing.topPackageName,
                '${closing.totalPackagesSold}',
              ),
          ]),
        ],
      ],
    );
  }

  Widget _valueGrid(List<(String, String, String)> rows) {
    return Column(
      children: rows
          .map(
            (row) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.$1,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (row.$3.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        row.$3,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    row.$2,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _Metric({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.secondary.withValues(alpha: 0.08)
            : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight
              ? AppColors.secondary.withValues(alpha: 0.35)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: highlight ? AppColors.secondary : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.black,
        ),
      ),
    );
  }
}

// ─── Generic raw section tab ────────────────────────────────────────────────

class _RawTab extends StatelessWidget {
  final DailyClosingDetailsController controller;
  final ClosingSection section;
  final Rx<RawSection> sectionRx;
  final String emptyLabel;

  const _RawTab({
    required this.controller,
    required this.section,
    required this.sectionRx,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = sectionRx.value;
      final isLoading = controller.loadingSections.contains(section);
      if (data.items.isEmpty) {
        return _EmptyTab(label: emptyLabel);
      }
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        itemCount: data.items.length + 1,
        itemBuilder: (context, index) {
          if (index == data.items.length) {
            return _LoadMore(
              hasMore: data.meta.hasNextPage,
              isLoading: isLoading,
              onTap: () => controller.loadMore(section),
              total: data.meta.total,
              shown: data.items.length,
            );
          }
          return _RawItemCard(item: data.items[index]);
        },
      );
    });
  }
}

class _RawItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _RawItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final entries = item.entries.where((e) {
      final v = e.value;
      if (v is Map || v is List) return false;
      if (v == null) return false;
      return true;
    }).toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: entries.map((entry) {
          final key = entry.key;
          final isPrimary =
              key == 'id' ||
              key == 'bill_no' ||
              key == 'serial' ||
              key == 'name';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    humanizeReportKey(key),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: Text(
                    isPrimary && key == 'id'
                        ? '#${entry.value}'
                        : formatReportCell(key, entry.value),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.black,
                      fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LoadMore extends StatelessWidget {
  final bool hasMore;
  final bool isLoading;
  final int total;
  final int shown;
  final VoidCallback onTap;

  const _LoadMore({
    required this.hasMore,
    required this.isLoading,
    required this.total,
    required this.shown,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            '$shown / $total',
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.secondary, width: 1.2),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.secondary,
                    ),
                  )
                : Text(
                    '${'dailyClosing.loadMore'.trns()} ($shown / $total)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Sales summary tab ──────────────────────────────────────────────────────

class _SalesTab extends StatelessWidget {
  final DailyClosingDetailsController controller;

  const _SalesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final services = controller.serviceSummary.value;
      final products = controller.productSummary.value;
      final packages = controller.packageSummary.value;
      if (services.items.isEmpty &&
          products.items.isEmpty &&
          packages.items.isEmpty) {
        return _EmptyTab(label: 'dailyClosing.empty.sales'.trns());
      }
      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        children: [
          _summaryBlock(
            title: 'dailyClosing.section.services'.trns(),
            data: services,
            section: ClosingSection.services,
            emptyLabel: 'dailyClosing.empty.section'.trns(),
          ),
          _summaryBlock(
            title: 'dailyClosing.section.products'.trns(),
            data: products,
            section: ClosingSection.products,
            emptyLabel: 'dailyClosing.empty.section'.trns(),
          ),
          _summaryBlock(
            title: 'dailyClosing.section.packages'.trns(),
            data: packages,
            section: ClosingSection.packages,
            emptyLabel: 'dailyClosing.empty.section'.trns(),
          ),
        ],
      );
    });
  }

  Widget _summaryBlock({
    required String title,
    required RawSection data,
    required ClosingSection section,
    required String emptyLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title),
        if (data.items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              emptyLabel,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          )
        else
          ...data.items.map((item) => _RawItemCard(item: item)),
        if (data.meta.hasNextPage)
          _LoadMore(
            hasMore: true,
            isLoading: controller.loadingSections.contains(section),
            total: data.meta.total,
            shown: data.items.length,
            onTap: () => controller.loadMore(section),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Activity tab ───────────────────────────────────────────────────────────

class _ActivityTab extends StatelessWidget {
  final DailyClosingDetailsController controller;

  const _ActivityTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activities = controller.activities;
      if (activities.isEmpty) {
        return _EmptyTab(label: 'dailyClosing.empty.activity'.trns());
      }
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: AppCachedImage(
                    imageUrl: activity.user?.bestImageUrl,
                    width: 32,
                    height: 32,
                    fallbackAsset: 'assets/images/placeholder.png',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.comment,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        closingActivityTime(activity.createdAt),
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

// ─── Empty / error ──────────────────────────────────────────────────────────

class _EmptyTab extends StatelessWidget {
  final String label;

  const _EmptyTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 46, color: Color(0xFFCCCCCC)),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 56, color: Color(0xFFCCCCCC)),
          const SizedBox(height: 12),
          Text(
            'dailyClosing.loadFailed'.trns(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'common.retry'.trns(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

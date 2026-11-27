import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:va_bookats/app/modules/appDrawer/controllers/app_drawer_controller.dart';
import 'package:va_bookats/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:va_bookats/app/modules/dailyClosing/controllers/opening_balance_controller.dart';
import 'package:va_bookats/app/modules/dailyClosing/utilities/closing_formatters.dart';
import 'package:va_bookats/app/modules/dailyClosing/views/widgets/closing_branch_picker.dart';
import 'package:va_bookats/app/modules/dailyClosing/views/widgets/daily_closing_card.dart';
import 'package:va_bookats/app/modules/home/controllers/home_controller.dart';
import 'package:va_bookats/app/modules/home/models/home_model.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/booking_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/booking_card.dart';
import 'package:va_bookats/widgets/Global-Widgets/booking_status_sheet.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

// ─── Dummy Asset Icon Paths ─────────────────────────────────────────────────

class _HomeAssets {
  _HomeAssets._();

  // Header
  static const String menu = 'assets/icons/ic_menu.png';
  static const String search = 'assets/icons/ic_search.png';
  static const String notification = 'assets/icons/ic_notification.png';

  // Opening Balance
  static const String wallet = 'assets/icons/ic_wallet.png';

  // 4 Booking Stats
  static const String statTotal = 'assets/icons/ic_stat_total.png';
  static const String statPending = 'assets/icons/ic_stat_pending.png';
  static const String statCompleted = 'assets/icons/ic_stat_completed.png';
  static const String statCancelled = 'assets/icons/ic_stat_cancelled.png';

  // Quick Actions
  static const String qaBooking = 'assets/icons/ic_qa_booking.png';
  static const String qaInventory = 'assets/icons/ic_qa_inventory.png';
  static const String qaPayments = 'assets/icons/ic_qa_payments.png';
  static const String qaCustomers = 'assets/icons/ic_qa_customers.png';
  static const String qaReporting = 'assets/icons/ic_qa_reporting.png';
  static const String qaDailyClosing = 'assets/icons/ic_qa_daily_closing.png';

  // Revenue Card
  static const String revenueChart = 'assets/icons/ic_revenue_chart.png';
}

// ─── Responsive Scale Helper (mirrors ResponsiveUtil.scaleSize) ─────────────

double _rs(BuildContext context, double baseSize) {
  final double screenWidth = MediaQuery.sizeOf(context).width;
  final double pixelDensity = MediaQuery.devicePixelRatioOf(context);
  double scaleFactor;

  if (screenWidth >= 1920.0) {
    scaleFactor = (screenWidth / 1920.0) * 1.2;
  } else if (screenWidth >= 1024.0) {
    scaleFactor = (screenWidth / 1920.0) * 1.1;
  } else if (screenWidth >= 768.0) {
    scaleFactor = (screenWidth / 1024.0) * 1.0;
  } else {
    scaleFactor = (screenWidth / 360.0) * 0.85;
  }

  scaleFactor = scaleFactor.clamp(0.85, 1.3);

  return math.max(
    baseSize * scaleFactor,
    pixelDensity > 2 ? pixelDensity * 0.75 : 8.0,
  );
}

// ─── Asset Icon Widget with Safe Fallback ───────────────────────────────────

class _AssetIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;
  final IconData fallbackIcon;

  const _AssetIcon({
    required this.assetPath,
    required this.size,
    required this.fallbackIcon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        fallbackIcon,
        size: size,
        color: color,
      ),
    );
  }
}

// ─── Home View ──────────────────────────────────────────────────────────────

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final obController = ensureOpeningBalanceController();

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: Column(
          children: [
            _HomeHeader(
              controller: controller,
              obController: obController,
            ),
            Expanded(
              child: RefreshIndicator(
                backgroundColor: AppColors.white,
                color: AppColors.secondary,
                onRefresh: () async {
                  await Future.wait([
                    controller.handleRefresh(),
                    refreshOpeningBalanceIfMounted(),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overlapping Hero Card (Opening Balance + 4 Booking Stats)
                      _HeroDashboardCard(
                        controller: controller,
                        obController: obController,
                      ),

                      // Quick Actions (6 Drawer-synced Shortcuts)
                      _QuickActionsSection(controller: controller),

                      // Revenue Overview + Today's Bookings (gated by booking perm)
                      Can.any(
                        [AppPerm.index(AppPerm.bookings)],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RevenueCard(controller: controller),
                            SizedBox(height: _rs(context, 22)),
                            _TodayBookingHeader(controller: controller),
                            SizedBox(height: _rs(context, 10)),
                            Obx(() {
                              if (controller.isLoading.value) {
                                return const _BookingShimmerList();
                              }
                              if (controller.loadFailed.value &&
                                  controller.todayBookings.isEmpty) {
                                return _HomeErrorState(
                                  onRetry: controller.retry,
                                );
                              }
                              if (controller.todayBookings.isEmpty) {
                                return const _HomeEmptyState();
                              }
                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.todayBookings.length,
                                itemBuilder: (context, index) {
                                  final booking =
                                      controller.todayBookings[index];
                                  return Obx(
                                    () => BookingCard(
                                      booking: booking,
                                      isBusy:
                                          controller.busyBookingId.value ==
                                          booking.id,
                                      onDelete: () =>
                                          controller.deleteBooking(booking),
                                      onViewDetails: () =>
                                          controller.openDetails(booking),
                                      onEdit: () => _openEdit(booking),
                                      onStatusTap: () =>
                                          _showStatusSheet(context, booking),
                                    ),
                                  );
                                },
                              );
                            }),
                            SizedBox(height: _rs(context, 28)),
                          ],
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
    );
  }

  void _openEdit(BookingModel booking) {
    Get.toNamed(Routes.CREATE_BOOKING, arguments: booking)?.then((_) {
      controller.handleRefresh();
    });
  }

  void _showStatusSheet(BuildContext context, BookingModel booking) {
    BookingStatusSheet.show(
      context,
      currentStatus: booking.status,
      totalAmount: booking.totalAmount ?? booking.payment?.totalAmount ?? '0',
      discount: booking.discount ?? booking.payment?.discountAmount ?? '0',
      amountPaid: booking.amountPaid ?? booking.payment?.paidAmount ?? '0',
      balance: booking.remainingAmount ?? booking.payment?.balance ?? '0',
      onConfirmed: ({
        required String status,
        String? returnAmount,
        String? paymentMethod,
        String? transactionId,
        int? mediaId,
      }) {
        controller.changeStatus(
          booking,
          status,
          returnAmount: returnAmount,
          paymentMethod: paymentMethod,
          transactionId: transactionId,
          mediaId: mediaId,
        );
      },
    );
  }
}

// ─── Top Bar Header ─────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final HomeController controller;
  final OpeningBalanceController obController;

  const _HomeHeader({
    required this.controller,
    required this.obController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.secondary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            _rs(context, 18),
            _rs(context, 12),
            _rs(context, 18),
            _rs(context, 14),
          ),
          child: Row(
            children: [
              // Menu Button
              GestureDetector(
                onTap: () => Get.find<BottomnavController>().openDrawer(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(right: _rs(context, 14)),
                  child: _AssetIcon(
                    assetPath: _HomeAssets.menu,
                    size: _rs(context, 24),
                    color: AppColors.white,
                    fallbackIcon: Icons.format_list_bulleted_rounded,
                  ),
                ),
              ),

              // Branch Selector / Title
              Expanded(
                child: _HeaderBranchSelector(
                  controller: controller,
                  obController: obController,
                ),
              ),

              // Search Circle Button
              GestureDetector(
                onTap: controller.openSearch,
                child: Container(
                  width: _rs(context, 40),
                  height: _rs(context, 40),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: _AssetIcon(
                    assetPath: _HomeAssets.search,
                    size: _rs(context, 19),
                    color: AppColors.white,
                    fallbackIcon: Icons.search_rounded,
                  ),
                ),
              ),
              SizedBox(width: _rs(context, 10)),

              // Notification Circle Button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: _rs(context, 40),
                  height: _rs(context, 40),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: _AssetIcon(
                    assetPath: _HomeAssets.notification,
                    size: _rs(context, 19),
                    color: AppColors.white,
                    fallbackIcon: Icons.notifications_none_rounded,
                  ),
                ),
              ),
              SizedBox(width: _rs(context, 10)),

              // Profile Avatar
              Obx(() {
                final img = controller.auth.currentUser.value;
                return GestureDetector(
                  onTap: () => Get.toNamed(Routes.PERSONAL_INFO),
                  child: Container(
                    width: _rs(context, 40),
                    height: _rs(context, 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: AppCachedImage(
                        imageUrl:
                            img?.bestImageUrl ?? img?.bestImageThumbUrl,
                        width: _rs(context, 40),
                        height: _rs(context, 40),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBranchSelector extends StatelessWidget {
  final HomeController controller;
  final OpeningBalanceController obController;

  const _HeaderBranchSelector({
    required this.controller,
    required this.obController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final branch = obController.selectedBranch.value;
      final isLoadingBranches = obController.isBranchesLoading.value;
      final fallbackName = controller.userName.isNotEmpty
          ? controller.userName
          : 'Main Branch';

      final String displayBranch = isLoadingBranches
          ? 'common.loading'.trns()
          : (branch?.displayLabel.isNotEmpty == true
                ? branch!.displayLabel
                : fallbackName);

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: obController.isOwner
            ? () async {
                if (obController.isBranchesLoading.value) return;
                if (obController.branches.isEmpty) {
                  await obController.loadBranches();
                }
                if (!context.mounted) return;
                final picked = await showClosingBranchPicker(
                  context,
                  branches: obController.branches,
                  selected: obController.selectedBranch.value,
                );
                if (picked == null) return;
                await obController.selectBranch(picked);
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Branch',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.85),
                fontSize: _rs(context, 11.5),
                fontWeight: FontWeight.w400,
                height: 1.1,
              ),
            ),
            SizedBox(height: _rs(context, 2)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    displayBranch,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: _rs(context, 16.5),
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
                SizedBox(width: _rs(context, 4)),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.white,
                  size: _rs(context, 18),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ─── Overlapping Hero Card (Opening Balance + 4 Booking Stats) ──────────────

class _HeroDashboardCard extends StatelessWidget {
  final HomeController controller;
  final OpeningBalanceController obController;

  const _HeroDashboardCard({
    required this.controller,
    required this.obController,
  });

  @override
  Widget build(BuildContext context) {
    final bool canViewClosings = Permissions.can(
      AppPerm.index(AppPerm.dailyClosings),
    );
    final bool canViewBookings = Permissions.can(
      AppPerm.index(AppPerm.bookings),
    );

    if (!canViewClosings && !canViewBookings) {
      return Container(
        height: _rs(context, 20),
        decoration: const BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Orange curved backdrop extending seamlessly from the top header
        Container(
          height: _rs(context, 56),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
        ),

        // White Floating Card
        Container(
          margin: EdgeInsets.fromLTRB(
            _rs(context, 16),
            _rs(context, 4),
            _rs(context, 16),
            0,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Opening Balance Section
              Can(
                AppPerm.index(AppPerm.dailyClosings),
                child: _OpeningBalanceSection(controller: obController),
              ),

              // Divider when both sections are visible
              if (canViewClosings && canViewBookings)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _rs(context, 16)),
                  child: const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF1F1F1),
                  ),
                ),

              // 2. Booking Stats 4-Column Row
              Can.any(
                [AppPerm.index(AppPerm.bookings)],
                child: _InlineStatsRow(controller: controller),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OpeningBalanceSection extends StatelessWidget {
  final OpeningBalanceController controller;

  const _OpeningBalanceSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final today = controller.today.value;
      final hasOpening = today?.exists == true;

      return Padding(
        padding: EdgeInsets.fromLTRB(
          _rs(context, 16),
          _rs(context, 16),
          _rs(context, 16),
          _rs(context, 15),
        ),
        child: Row(
          children: [
            // Soft Orange Wallet Icon Box
            Container(
              width: _rs(context, 48),
              height: _rs(context, 48),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFE7),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: _AssetIcon(
                assetPath: _HomeAssets.wallet,
                size: _rs(context, 22),
                color: AppColors.secondary,
                fallbackIcon: Icons.account_balance_wallet_outlined,
              ),
            ),
            SizedBox(width: _rs(context, 12)),

            // Title + Subtitle / Amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opening Balance',
                    style: TextStyle(
                      fontSize: _rs(context, 14.5),
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: _rs(context, 3)),
                  if (controller.isLoading.value)
                    SizedBox(
                      width: _rs(context, 14),
                      height: _rs(context, 14),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.secondary,
                      ),
                    )
                  else if (controller.loadFailed.value)
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'dailyClosing.loadFailedShort'.trns(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: _rs(context, 11.5),
                              color: AppColors.lightGrey,
                            ),
                          ),
                        ),
                        SizedBox(width: _rs(context, 6)),
                        GestureDetector(
                          onTap: controller.fetchToday,
                          child: Text(
                            'common.retry'.trns(),
                            style: TextStyle(
                              fontSize: _rs(context, 11.5),
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (hasOpening)
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            closingAmount(today!.openingBalance),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: _rs(context, 14),
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: _rs(context, 6)),
                        ClosingStatusChip(status: today.status),
                      ],
                    )
                  else
                    Text(
                      'Today, not created yet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _rs(context, 11.5),
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightGrey,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: _rs(context, 8)),

            // Right Action Button ("Add Opening" or "View All")
            if (hasOpening)
              GestureDetector(
                onTap: () => Get.toNamed(Routes.DAILY_CLOSINGS),
                child: Container(
                  height: _rs(context, 36),
                  padding: EdgeInsets.symmetric(horizontal: _rs(context, 12)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEFE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'dailyClosing.viewAll'.trns(),
                        style: TextStyle(
                          fontSize: _rs(context, 11.5),
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              )
            else
              Can(
                AppPerm.create(AppPerm.dailyClosings),
                child: GestureDetector(
                  onTap: () => controller.openCreateSheet(context),
                  child: Container(
                    height: _rs(context, 36),
                    padding: EdgeInsets.symmetric(horizontal: _rs(context, 14)),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Add Opening',
                      style: TextStyle(
                        fontSize: _rs(context, 12),
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _InlineStatsRow extends StatelessWidget {
  final HomeController controller;

  const _InlineStatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingHome) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _rs(context, 12),
            vertical: _rs(context, 16),
          ),
          child: Row(
            children: List.generate(
              4,
              (_) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: _rs(context, 6)),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: _rs(context, 68),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      final home = controller.home;
      if (home == null) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.fromLTRB(
          _rs(context, 6),
          _rs(context, 14),
          _rs(context, 6),
          _rs(context, 16),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _InlineStatItem(
                  value: _fullNumber(home.totalBookings.toDouble()),
                  label: 'Total',
                  assetPath: _HomeAssets.statTotal,
                  fallbackIcon: Icons.calendar_today_outlined,
                  circleBg: const Color(0xFFFFEFE7),
                  iconColor: AppColors.secondary,
                ),
              ),
              const _StatVerticalDivider(),
              Expanded(
                child: _InlineStatItem(
                  value: _fullNumber(home.pendingBookings.toDouble()),
                  label: 'Pending',
                  assetPath: _HomeAssets.statPending,
                  fallbackIcon: Icons.access_time_rounded,
                  circleBg: const Color(0xFFFFF6E5),
                  iconColor: const Color(0xFFF59E0B),
                ),
              ),
              const _StatVerticalDivider(),
              Expanded(
                child: _InlineStatItem(
                  value: _fullNumber(home.completedBookings.toDouble()),
                  label: 'Completed',
                  assetPath: _HomeAssets.statCompleted,
                  fallbackIcon: Icons.check_circle_outline_rounded,
                  circleBg: const Color(0xFFE8F7EE),
                  iconColor: const Color(0xFF22C55E),
                ),
              ),
              const _StatVerticalDivider(),
              Expanded(
                child: _InlineStatItem(
                  value: _fullNumber(home.cancelledBookings.toDouble()),
                  label: 'Cancelled',
                  assetPath: _HomeAssets.statCancelled,
                  fallbackIcon: Icons.cancel_outlined,
                  circleBg: const Color(0xFFFDECEC),
                  iconColor: AppColors.red,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _StatVerticalDivider extends StatelessWidget {
  const _StatVerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: EdgeInsets.symmetric(vertical: _rs(context, 6)),
      color: const Color(0xFFEEEEEE),
    );
  }
}

class _InlineStatItem extends StatelessWidget {
  final String value;
  final String label;
  final String assetPath;
  final IconData fallbackIcon;
  final Color circleBg;
  final Color iconColor;

  const _InlineStatItem({
    required this.value,
    required this.label,
    required this.assetPath,
    required this.fallbackIcon,
    required this.circleBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _rs(context, 30),
          height: _rs(context, 30),
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: _AssetIcon(
            assetPath: assetPath,
            size: _rs(context, 15),
            color: iconColor,
            fallbackIcon: fallbackIcon,
          ),
        ),
        SizedBox(height: _rs(context, 8)),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: _rs(context, 18),
            fontWeight: FontWeight.w800,
            color: AppColors.black,
            height: 1.1,
          ),
        ),
        SizedBox(height: _rs(context, 3)),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: _rs(context, 11.5),
            fontWeight: FontWeight.w400,
            color: const Color(0xFF888888),
          ),
        ),
      ],
    );
  }
}

// ─── Quick Actions Section (Drawer-Synced Routing) ──────────────────────────

class _QuickActionsSection extends StatelessWidget {
  final HomeController controller;

  const _QuickActionsSection({required this.controller});

  AppDrawerController _ensureDrawerController() {
    if (Get.isRegistered<AppDrawerController>()) {
      return Get.find<AppDrawerController>();
    }
    return Get.put(AppDrawerController());
  }

  void _onBookingTap(BuildContext context) {
    final canAccess = Permissions.canAny([
      AppPerm.index(AppPerm.bookings),
      AppPerm.create(AppPerm.bookings),
    ]);
    if (!canAccess) {
      showNoAccessDialog();
      return;
    }
    final subItems = _ensureDrawerController().bookingSubItems;
    if (subItems.isEmpty) {
      controller.openAllBookings();
      return;
    }
    _showQuickActionSubSheet(
      context,
      title: 'drawer.booking'.trns(),
      items: subItems,
      onSelected: (item) {
        switch (item) {
          case 'All Bookings':
            Get.toNamed(Routes.ALL_BOOKING);
            break;
          case 'Add Booking':
            controller.openCreate();
            break;
          default:
            controller.openAllBookings();
        }
      },
    );
  }

  void _onInventoryTap(BuildContext context) {
    final canAccess = Permissions.canAny([
      AppPerm.index(AppPerm.services),
      AppPerm.index(AppPerm.serviceCategories),
      AppPerm.index(AppPerm.packages),
      AppPerm.index(AppPerm.products),
      AppPerm.index(AppPerm.brands),
      AppPerm.index(AppPerm.productCategories),
      AppPerm.index(AppPerm.tags),
      AppPerm.index(AppPerm.units),
      AppPerm.index(AppPerm.productVariations),
    ]);
    if (!canAccess) {
      showNoAccessDialog();
      return;
    }
    final subItems = _ensureDrawerController().inventorySubItems;
    if (subItems.isEmpty) {
      showNoAccessDialog();
      return;
    }
    _showQuickActionSubSheet(
      context,
      title: 'drawer.inventory'.trns(),
      items: subItems,
      onSelected: (item) {
        switch (item) {
          case 'Services':
            try {
              Get.find<BottomnavController>().changeTabIndex(2);
            } catch (_) {
              Get.toNamed(Routes.SERVICES);
            }
            break;
          case 'Service Categories':
            Get.toNamed(Routes.SERVICE_CATEGORIES);
            break;
          case 'Packages':
            Get.toNamed(Routes.PACKAGES);
            break;
          case 'Products':
            Get.toNamed(Routes.PRODUCTS);
            break;
          case 'Brands':
            Get.toNamed(Routes.BRANDS);
            break;
          case 'Product Categories':
            Get.toNamed(Routes.PRODUCT_CATEGORIES);
            break;
          case 'Tags':
            Get.toNamed(Routes.TAGS);
            break;
          case 'Units':
            Get.toNamed(Routes.UNITS);
            break;
          case 'Variations':
            Get.toNamed(Routes.VARIATIONS);
            break;
        }
      },
    );
  }

  void _onPaymentsTap() {
    if (!Permissions.can(AppPerm.index(AppPerm.payments))) {
      showNoAccessDialog();
      return;
    }
    Get.toNamed(Routes.PAYMENTS);
  }

  void _onCustomersTap() {
    if (!Permissions.can(AppPerm.index(AppPerm.customers))) {
      showNoAccessDialog();
      return;
    }
    Get.toNamed(Routes.CUSTOMERS);
  }

  void _onReportingTap(BuildContext context) {
    if (!Get.find<AuthService>().isOwner) {
      showNoAccessDialog();
      return;
    }
    final subItems = _ensureDrawerController().reportingSubItems;
    _showQuickActionSubSheet(
      context,
      title: 'drawer.reporting'.trns(),
      items: subItems,
      onSelected: (item) {
        switch (item) {
          case 'Branch Comparison':
            Get.toNamed(Routes.BRANCH_COMPARISON_REPORT);
            break;
          case 'Revenue Report':
            Get.toNamed(Routes.REVENUE_REPORT);
            break;
          case 'Services Revenue Report':
            Get.toNamed(Routes.SERVICE_REVENUE_REPORT);
            break;
          case 'Products Revenue Report':
            Get.toNamed(Routes.PRODUCT_REVENUE_REPORT);
            break;
          case 'Packages Revenue Report':
            Get.toNamed(Routes.PACKAGE_REVENUE_REPORT);
            break;
          case 'Commissions Report':
            Get.toNamed(Routes.COMMISSIONS_REPORT);
            break;
          case 'Expenses Report':
            Get.toNamed(Routes.EXPENSE_REPORT);
            break;
          case 'Customers Report':
            Get.toNamed(Routes.CUSTOMER_REPORT);
            break;
        }
      },
    );
  }

  void _onDailyClosingTap() {
    if (!Permissions.can(AppPerm.index(AppPerm.dailyClosings))) {
      showNoAccessDialog();
      return;
    }
    Get.toNamed(Routes.DAILY_CLOSINGS);
  }

  void _showQuickActionSubSheet(
    BuildContext context, {
    required String title,
    required List<String> items,
    required void Function(String) onSelected,
  }) {
    if (items.length == 1) {
      onSelected(items.first);
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: _rs(context, 12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.indicatorInactive,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _rs(context, 20),
                    vertical: _rs(context, 6),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: _rs(context, 16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const Divider(color: AppColors.dividerColor),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: Color(0xFFF3F4F6),
                    ),
                    itemBuilder: (_, i) {
                      final sub = items[i];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: _rs(context, 20),
                        ),
                        title: Text(
                          sub,
                          style: TextStyle(
                            fontSize: _rs(context, 14),
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.lightGrey,
                          size: 20,
                        ),
                        onTap: () {
                          Navigator.of(sheetCtx).pop();
                          onSelected(sub);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _rs(context, 16),
        _rs(context, 22),
        _rs(context, 16),
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: _rs(context, 16.5),
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: _rs(context, 12)),
          GridView.count(
            padding: EdgeInsets.zero,
            crossAxisCount: 3,
            mainAxisSpacing: _rs(context, 10),
            crossAxisSpacing: _rs(context, 10),
            childAspectRatio: 1.25,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _QuickActionTile(
                label: 'Booking',
                assetPath: _HomeAssets.qaBooking,
                fallbackIcon: Icons.calendar_today_outlined,
                onTap: () => _onBookingTap(context),
              ),
              _QuickActionTile(
                label: 'Inventory',
                assetPath: _HomeAssets.qaInventory,
                fallbackIcon: Icons.inventory_2_outlined,
                onTap: () => _onInventoryTap(context),
              ),
              _QuickActionTile(
                label: 'Payments',
                assetPath: _HomeAssets.qaPayments,
                fallbackIcon: Icons.credit_card_outlined,
                onTap: _onPaymentsTap,
              ),
              _QuickActionTile(
                label: 'Customers',
                assetPath: _HomeAssets.qaCustomers,
                fallbackIcon: Icons.groups_outlined,
                onTap: _onCustomersTap,
              ),
              _QuickActionTile(
                label: 'Reporting',
                assetPath: _HomeAssets.qaReporting,
                fallbackIcon: Icons.bar_chart_rounded,
                onTap: () => _onReportingTap(context),
              ),
              _QuickActionTile(
                label: 'Daily Closing',
                assetPath: _HomeAssets.qaDailyClosing,
                fallbackIcon: Icons.fact_check_outlined,
                onTap: _onDailyClosingTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String label;
  final String assetPath;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.label,
    required this.assetPath,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: _rs(context, 34),
              height: _rs(context, 34),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEFE7),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: _AssetIcon(
                assetPath: assetPath,
                size: _rs(context, 17),
                color: AppColors.secondary,
                fallbackIcon: fallbackIcon,
              ),
            ),
            SizedBox(height: _rs(context, 8)),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: _rs(context, 12),
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Revenue Card (Interactive Today / Week / Month + Spline Area Graph) ────

enum _RevenuePeriod { today, week, month }

class _RevenueCard extends StatefulWidget {
  final HomeController controller;

  const _RevenueCard({required this.controller});

  @override
  State<_RevenueCard> createState() => _RevenueCardState();
}

class _RevenueCardState extends State<_RevenueCard> {
  _RevenuePeriod _selectedPeriod = _RevenuePeriod.today;

  List<SalesPoint> _filterPoints(List<SalesPoint> allPoints) {
    if (allPoints.isEmpty) return const [];

    // Sort chronologically if dates are valid
    final sorted = List<SalesPoint>.from(allPoints);
    sorted.sort((a, b) {
      final da = DateTime.tryParse(a.date);
      final db = DateTime.tryParse(b.date);
      if (da == null || db == null) return 0;
      return da.compareTo(db);
    });

    final latestDate =
        DateTime.tryParse(sorted.last.date) ?? DateTime.now();

    switch (_selectedPeriod) {
      case _RevenuePeriod.today:
        final todayStr =
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
        final todayMatches =
            sorted.where((p) => p.date.startsWith(todayStr)).toList();
        if (todayMatches.isNotEmpty) return todayMatches;
        return [sorted.last];
      case _RevenuePeriod.week:
        final cutoff = latestDate.subtract(const Duration(days: 7));
        final weekPoints = sorted.where((p) {
          final d = DateTime.tryParse(p.date);
          return d == null || !d.isBefore(cutoff);
        }).toList();
        return weekPoints.isEmpty ? sorted : weekPoints;
      case _RevenuePeriod.month:
        final cutoff = latestDate.subtract(const Duration(days: 30));
        final monthPoints = sorted.where((p) {
          final d = DateTime.tryParse(p.date);
          return d == null || !d.isBefore(cutoff);
        }).toList();
        return monthPoints.isEmpty ? sorted : monthPoints;
    }
  }

  int _calculateGrowthPercent(List<SalesPoint> points) {
    if (points.length < 2) return 0;
    final first = points.first.total;
    final last = points.last.total;
    if (first <= 0) return last > 0 ? 100 : 0;
    return (((last - first) / first) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.controller.isLoadingHome) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            _rs(context, 16),
            _rs(context, 20),
            _rs(context, 16),
            0,
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: _rs(context, 155),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        );
      }

      final home = widget.controller.home;
      if (home == null) return const SizedBox.shrink();

      final filteredPoints = _filterPoints(home.salesData);
      final double periodTotal = filteredPoints.fold<double>(
        0,
        (sum, p) => sum + p.total,
      );
      final int growth = _calculateGrowthPercent(
        filteredPoints.length >= 2 ? filteredPoints : home.salesData,
      );

      // For smooth curve plotting, use filtered points if >= 2, else all points
      final List<SalesPoint> chartPoints = filteredPoints.length >= 2
          ? filteredPoints
          : home.salesData;

      return Container(
        margin: EdgeInsets.fromLTRB(
          _rs(context, 16),
          _rs(context, 20),
          _rs(context, 16),
          0,
        ),
        padding: EdgeInsets.all(_rs(context, 16)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon + Title + Period Switcher
            Row(
              children: [
                Container(
                  width: _rs(context, 38),
                  height: _rs(context, 38),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: _AssetIcon(
                    assetPath: _HomeAssets.revenueChart,
                    size: _rs(context, 18),
                    color: AppColors.white,
                    fallbackIcon: Icons.bar_chart_rounded,
                  ),
                ),
                SizedBox(width: _rs(context, 10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'home.revenue.title'.trns(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: _rs(context, 15.5),
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        'Total sales overview',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: _rs(context, 11),
                          color: AppColors.lightGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                _PeriodSelector(
                  selected: _selectedPeriod,
                  onChanged: (period) {
                    setState(() => _selectedPeriod = period);
                  },
                ),
              ],
            ),
            SizedBox(height: _rs(context, 16)),

            // Bottom Row: Amount + Growth Badge on Left, Spline Area Chart on Right
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs ${_fullNumber(periodTotal)}',
                      style: TextStyle(
                        fontSize: _rs(context, 24),
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: _rs(context, 10)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _rs(context, 6),
                            vertical: _rs(context, 3),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F7EE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${growth >= 0 ? '↗' : '↘'} ${growth.abs()}%',
                            style: TextStyle(
                              fontSize: _rs(context, 10),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                        SizedBox(width: _rs(context, 6)),
                        Text(
                          'vs. last period',
                          style: TextStyle(
                            fontSize: _rs(context, 10.5),
                            color: AppColors.lightGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: _rs(context, 12)),
                Expanded(
                  child: SizedBox(
                    height: _rs(context, 70),
                    child: _RevenueSplineChart(points: chartPoints),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _PeriodSelector extends StatelessWidget {
  final _RevenuePeriod selected;
  final ValueChanged<_RevenuePeriod> onChanged;

  const _PeriodSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab(context, 'Today', _RevenuePeriod.today),
          _buildTab(context, 'Week', _RevenuePeriod.week),
          _buildTab(context, 'Month', _RevenuePeriod.month),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, _RevenuePeriod period) {
    final bool isSelected = selected == period;
    return GestureDetector(
      onTap: () => onChanged(period),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: _rs(context, 10),
          vertical: _rs(context, 5),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: _rs(context, 10.5),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.onboardingMuted,
          ),
        ),
      ),
    );
  }
}

class _RevenueSplineChart extends StatelessWidget {
  final List<SalesPoint> points;

  const _RevenueSplineChart({required this.points});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SplineAreaPainter(points: points),
      size: Size.infinite,
    );
  }
}

class _SplineAreaPainter extends CustomPainter {
  final List<SalesPoint> points;

  _SplineAreaPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Extract normalized heights [0.0 .. 1.0].
    // When empty or all zero, use the exact Figma silhouette curve so it looks
    // identical to the design even on Rs 0.
    List<double> norm;
    final rawValues = points.map((e) => e.total).toList();
    final maxVal = rawValues.fold<double>(0, math.max);

    if (rawValues.length >= 2 && maxVal > 0) {
      norm = rawValues.map((v) => (v / maxVal).clamp(0.08, 0.92)).toList();
      // Add subtle lead-in and lead-out points so the curve touches both edges
      norm = [
        (norm.first * 0.4).clamp(0.04, 0.9),
        ...norm,
        (norm.last * 1.05).clamp(0.1, 0.95),
      ];
    } else {
      norm = const [0.04, 0.22, 0.44, 0.36, 0.78, 0.85];
    }

    final double topPad = 6.0;
    final double bottomPad = 4.0;
    final double plotH = size.height - topPad - bottomPad;
    final int count = norm.length;
    final double stepX = size.width / (count - 1);

    final List<Offset> coords = List.generate(count, (i) {
      final double x = i * stepX;
      final double y = topPad + plotH * (1.0 - norm[i]);
      return Offset(x, y);
    });

    // Build smooth cubic Bezier path
    final Path linePath = Path()..moveTo(coords.first.dx, coords.first.dy);
    for (int i = 0; i < coords.length - 1; i++) {
      final Offset p0 = coords[i];
      final Offset p1 = coords[i + 1];
      final double controlX1 = p0.dx + (p1.dx - p0.dx) * 0.45;
      final double controlX2 = p0.dx + (p1.dx - p0.dx) * 0.55;
      linePath.cubicTo(controlX1, p0.dy, controlX2, p1.dy, p1.dx, p1.dy);
    }

    // Build closed area path for gradient fill
    final Path areaPath = Path.from(linePath)
      ..lineTo(coords.last.dx, size.height - bottomPad)
      ..lineTo(coords.first.dx, size.height - bottomPad)
      ..close();

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.secondary.withValues(alpha: 0.38),
          AppColors.secondary.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = AppColors.secondary;

    canvas.drawPath(areaPath, fillPaint);
    canvas.drawPath(linePath, strokePaint);

    // Draw circular nodes on interior points (matching the 4 dots in Figma)
    final Paint dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.secondary;

    for (int i = 1; i < coords.length - 1; i++) {
      canvas.drawCircle(coords[i], 3.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplineAreaPainter oldDelegate) =>
      oldDelegate.points != points;
}

// ─── Number / Date Formatting ───────────────────────────────────────────────

/// 1750 → "1,750"; 1750.5 → "1,750.50".
String _fullNumber(double v) {
  final parts =
      (v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2))
          .split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
}

/// "2026-10-14" → "Oct 14" (shared helper format minus the year).
// ignore: unused_element
String _shortDate(String dateStr) {
  if (dateStr.isEmpty) return '';
  final parsed = DateTime.tryParse(dateStr);
  if (parsed == null) return dateStr;
  return reportHumanDate(parsed).split(',').first;
}

// ─── Today Booking Header ───────────────────────────────────────────────────

class _TodayBookingHeader extends StatelessWidget {
  final HomeController controller;

  const _TodayBookingHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _rs(context, 16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              '${'home.todayBooking'.trns()} (${controller.todayBookings.length})',
              style: TextStyle(
                fontSize: _rs(context, 16.5),
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ),
          Can(
            AppPerm.index(AppPerm.bookings),
            child: GestureDetector(
              onTap: controller.openAllBookings,
              child: Text(
                'home.viewAll'.trns(),
                style: TextStyle(
                  fontSize: _rs(context, 13.5),
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer / Empty / Error ────────────────────────────────────────────────

class _BookingShimmerList extends StatelessWidget {
  const _BookingShimmerList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 210,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 56,
              color: Color(0xFFCCCCCC),
            ),
            const SizedBox(height: 12),
            Text(
              'home.booking.empty'.trns() == 'home.booking.empty'
                  ? 'No bookings for today'
                  : 'home.booking.empty'.trns(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _HomeErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 52, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 12),
            const Text(
              'Failed to load bookings.\nPull to refresh or try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
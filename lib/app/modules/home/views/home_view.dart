// lib/app/modules/home/views/home_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:va_bookats/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:va_bookats/app/modules/home/controllers/home_controller.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'dart:math' as math;

import 'package:va_bookats/app/modules/home/models/home_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/booking_card.dart';
import 'package:va_bookats/widgets/Global-Widgets/booking_status_sheet.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            _HomeHeader(controller: controller),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.secondary,
                onRefresh: controller.handleRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HomeInsights(controller: controller),
                      SizedBox(height: 24),
                      _TodayBookingHeader(controller: controller),
                      Obx(() {
                        if (controller.isLoading.value) {
                          return const _BookingShimmerList();
                        }
                        if (controller.loadFailed.value &&
                            controller.todayBookings.isEmpty) {
                          return _HomeErrorState(onRetry: controller.retry);
                        }
                        if (controller.todayBookings.isEmpty) {
                          return const _HomeEmptyState();
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.todayBookings.length,
                          itemBuilder: (context, index) {
                            final booking = controller.todayBookings[index];
                            return Obx(
                              () => BookingCard(
                                booking: booking,
                                isBusy:
                                    controller.busyBookingId.value ==
                                    booking.id,
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
                      const SizedBox(height: 24),
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
      onConfirmed:
          ({
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

// ─── Header Widget ──────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final HomeController controller;

  const _HomeHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.find<BottomnavController>().openDrawer(),
                    child: const Icon(
                      Icons.menu,
                      color: AppColors.white,
                      size: 26,
                    ),
                  ),
                  Row(
                    children: [
                      // Stack(
                      //   children: [
                      //     GestureDetector(
                      //       onTap: () {},
                      //       child: const Icon(
                      //         Icons.notifications_outlined,
                      //         color: AppColors.white,
                      //         size: 26,
                      //       ),
                      //     ),
                      //     Positioned(
                      //       right: 0,
                      //       top: 0,
                      //       child: Container(
                      //         width: 8,
                      //         height: 8,
                      //         decoration: const BoxDecoration(
                      //           color: AppColors.white,
                      //           shape: BoxShape.circle,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(width: 14),
                      Obx(() {
                        final img = controller.auth.currentUser.value;
                        return GestureDetector(
                          onTap: () => Get.toNamed(Routes.PERSONAL_INFO),
                          child: ClipOval(
                            child: AppCachedImage(
                              imageUrl:
                                  img?.bestImageUrl ?? img?.bestImageThumbUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Greeting
              Text(
                'home.greeting'.trns(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Obx(() {
                final name = controller.userName;
                final subtitle = 'home.greetingSubtitle'.trns();
                return Text(
                  name.isEmpty ? subtitle : '$subtitle\n$name',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Search bar → navigates to AllBookings with search focused
              GestureDetector(
                onTap: controller.openSearch,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'home.searchHint'.trns(),
                          style: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.search,
                        color: Color(0xFFAAAAAA),
                        size: 20,
                      ),
                    ],
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

// ─── Quick Menu Grid ────────────────────────────────────────────────────────

// ─── Home Insights (booking stat cards + revenue graph) ─────────────────────
// The old non-functional menu tiles are now live stat cards fed by
// GET /home; the revenue graph sits beneath them. Display-only —
// no tap handling except the Total card (booking entry point).

class _HomeInsights extends StatelessWidget {
  final HomeController controller;

  const _HomeInsights({required this.controller});

  @override
  Widget build(BuildContext context) {
    return
    // Can(
    //   AppPerm.index(AppPerm.bookings),
    //   child:
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatsGrid(controller: controller),
        _RevenueCard(controller: controller),
      ],
    );
    // );
  }
}

class _StatsGrid extends StatelessWidget {
  final HomeController controller;

  const _StatsGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingHome) return _statsShimmer();
      final home = controller.home;
      if (home == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.33,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
              value: '${home.totalBookings}',
              label: 'home.stats.totalBookings'.trns(),
              icon: Icons.calendar_today_rounded,
              background: AppColors.secondary,
              foreground: AppColors.white,
              subColor: AppColors.white.withValues(alpha: 0.75),
              onTap: controller.openAllBookings,
            ),
            _StatCard(
              value: '${home.pendingBookings}',
              label: 'home.stats.pendingBookings'.trns(),
              icon: Icons.schedule_outlined,
              background: AppColors.white,
              foreground: AppColors.black,
              subColor: const Color(0xFF888888),
              accent: const Color(0xFFF57F00),
            ),
            _StatCard(
              value: '${home.completedBookings}',
              label: 'home.stats.completedBookings'.trns(),
              icon: Icons.check_circle_outline_rounded,
              background: AppColors.white,
              foreground: AppColors.black,
              subColor: const Color(0xFF888888),
              accent: const Color(0xFF2E7D32),
            ),
            _StatCard(
              value: '${home.cancelledBookings}',
              label: 'home.stats.cancelledBookings'.trns(),
              icon: Icons.cancel_outlined,
              background: AppColors.white,
              foreground: AppColors.black,
              subColor: const Color(0xFF888888),
              accent: const Color(0xFFC62828),
            ),
          ],
        ),
      );
    });
  }

  Widget _statsShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GridView.count(
        padding: EdgeInsets.zero,
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          4,
          (_) => Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color subColor;
  final Color? accent;
  final VoidCallback? onTap;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.subColor,
    this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconBg = accent != null
        ? accent!.withValues(alpha: 0.12)
        : AppColors.white.withValues(alpha: 0.25);
    final iconFg = accent ?? AppColors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: accent == null
              ? null
              : Border.all(color: const Color(0xFFEEEEEE), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w900,
                    color: foreground,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: subColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Spacer(),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconFg, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Revenue Graph Card ─────────────────────────────────────────────────────

class _RevenueCard extends StatelessWidget {
  final HomeController controller;

  const _RevenueCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingHome) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }
      final home = controller.home;
      if (home == null) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'home.revenue.title'.trns(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  _fullNumber(home.totalSales),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            if (home.salesData.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${_shortDate(home.salesData.first.date)} — ${_shortDate(home.salesData.last.date)}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
            ],
            const SizedBox(height: 12),
            if (home.salesData.isEmpty)
              SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'home.revenue.noData'.trns(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              )
            else
              _RevenueBars(points: home.salesData),
          ],
        ),
      );
    });
  }
}

class _RevenueBars extends StatelessWidget {
  final List<SalesPoint> points;

  const _RevenueBars({required this.points});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.max(constraints.maxWidth, points.length * 48.0);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: width,
            height: 190,
            child: CustomPaint(painter: _BarsPainter(points: points)),
          ),
        );
      },
    );
  }
}

class _BarsPainter extends CustomPainter {
  final List<SalesPoint> points;

  static const double _leftPad = 40.0;
  static const double _rightPad = 8.0;
  static const double _topPad = 12.0;
  static const double _bottomPad = 24.0;

  _BarsPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final values = points.map((p) => p.total).toList();
    final maxV = values.fold<double>(0, math.max);
    final plotW = size.width - _leftPad - _rightPad;
    final plotH = size.height - _topPad - _bottomPad;

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    // Gridlines + Y labels.
    for (var i = 0; i <= 3; i++) {
      final frac = i / 3;
      final y = _topPad + plotH * (1 - frac);
      canvas.drawLine(
        Offset(_leftPad, y),
        Offset(size.width - _rightPad, y),
        gridPaint,
      );
      _drawLabel(
        canvas,
        _compactNumber(maxV * frac),
        Offset(0, y - 9),
        _leftPad - 6,
      );
    }

    if (values.isEmpty || maxV <= 0) return;

    // Bars.
    final n = values.length;
    final slot = plotW / n;
    final barW = math.min(slot * 0.55, 34.0);
    for (var i = 0; i < n; i++) {
      final h = (values[i] / maxV) * plotH;
      if (h <= 0) continue;
      final x = _leftPad + slot * i + (slot - barW) / 2;
      final y = _topPad + plotH - h;
      final isMax = values[i] == maxV;
      final paint = Paint()
        ..color = isMax
            ? AppColors.primary
            : AppColors.secondary.withValues(alpha: 0.75);
      final radius = Radius.circular(math.min(6.0, h / 2));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, barW, h), radius),
        paint,
      );
    }

    // X labels (up to 4, spread across the range).
    for (final i in _labelIndices(n)) {
      final x = _leftPad + slot * i + slot / 2;
      _drawLabel(
        canvas,
        _shortDate(points[i].date),
        Offset(x - 32, size.height - _bottomPad + 6),
        64,
        alignCenter: true,
      );
    }
  }

  List<int> _labelIndices(int n) {
    if (n <= 4) return [for (var i = 0; i < n; i++) i];
    final out = <int>[];
    for (final i in [0, n ~/ 3, (2 * n) ~/ 3, n - 1]) {
      if (!out.contains(i)) out.add(i);
    }
    out.sort();
    return out;
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset offset,
    double width, {
    bool alignCenter = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: width);
    final dx = alignCenter
        ? offset.dx + (width - painter.width) / 2
        : offset.dx + (width - painter.width);
    painter.paint(canvas, Offset(dx, offset.dy));
    painter.dispose();
  }

  @override
  bool shouldRepaint(covariant _BarsPainter old) => old.points != points;
}

// ─── Number / date formatting ───────────────────────────────────────────────

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

/// Axis-friendly: 1500000 → "1.5M", 1750 → "1.8K", 500 → "500".
String _compactNumber(double v) {
  if (v >= 1000000) return '${_trim1(v / 1000000)}M';
  if (v >= 1000) return '${_trim1(v / 1000)}K';
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(2);
}

String _trim1(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

/// "2026-10-14" → "Oct 14" (shared helper format minus the year).
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              '${'home.todayBooking'.trns()} (${controller.todayBookings.length})',
              style: const TextStyle(
                fontSize: 16,
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
                style: const TextStyle(
                  fontSize: 13,
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

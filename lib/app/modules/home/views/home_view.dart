// lib/app/modules/home/views/home_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:va_bookats/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:va_bookats/app/modules/home/controllers/home_controller.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/booking_card.dart';
import 'package:va_bookats/widgets/Global-Widgets/booking_status_sheet.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    _QuickMenuGrid(),
                    _TodayBookingHeader(controller: controller),
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
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.todayBookings.length,
                        itemBuilder: (context, index) {
                          final booking = controller.todayBookings[index];
                          return Obx(() => BookingCard(
                                booking: booking,
                                isBusy:
                                    controller.busyBookingId.value ==
                                        booking.id,
                                onViewDetails: () =>
                                    controller.openDetails(booking),
                                onEdit: () => _openEdit(booking),
                                onStatusTap: () =>
                                    _showStatusSheet(context, booking),
                              ));
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
                        final img =
                            controller.userImage;
                        return ClipOval(
                          child: AppCachedImage(
                            imageUrl: img,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
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

class _QuickMenuGrid extends StatelessWidget {
  const _QuickMenuGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem(
        label: 'home.menu.booking'.trns(),
        icon: Icons.calendar_today_rounded,
        isActive: true,
        onTap: () => Get.toNamed(Routes.ALL_BOOKING),
      ),
      _MenuItem(
        label: 'home.menu.inventory'.trns(),
        icon: Icons.credit_card_outlined,
        isActive: false,
        onTap: () {},
      ),
      _MenuItem(
        label: 'home.menu.user'.trns(),
        icon: Icons.group_outlined,
        isActive: false,
        onTap: () {},
      ),
      _MenuItem(
        label: 'home.menu.reporting'.trns(),
        icon: Icons.description_outlined,
        isActive: false,
        onTap: () {},
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: GridView.count(
        padding: EdgeInsets.zero,
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: items
            .map(
              (item) => _MenuCard(item: item),
            )
            .toList(),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  _MenuItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;

  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: item.isActive ? AppColors.secondary : AppColors.white,
          borderRadius: BorderRadius.circular(50),
          border: item.isActive
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.isActive
                    ? AppColors.white.withValues(alpha: 0.25)
                    : AppColors.secondary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: item.isActive ? AppColors.white : AppColors.secondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: item.isActive ? AppColors.white : const Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
          GestureDetector(
            onTap: () => Get.toNamed(Routes.ALL_BOOKING,
                arguments: {'autoFocusSearch': false}),
            
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
            const Icon(Icons.calendar_today_outlined,
                size: 56, color: Color(0xFFCCCCCC)),
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
            const Icon(Icons.error_outline,
                size: 52, color: Color(0xFFCCCCCC)),
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
                    horizontal: 26, vertical: 11),
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

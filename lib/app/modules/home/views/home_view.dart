// lib/app/modules/home/views/home_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/home/controllers/home_controller.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/booking_card.dart';
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _QuickMenuGrid(),
                  const SizedBox(height: 20),
                  _TodayBookingHeader(controller: controller),
                  const SizedBox(height: 8),
                  Obx(
                    () => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.todayBookings.length,
                      itemBuilder: (context, index) {
                        return BookingCard(
                          booking: controller.todayBookings[index],
                          onViewDetails: () {
                            Get.toNamed(Routes.BOOKING_DETAILS);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
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
                    onTap: () {},
                    child: const Icon(
                      Icons.menu,
                      color: AppColors.white,
                      size: 26,
                    ),
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.white,
                              size: 26,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      ClipOval(
                        child: AppCachedImage(
                          imageUrl: controller.vendorProfileImage,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
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
              Text(
                'home.greetingSubtitle'.trns(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),

              // Search bar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  onChanged: (v) => controller.searchQuery.value = v,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'home.searchHint'.trns(),
                    hintStyle: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 13,
                    ),
                    suffixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFAAAAAA),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
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
            onTap: () => Get.toNamed(Routes.ALL_BOOKING),
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
// lib/app/modules/all_booking/views/all_booking_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:va_bookats/app/modules/allBooking/controllers/all_booking_controller.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/booking_card.dart';
import 'package:va_bookats/widgets/Global-Widgets/booking_status_sheet.dart';

class AllBookingView extends GetView<AllBookingController> {
  const AllBookingView({super.key});

  /// Standalone route (`/all-booking`) vs embedded bottom-nav page.
  /// Embedded → hide the header search toggle (home drives search);
  /// standalone → show the back button.
  bool get _isStandalone => Get.currentRoute == Routes.ALL_BOOKING;

  @override
  Widget build(BuildContext context) {
    // Never mutate Rx state synchronously inside build — that throws
    // "setState() or markNeedsBuild() called during build". Handle the
    // incoming `autoFocusSearch` arg (and bottom-nav reuse) post-frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isClosed) return;
      controller.handleIncomingArgs();
    });
    final isStandalone = _isStandalone;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _AllBookingHeader(
            controller: controller,
            showBack: isStandalone,
            showSearchToggle: isStandalone,
          ),
          Obx(
            () => controller.isSearchOpen.value
                ? _SearchBar(controller: controller)
                : const SizedBox.shrink(),
          ),
          Obx(
            () => controller.isSearching
                ? _SearchResultsHeader(controller: controller)
                : _TabBar(controller: controller),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.currentBookings.isEmpty) {
                return const _ListShimmer();
              }
              if (controller.loadFailed.value &&
                  controller.currentBookings.isEmpty) {
                return _ErrorState(onRetry: controller.retry);
              }
              if (controller.currentBookings.isEmpty) {
                return const _EmptyState();
              }
              return RefreshIndicator(
                color: AppColors.secondary,
                onRefresh: controller.handleRefresh,
                child: ListView.builder(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount:
                      controller.currentBookings.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= controller.currentBookings.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                    final booking = controller.currentBookings[index];
                    return Obx(
                      () => BookingCard(
                        booking: booking,
                        isBusy: controller.busyBookingId.value == booking.id,
                        onViewDetails: () => controller.openDetails(booking),
                        onEdit: () => controller.openCreate(booking: booking),
                        onStatusTap: () => _showStatusSheet(context, booking),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _showStatusSheet(BuildContext context, BookingModel booking) {
    BookingStatusSheet.show(
      context,
      currentStatus: booking.status,
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

// ─── Header ─────────────────────────────────────────────────────────────────

class _AllBookingHeader extends StatelessWidget {
  final AllBookingController controller;
  final bool showBack;
  final bool showSearchToggle;

  const _AllBookingHeader({
    required this.controller,
    this.showBack = false,
    this.showSearchToggle = true,
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
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showBack)
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.white,
                    size: 20,
                  ),
                )
              else
                const SizedBox(width: 88),
              Expanded(
                child: Text(
                  'home.booking.title'.trns(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (showSearchToggle)
                Obx(
                  () => GestureDetector(
                    onTap: () => controller.toggleSearch(),
                    child: Icon(
                      controller.isSearchOpen.value
                          ? Icons.close
                          : Icons.search,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                ),
              if (showSearchToggle) const SizedBox(width: 12),
              GestureDetector(
                onTap: () => controller.openFilter(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.filter_alt_outlined,
                      color: AppColors.white,
                      size: 22,
                    ),
                    Obx(() {
                      final n = controller.appliedFiltersCount;
                      if (n == 0) return const SizedBox.shrink();
                      return Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$n',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => controller.openCreate(),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.white,
                    size: 20,
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

// ─── Search Bar (collapsible) ───────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final AllBookingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 20, color: Color(0xFF888888)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.searchCtrl,
                focusNode: controller.searchFocus,
                autofocus: false,
                onChanged: controller.onSearchChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14, color: AppColors.black),
                decoration: InputDecoration(
                  hintText: 'Search bookings...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAAAAAA),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  suffixIcon: Obx(
                    () => controller.searchQuery.value.isEmpty
                        ? const SizedBox.shrink()
                        : GestureDetector(
                            onTap: () {
                              controller.searchCtrl.clear();
                              controller.onSearchChanged('');
                            },
                            child: const Icon(
                              Icons.clear,
                              size: 18,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
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

class _SearchResultsHeader extends StatelessWidget {
  final AllBookingController controller;

  const _SearchResultsHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(
        () => Text(
          'Results (${controller.searchResults.length}) — all statuses',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}

// ─── Tab Bar ─────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final AllBookingController controller;

  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      BookingStatus.pending,
      BookingStatus.completed,
      BookingStatus.cancelled,
    ];

    return Container(
      color: AppColors.white,
      child: Obx(
        () => Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final count = switch (index) {
              0 => controller.pendingCount,
              1 => controller.completedCount,
              _ => controller.cancelledCount,
            };
            final isSelected = controller.selectedTab.value == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => controller.changeTab(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? AppColors.secondary
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Text(
                    '$label ($count)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.secondary
                          : const Color(0xFF888888),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── States ──────────────────────────────────────────────────────────────────

class _ListShimmer extends StatelessWidget {
  const _ListShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      itemCount: 4,
      shrinkWrap: true,
      itemBuilder: (_, __) => Padding(
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
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 56,
              color: Color(0xFFCCCCCC),
            ),
            SizedBox(height: 12),
            Text(
              'No bookings found',
              style: TextStyle(
                fontSize: 15,
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

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Color(0xFFCCCCCC)),
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

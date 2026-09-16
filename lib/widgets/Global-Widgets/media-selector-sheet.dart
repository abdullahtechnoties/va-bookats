import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/mediaLibrary/controllers/media_library_controller.dart';
import 'package:va_bookats/app/modules/mediaLibrary/repositories/media_repository.dart';
import 'package:va_bookats/app/modules/mediaLibrary/views/media_library_view.dart';
import 'package:va_bookats/utilities/colors.dart';

/// Call this anywhere to open the media selector sheet.
/// Returns selected [MediaItem] list via [onConfirmed] callback.
///
/// - [allowMultiple]: false = single-select (profile/service image).
/// - [initialSelectedIds]: pre-check already-chosen media ids.
class MediaSelectorSheet {
  MediaSelectorSheet._();

  static void show(
    BuildContext context, {
    required Function(List<MediaItem>) onConfirmed,
    bool allowMultiple = true,
    List<int> initialSelectedIds = const [],
  }) {
    final MediaRepository repository;
    if (Get.isRegistered<MediaRepository>()) {
      repository = Get.find<MediaRepository>();
    } else {
      repository = MediaRepository();
    }

    final tag = 'sheet_${DateTime.now().millisecondsSinceEpoch}';
    final ctrl = Get.put(
      MediaLibraryController(
        onSelectionConfirmed: onConfirmed,
        isSheetMode: true,
        allowMultiple: allowMultiple,
        initialSelectedIds: initialSelectedIds,
        repository: repository,
      ),
      tag: tag,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MediaSelectorSheetContent(controller: ctrl),
    ).whenComplete(() {
      // Dispose the tagged sheet controller so repeated opens never leak or
      // reuse stale selections.
      if (Get.isRegistered<MediaLibraryController>(tag: tag)) {
        Get.delete<MediaLibraryController>(tag: tag);
      }
    });
  }
}

class _MediaSelectorSheetContent extends StatelessWidget {
  final MediaLibraryController controller;

  const _MediaSelectorSheetContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Sheet Handle + Header ────────────────────────────────────
          _SheetHeader(controller: controller),

          // ── Body ────────────────────────────────────────────────────
          Expanded(
            child: MediaLibraryBody(
              controller: controller,
              isSheet: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sheet Header ───────────────────────────────────────────────────────────────
class _SheetHeader extends StatelessWidget {
  final MediaLibraryController controller;

  const _SheetHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Handle bar
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

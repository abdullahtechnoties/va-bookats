import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/mediaLibrary/controllers/media_library_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';
import 'package:va_bookats/widgets/main_btn.dart';

/// Full-screen Media Library page
class MediaLibraryView extends GetView<MediaLibraryController> {
  const MediaLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context),
      body: MediaLibraryBody(controller: controller),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.chevron_left,
              color: AppColors.white, size: 28),
        ),
      ),
      title: Text(
        'mediaLibrary.title'.trns(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => _showSearch(context),
            child: const Icon(Icons.search,
                color: AppColors.white, size: 24),
          ),
        ),
      ],
    );
  }

  void _showSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _SearchDialog(controller: controller),
    );
  }
}

// ── Shared body (used in both full-screen and sheet) ─────────────────────────
class MediaLibraryBody extends StatelessWidget {
  final MediaLibraryController controller;
  final bool isSheet;

  const MediaLibraryBody({super.key, 
    required this.controller,
    this.isSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upload zone
                _UploadZone(controller: controller),
                const SizedBox(height: 24),
                // Recent files label
                Text(
                  'mediaLibrary.recentFile'.trns(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 12),
                // Grid
                Obx(() {
                  final items = controller.filteredItems;
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) => _MediaGridItem(
                      item: items[i],
                      controller: controller,
                      isSheet: isSheet,
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ── Sheet mode: selection detail + action buttons ────────────────
        if (isSheet) ...[
          Obx(() {
            final sel = controller.firstSelected;
            if (sel == null) return const SizedBox.shrink();
            return _SelectionDetail(item: sel, controller: controller);
          }),
          _SheetActionButtons(controller: controller),
        ],
      ],
    );
  }
}

// ── Upload Zone ────────────────────────────────────────────────────────────────
class _UploadZone extends StatelessWidget {
  final MediaLibraryController controller;

  const _UploadZone({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showUploadOptions(context),
      child: Obx(() => Container(
            width: double.infinity,
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD1D5DB),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: controller.isUploading.value
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(
                                AppColors.primary),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Uploading...',
                            style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280))),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image_outlined,
                          size: 44, color: Color(0xFF9CA3AF)),
                      const SizedBox(height: 8),
                      Text(
                        'mediaLibrary.uploadImage'.trns(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
          )),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _UploadOptionsSheet(controller: controller),
    );
  }
}

// ── Upload Options Sheet ───────────────────────────────────────────────────────
class _UploadOptionsSheet extends StatelessWidget {
  final MediaLibraryController controller;

  const _UploadOptionsSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
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
            const SizedBox(height: 20),
            Text(
              'mediaLibrary.selectSource'.trns(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SourceOption(
                    icon: Icons.photo_library_outlined,
                    label: 'mediaLibrary.gallery'.trns(),
                    onTap: () {
                      Get.back();
                      controller.uploadFromGallery();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SourceOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'mediaLibrary.camera'.trns(),
                    onTap: () {
                      Get.back();
                      controller.uploadFromCamera();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Media Grid Item ────────────────────────────────────────────────────────────
class _MediaGridItem extends StatelessWidget {
  final MediaItem item;
  final MediaLibraryController controller;
  final bool isSheet;

  const _MediaGridItem({
    required this.item,
    required this.controller,
    required this.isSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.isSelected(item.id);
      return GestureDetector(
        onTap: () {
          if (isSheet) {
            controller.toggleSelection(item.id);
          } else {
            // Full page: single tap = select/deselect for preview
            controller.toggleSelection(item.id);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? Border.all(color: AppColors.primary, width: 2.5)
                : null,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(selected ? 6 : 8),
                child: item.isLocal
                    ? Image.file(item.localFile!,
                        fit: BoxFit.cover)
                    : AppCachedImage(
                        imageUrl: item.networkUrl,
                        fit: BoxFit.cover,
                      ),
              ),
              if (selected)
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.check,
                        color: AppColors.white, size: 14),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Selection Detail Panel ────────────────────────────────────────────────────
class _SelectionDetail extends StatelessWidget {
  final MediaItem item;
  final MediaLibraryController controller;

  const _SelectionDetail({
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.isLocal
                    ? Image.file(item.localFile!,
                        width: 90,
                        height: 80,
                        fit: BoxFit.cover)
                    : AppCachedImage(
                        imageUrl: item.networkUrl,
                        width: 90,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                        label: 'mediaLibrary.uploaded'.trns(),
                        value: item.uploadedDate),
                    _InfoRow(
                        label: 'mediaLibrary.size'.trns(),
                        value: item.size),
                    _InfoRow(
                        label: 'mediaLibrary.dimensions'.trns(),
                        value: item.dimensions),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => controller.deleteItem(item.id),
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'mediaLibrary.deletePermanently'.trns(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '$label $value',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}

// ── Sheet Action Buttons ───────────────────────────────────────────────────────
class _SheetActionButtons extends StatelessWidget {
  final MediaLibraryController controller;

  const _SheetActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      child: Row(
        children: [
          Expanded(
            child: _OutlineBtn(
              label: 'mediaLibrary.cancel'.trns(),
              onTap: () {
                controller.clearSelection();
                Get.back();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => MainBtn(
                  text: controller.selectedIds.isEmpty
                      ? 'mediaLibrary.select'.trns()
                      : '${'mediaLibrary.selected'.trns()} (${controller.selectedIds.length})',
                  onPressed: controller.selectedIds.isEmpty
                      ? null
                      : controller.confirmSelection,
                )),
          ),
        ],
      ),
    );
  }
}

// ── Outline button ─────────────────────────────────────────────────────────────
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

// ── Search Dialog ─────────────────────────────────────────────────────────────
class _SearchDialog extends StatelessWidget {
  final MediaLibraryController controller;

  const _SearchDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.searchController,
                autofocus: true,
                onChanged: (v) => controller.searchQuery.value = v,
                decoration: InputDecoration(
                  hintText: 'mediaLibrary.searchHint'.trns(),
                  border: InputBorder.none,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                controller.searchQuery.value = '';
                controller.searchController.clear();
                Get.back();
              },
              child: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
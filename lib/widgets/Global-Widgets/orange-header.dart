import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

// --- Custom Header for these specific screens ---
class OrangeHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onFilter;
  final VoidCallback? onAdd;

  /// Active filter count badge on the filter icon (0 hides it).
  final int filterCount;

  const OrangeHeader({
    super.key,
    required this.title,
    this.onBack,
    this.onFilter,
    this.onAdd,
    this.filterCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Get.back(),
            child: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.white,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onFilter != null)
            GestureDetector(
              onTap: onFilter,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.filter_alt_outlined,
                    color: AppColors.white,
                    size: 24,
                  ),
                  if (filterCount > 0)
                    Positioned(
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
                          '$filterCount',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(width: 15),
          if (onAdd != null)
            GestureDetector(
              onTap: onAdd,
              child: const Icon(
                Icons.add_box,
                color: AppColors.white,
                size: 24,
              ),
            ),
          // Placeholder to balance the row if icons are missing on right but we want center title
          if (onFilter == null && onAdd == null) const SizedBox(width: 20),
        ],
      ),
    );
  }
}

// --- Dashed Divider ---
class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key, this.height = 1, this.color = Colors.grey});
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color.withValues(alpha: 0.3)),
              ),
            );
          }),
        );
      },
    );
  }
}

// --- Reusable Item Card (brands, categories, tags, units, variations) ---
class InventoryItemCard extends StatelessWidget {
  final String imageUrl;
  final String status;
  final String name;
  final String branch;
  final VoidCallback onDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// When set, the status badge becomes tappable (status picker).
  final VoidCallback? onStatusTap;
  final bool isBusy;
  final bool isDeleting;

  /// Laravel permissions gating each action (`null` = ungated).
  final String? detailsPermission;
  final String? editPermission;
  final String? deletePermission;
  final String? statusPermission;

  /// Hides the thumbnail box (name-only entities like tags/units).
  final bool showImage;

  /// Hides the branch row (non-owner scope).
  final bool showBranch;

  const InventoryItemCard({
    super.key,
    required this.imageUrl,
    required this.status,
    required this.name,
    required this.branch,
    required this.onDetails,
    required this.onEdit,
    required this.onDelete,
    this.onStatusTap,
    this.isBusy = false,
    this.isDeleting = false,
    this.detailsPermission,
    this.editPermission,
    this.deletePermission,
    this.statusPermission,
    this.showImage = true,
    this.showBranch = true,
  });

  bool _allowed(String? permission) =>
      permission == null || Permissions.can(permission);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Image and Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: showImage
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            children: [
              if (showImage)
                Container(
                  width: 70,
                  height: 70,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.inputBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppCachedImage(
                    imageUrl: imageUrl.isEmpty ? null : imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              if (showImage)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (onStatusTap != null && _allowed(statusPermission))
                      GestureDetector(
                        onTap: isBusy ? null : onStatusTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE3D9), // Light orange bg
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: isBusy
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      status,
                                      style: const TextStyle(
                                        color: AppColors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 14,
                                      color: AppColors.black,
                                    ),
                                  ],
                                ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE3D9), // Light orange bg
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          if (showImage)
          const SizedBox(height: 16),

          // Details Rows
          if (showImage)
            _buildInfoRow('inventory.name'.trns(), name)
          else
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    'inventory.name'.trns(),
                    style: const TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(color: AppColors.grey, fontSize: 14, overflow: TextOverflow.ellipsis),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: isBusy ? null : onStatusTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE3D9), // Light orange bg
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isBusy
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                status,
                                style: const TextStyle(
                                  color: AppColors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 14,
                                color: AppColors.black,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          if (showBranch) ...[
            const SizedBox(height: 12),
            const DashedDivider(),
            const SizedBox(height: 12),
            _buildInfoRow('inventory.branch'.trns(), branch),
          ],
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              if (_allowed(detailsPermission) && _allowed(editPermission))
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'packages.card.viewOrEdit'.trns(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              // if (_allowed(editPermission)) ...[
              //   const SizedBox(width: 12),
              //   _buildIconButton(Icons.edit_outlined, onEdit,
              //       busy: false, disabled: isBusy || isDeleting),
              // ],
              if (_allowed(deletePermission)) ...[
                const SizedBox(width: 12),
                _buildIconButton(
                  Icons.delete_outline,
                  onDelete,
                  busy: isDeleting,
                  disabled: isBusy || isDeleting,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.grey, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onTap, {
    bool busy = false,
    bool disabled = false,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: busy
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              )
            : Icon(icon, color: AppColors.primary, size: 24),
      ),
    );
  }
}

// --- Reusable File Picker Input Style ---
class FilePickerInput extends StatelessWidget {
  final String placeholder;
  final VoidCallback onTap;

  const FilePickerInput({
    super.key,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                placeholder,
                style: const TextStyle(color: AppColors.grey, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(9),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'inventory.choose_file'.trns(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Reusable Input Label ---
class FormLabel extends StatelessWidget {
  final String text;
  const FormLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

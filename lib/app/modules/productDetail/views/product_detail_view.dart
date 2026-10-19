
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/productDetail/controllers/product_detail_controller.dart';
import 'package:va_bookats/app/modules/products/views/widgets/rounded_app_bar.dart'
    show RoundedOrangeAppBar, LightOrangeBadge, DashedDivider;
import 'package:va_bookats/models/product_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: RoundedOrangeAppBar(
        title: 'productDetails.title'.trns(),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (controller.hasError) {
          return _buildErrorState();
        }
        if (!controller.hasData) {
          return _buildEmptyState();
        }
        final product = controller.product!;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refreshDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildGallery(product),
                const SizedBox(height: 16),
                _buildTitleCard(product),
                const SizedBox(height: 16),
                _buildActions(product),
                const SizedBox(height: 16),
                _buildBranchInfo(product),
                const SizedBox(height: 16),
                _buildProductBasicInfo(product),
                const SizedBox(height: 16),
                _buildProductDetailedInfo(product),
                const SizedBox(height: 16),
                if (product.categories.isNotEmpty)
                  _buildChipsSection(
                    'productDetails.sections.categories'.trns(),
                    product.categories
                        .map((c) => c.name ?? '')
                        .where((n) => n.isNotEmpty)
                        .toList(),
                  ),
                if (product.categories.isNotEmpty)
                  const SizedBox(height: 16),
                if (product.tags.isNotEmpty)
                  _buildChipsSection(
                    'productDetails.sections.tags'.trns(),
                    product.tags
                        .map((t) => t.name ?? '')
                        .where((n) => n.isNotEmpty)
                        .toList(),
                  ),
                if (product.tags.isNotEmpty) const SizedBox(height: 16),
                if (product.variants.isNotEmpty) _buildVariants(product),
                if (product.variants.isNotEmpty) const SizedBox(height: 16),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Gallery (multiple images, tap to expand) ────────────────────────────

  Widget _buildGallery(ProductModel product) {
    final media = product.media
        .where((m) => (m.displayUrl ?? '').isNotEmpty)
        .toList();
    if (media.isEmpty) {
      return _buildDetailContainer(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AppCachedImage(
            imageUrl: null,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return _buildDetailContainer(
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: controller.galleryController,
              itemCount: media.length,
              onPageChanged: (i) => controller.galleryIndex.value = i,
              itemBuilder: (_, i) {
                final url = media[i].url ?? media[i].displayUrl;
                return GestureDetector(
                  onTap: () => _showImageDialog(url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppCachedImage(
                      imageUrl: url,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          if (media.length > 1) ...[
            const SizedBox(height: 10),
            // Obx(
            //   () => 
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SizedBox(
                      height: 56,
                      child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: media.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          return Obx(
                            () {
                          final selected =
                              controller.galleryIndex.value == i;
                              return GestureDetector(
                              onTap: () {
                                controller.galleryIndex.value = i;
                                if (controller.galleryController.hasClients) {
                                  controller.galleryController.animateToPage(
                                    i,
                                    duration:
                                        const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.navOutline,
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: AppCachedImage(
                                    imageUrl:
                                        media[i].displayUrl,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                        });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            // ),
          ],
        ],
      ),
    );
  }

  void _showImageDialog(String? imageUrl) {
    if ((imageUrl ?? '').isEmpty) return;
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppCachedImage(
                imageUrl: imageUrl,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0x80000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Title + status ──────────────────────────────────────────────────────

  Widget _buildTitleCard(ProductModel product) {
    return _buildDetailContainer(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? '—',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                if ((product.productType ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.productType!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Obx(() {
            final busy =
                controller.busyStatus.value == product.id;
            final badge = Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Text(
                      product.isActive
                          ? 'products.card.active'.trns()
                          : 'products.card.inactive'.trns(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
            );
            if (!Permissions.can(AppPerm.update(AppPerm.products))) {
              return badge;
            }
            return GestureDetector(
              onTap: busy ? null : controller.changeStatus,
              child: badge,
            );
          }),
        ],
      ),
    );
  }

  // ── Edit / Delete actions ───────────────────────────────────────────────

  Widget _buildActions(ProductModel product) {
    return Row(
      children: [
        if (Permissions.can(AppPerm.edit(AppPerm.products)))
          Expanded(
            child: GestureDetector(
              onTap: controller.openEdit,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'products.card.edit'.trns() == 'products.card.edit'
                      ? 'Edit'
                      : 'products.card.edit'.trns(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        if (Permissions.can(AppPerm.destroy(AppPerm.products))) ...[
          const SizedBox(width: 12),
          Obx(() {
            final busy = controller.busyDelete.value == product.id;
            return GestureDetector(
              onTap: busy ? null : controller.deleteProduct,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(
                        Icons.delete_outline,
                        color: AppColors.primary,
                        size: 22,
                      ),
              ),
            );
          }),
        ],
      ],
    );
  }

  // ── Info cards ──────────────────────────────────────────────────────────

  Widget _buildBranchInfo(ProductModel product) {
    final branch = product.branch;
    return _buildDetailContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'productDetails.branchInfoTitle'.trns(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'productDetails.labels.name'.trns(),
            branch?.displayLabel.isNotEmpty == true
                ? branch!.displayLabel
                : (product.branchName.isNotEmpty ? product.branchName : '—'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductBasicInfo(ProductModel product) {
    return _buildDetailContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'productDetails.sections.productInfo'.trns(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'productDetails.labels.name'.trns(),
            product.name ?? '—',
          ),
          const DashedDivider(),
          _buildDetailRow(
            'productDetails.labels.brand'.trns(),
            (product.brandName ?? '').isNotEmpty ? product.brandName! : '—',
          ),
          const DashedDivider(),
          _buildDetailRow(
            'productDetails.labels.unit'.trns(),
            (product.unitName ?? '').isNotEmpty ? product.unitName! : '—',
          ),
          const DashedDivider(),
          _buildDetailRow(
            'productDetails.labels.price'.trns(),
            product.price ?? '—',
          ),
          const DashedDivider(),
          _buildDetailRow(
            'productDetails.labels.stock'.trns(),
            '${product.stock ?? 0}',
          ),
          if ((product.sku ?? '').isNotEmpty) ...[
            const DashedDivider(),
            _buildDetailRow(
              'productDetails.labels.sku'.trns(),
              product.sku!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductDetailedInfo(ProductModel product) {
    return _buildDetailContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'productDetails.sections.productInfo'.trns(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'productDetails.labels.productType'.trns(),
            (product.productType ?? '').isNotEmpty
                ? product.productType!
                : '—',
          ),
          const DashedDivider(),
          Text(
            'productDetails.labels.shortDescription'.trns(),
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AppColors.black),
          ),
          const SizedBox(height: 6),
          Text(
            (product.shortDescription ?? '').isNotEmpty
                ? product.shortDescription!
                : '—',
            style: const TextStyle(
                fontSize: 13, color: AppColors.grey, height: 1.4),
          ),
          if (product.plainDescription.isNotEmpty) ...[
            const DashedDivider(),
            Text(
              'productDetails.labels.description'.trns(),
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: AppColors.black),
            ),
            const SizedBox(height: 6),
            Text(
              product.plainDescription,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.grey, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVariants(ProductModel product) {
    return _buildDetailContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'productDetails.sections.variations'.trns(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...product.variants.asMap().entries.map((entry) {
            final v = entry.value;
            final last = entry.key == product.variants.length - 1;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.displayName.isNotEmpty
                                ? v.displayName
                                : '—',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                          if ((v.sku ?? '').isNotEmpty)
                            Text(
                              v.sku!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          v.price ?? '—',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          '${'productDetails.labels.stock'.trns()}: ${v.stock ?? 0}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!last) const DashedDivider(),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChipsSection(String title, List<String> items) {
    return _buildDetailContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items
                .map((item) => LightOrangeBadge(
                      text: item,
                      horizontalPadding: 16,
                      verticalPadding: 8,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── States ──────────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 16),
            Text(
              controller.detailResponse.value.message ??
                  'productDetails.errors.fetchFailed'.trns(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: controller.fetchDetails,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'productDetails.retry'.trns(),
                  style: const TextStyle(
                    fontSize: 14,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Color(0xFFCCCCCC),
            ),
            const SizedBox(height: 16),
            Text(
              'productDetails.empty.title'.trns(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'productDetails.empty.message'.trns(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Wrapper for all detail cards to maintain consistent border/shadow
  Widget _buildDetailContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navOutline),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: child,
    );
  }

  // Reusable row for Label: Value pairs
  Widget _buildDetailRow(String label, String value,
      {bool isBoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isBoldValue ? AppColors.black : AppColors.grey,
                fontWeight: isBoldValue ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

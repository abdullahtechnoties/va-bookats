import 'package:flutter/material.dart';
import 'package:va_bookats/app/modules/brands/controllers/brands_controller.dart';
import 'package:va_bookats/app/shared/views/inventory_list_view.dart';

class BrandsView extends InventoryListView<BrandsController> {
  const BrandsView({super.key})
      : super(
          titleKey: 'brands.title',
          addLabelKey: 'brands.addNew',
          emptyKey: 'brands.empty',
          emptyIcon: Icons.branding_watermark_outlined,
          showImage: true,
        );
}

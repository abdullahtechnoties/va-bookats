import 'package:flutter/material.dart';
import 'package:va_bookats/app/modules/productCategories/controllers/product_categories_controller.dart';
import 'package:va_bookats/app/shared/views/inventory_list_view.dart';

class ProductCategoriesView
    extends InventoryListView<ProductCategoriesController> {
  const ProductCategoriesView({super.key})
      : super(
          titleKey: 'productCategories.title',
          addLabelKey: 'productCategories.addNew',
          emptyKey: 'productCategories.empty',
          emptyIcon: Icons.category_outlined,
          showImage: true,
        );
}

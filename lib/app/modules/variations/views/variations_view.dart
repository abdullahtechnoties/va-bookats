import 'package:flutter/material.dart';
import 'package:va_bookats/app/modules/variations/controllers/variations_controller.dart';
import 'package:va_bookats/app/shared/views/inventory_list_view.dart';

class VariationsView extends InventoryListView<VariationsController> {
  const VariationsView({super.key})
      : super(
          titleKey: 'variations.title',
          addLabelKey: 'variations.addNew',
          emptyKey: 'variations.empty',
          emptyIcon: Icons.tune_outlined,
          showImage: false,
        );
}

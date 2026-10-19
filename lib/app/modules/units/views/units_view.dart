import 'package:flutter/material.dart';
import 'package:va_bookats/app/modules/units/controllers/units_controller.dart';
import 'package:va_bookats/app/shared/views/inventory_list_view.dart';

class UnitsView extends InventoryListView<UnitsController> {
  const UnitsView({super.key})
      : super(
          titleKey: 'units.title',
          addLabelKey: 'units.addNew',
          emptyKey: 'units.empty',
          emptyIcon: Icons.straighten_outlined,
          showImage: false,
        );
}

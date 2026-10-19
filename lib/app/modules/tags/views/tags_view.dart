import 'package:flutter/material.dart';
import 'package:va_bookats/app/modules/tags/controllers/tags_controller.dart';
import 'package:va_bookats/app/shared/views/inventory_list_view.dart';

class TagsView extends InventoryListView<TagsController> {
  const TagsView({super.key})
      : super(
          titleKey: 'tags.title',
          addLabelKey: 'tags.addNew',
          emptyKey: 'tags.empty',
          emptyIcon: Icons.local_offer_outlined,
          showImage: false,
        );
}

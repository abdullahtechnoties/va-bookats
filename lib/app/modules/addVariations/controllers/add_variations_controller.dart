import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/controllers/inventory_form_controller.dart';
import 'package:va_bookats/models/inventory_item.dart';
import 'package:va_bookats/network/api/api_path.dart';

class AddVariationsController extends InventoryFormController {
  @override
  String get resourceBase => ApiPath.productVariations;

  @override
  String get trPrefix => 'addVariations';

  /// Dynamic value rows (at least one must be non-empty).
  final RxList<TextEditingController> valueCtrls =
      <TextEditingController>[TextEditingController()].obs;

  List<String> get valueNames => valueCtrls
      .map((c) => c.text.trim())
      .where((v) => v.isNotEmpty)
      .toList();

  void addValueRow() {
    valueCtrls.add(TextEditingController());
  }

  void removeValueRow(int index) {
    if (valueCtrls.length <= 1) return;
    valueCtrls[index].dispose();
    valueCtrls.removeAt(index);
  }

  @override
  Map<String, dynamic> extraFields() {
    return {
      for (var i = 0; i < valueNames.length; i++)
        'value_list[$i]': valueNames[i],
    };
  }

  @override
  String? validateExtras() {
    if (valueNames.isEmpty) {
      return tr('validation.valuesRequired');
    }
    return null;
  }

  @override
  void prefillExtras(InventoryItem item) {
    for (final c in valueCtrls) {
      c.dispose();
    }
    final names =
        item.values.map((v) => v.name ?? '').where((n) => n.isNotEmpty);
    valueCtrls.assignAll(
      names.isEmpty
          ? [TextEditingController()]
          : names.map((n) => TextEditingController(text: n)).toList(),
    );
  }

  @override
  void onClose() {
    for (final c in valueCtrls) {
      c.dispose();
    }
    super.onClose();
  }
}

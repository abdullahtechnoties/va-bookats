import 'package:get/get.dart';
import 'package:va_bookats/controllers/inventory_form_controller.dart';
import 'package:va_bookats/models/inventory_item.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/service/auth_service.dart';

class AddBrandController extends InventoryFormController {

  final AuthService auth = Get.find<AuthService>();
  @override
  String get resourceBase => ApiPath.brands;

  @override
  String get trPrefix => 'addBrand';

  @override
  Map<String, dynamic> extraFields() {
    final mediaId = pickedImage.value?.mediaId;
    return {
      'media_id': ?mediaId,
    };
  }

  @override
  void prefillExtras(InventoryItem item) {
    existingImageUrl.value = item.thumbUrl ?? item.imageUrl;
  }
}

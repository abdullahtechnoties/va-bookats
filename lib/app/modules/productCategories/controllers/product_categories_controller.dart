import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/controllers/inventory_list_controller.dart';
import 'package:va_bookats/network/api/api_path.dart';

class ProductCategoriesController extends InventoryListController {
  @override
  String get resourceBase => ApiPath.productCategories;

  @override
  String get permResource => 'product-categories';

  @override
  String get trPrefix => 'productCategories';

  @override
  String get addRoute => Routes.ADD_PRODUCT_CATEGORY;
}

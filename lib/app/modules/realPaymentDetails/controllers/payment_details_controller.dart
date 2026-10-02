import 'package:get/get.dart';
import 'package:va_bookats/app/modules/payments/repositories/payment_repository.dart';
import 'package:va_bookats/models/payment_model.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class RealPaymentDetailsController extends GetxController {
  RealPaymentDetailsController({PaymentRepository? repository})
    : _repository = repository;

  final PaymentRepository? _repository;
  PaymentRepository get _repo {
    final r = _repository;
    if (r != null) return r;
    if (Get.isRegistered<PaymentRepository>()) {
      return Get.find<PaymentRepository>();
    }
    return PaymentRepository();
  }

  final Rxn<PaymentModel> payment = Rxn<PaymentModel>();
  final RxBool isLoading = true.obs;
  final RxBool loadFailed = false.obs;

  int? _paymentId;

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    fetchDetail();
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is int) {
      _paymentId = args;
    } else if (args is Map && args['paymentId'] is int) {
      _paymentId = args['paymentId'] as int;
    } else if (args is PaymentModel) {
      payment.value = args;
      _paymentId = args.id;
    }
  }

  Future<void> fetchDetail() async {
    final id = _paymentId;
    if (id == null || id == 0) {
      // Nothing to fetch — render a prefilled model if one was passed,
      // otherwise show the error state.
      isLoading.value = false;
      loadFailed.value = payment.value == null;
      return;
    }
    isLoading.value = true;
    loadFailed.value = false;
    final response = await _repo.getPaymentDetail(id);
    isLoading.value = false;
    if (!response.isCompleted || response.data == null) {
      loadFailed.value = true;
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
      return;
    }
    payment.value = response.data;
  }

  void retry() => fetchDetail();
}

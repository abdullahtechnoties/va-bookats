import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookingPaymentDetails/models/booking_payment_details_model.dart';
import 'package:va_bookats/app/modules/bookingPaymentDetails/repositories/booking_payment_repository.dart';
import 'package:va_bookats/app/modules/mediaLibrary/controllers/media_library_controller.dart';
import 'package:va_bookats/utilities/navigation_helper.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class AddNewPaymentController extends GetxController {
  final BookingPaymentRepository _repository = BookingPaymentRepository();

  // ── Arguments ───────────────────────────────────────────────────────────
  late final int bookingId;
  int? branchId;
  late String branchName;
  int? customerId;
  int? paymentId;

  bool get isEditMode => paymentId != null;

  // ── Form fields ─────────────────────────────────────────────────────────
  final branchController = TextEditingController();
  final totalAmountController = TextEditingController();
  final paidAmountController = TextEditingController();
  final balanceController = TextEditingController();
  final dateController = TextEditingController();
  final paymentMethodController = TextEditingController();
  final statusController = TextEditingController();
  final transactionIdController = TextEditingController();

  DateTime? selectedDate;

  // ── Payment slip (media library) ────────────────────────────────────────
  final Rxn<MediaItem> selectedSlip = Rxn<MediaItem>();
  final RxnString existingSlipUrl = RxnString();
  final RxList<int> initialSlipIds = <int>[].obs;

  String? get slipPreviewUrl =>
      selectedSlip.value?.thumbnailUrl ??
      selectedSlip.value?.networkUrl ??
      existingSlipUrl.value;

  String get slipDisplayName {
    final slip = selectedSlip.value;
    if (slip != null) return slip.name;
    if ((existingSlipUrl.value ?? '').isNotEmpty) {
      return 'addNewPayment.existingSlip'.trns();
    }
    return 'addNewPayment.noFileChosen'.trns();
  }

  // ── State ───────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isPrefilling = false.obs;

  /// True when both amounts are valid numbers and paid exceeds total.
  /// Drives the inline error under the paid field + submit guard.
  final RxBool paidExceedsTotal = false.obs;

  bool _suspendRecalc = false;

  final List<String> paymentMethods = ['Cash', 'Card', 'Bank Transfer', 'Online'];
  final List<String> statusOptions = ['Paid', 'Unpaid', 'Partial', 'Refunded'];

  @override
  void onInit() {
    super.onInit();
    _extractArguments();
    totalAmountController.addListener(_recalcBalance);
    paidAmountController.addListener(_recalcBalance);
    if (isEditMode) {
      _prefillFromEditData();
    }
  }

  void _extractArguments() {
    final args = Get.arguments;
    if (args is Map) {
      bookingId = int.tryParse(args['bookingId']?.toString() ?? '0') ?? 0;
      branchId = args['branchId'] == null
          ? null
          : int.tryParse(args['branchId'].toString());
      branchName = args['branchName']?.toString() ?? '';
      customerId = args['customerId'] == null
          ? null
          : int.tryParse(args['customerId'].toString());
      paymentId = args['paymentId'] == null
          ? null
          : int.tryParse(args['paymentId'].toString());
      // NOTE: amount fields intentionally start empty in create mode so
      // the "Enter amount" placeholders show; balance is auto-computed.
    } else {
      bookingId = 0;
      branchName = '';
    }
    branchController.text = branchName;
  }

  // ── Edit prefill (all fields come from the editData array) ──────────────
  Future<void> _prefillFromEditData() async {
    isPrefilling.value = true;
    final response = await _repository.getDetails(
      bookingId: bookingId,
      paymentId: paymentId,
    );
    isPrefilling.value = false;

    final PaymentEditData? edit = response.data?.editData;
    if (!response.isCompleted || edit == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'addNewPayment.errors.prefillFailed'.trns(),
      );
      return;
    }

    _suspendRecalc = true;
    totalAmountController.text = edit.totalAmount;
    paidAmountController.text = edit.paidAmount;
    balanceController.text = edit.balance;
    _suspendRecalc = false;
    _recalcBalance();
    paymentMethodController.text = edit.paymentMethod ?? '';
    statusController.text = _capitalize(edit.status);
    transactionIdController.text = edit.transactionId ?? '';
    existingSlipUrl.value = edit.slipThumbUrl ?? edit.slipUrl;
    initialSlipIds.assignAll(edit.media.map((m) => m.id));

    final parsed = DateTime.tryParse(edit.date);
    if (parsed != null) {
      selectedDate = parsed;
      dateController.text = reportHumanDate(parsed);
    } else if (edit.date.isNotEmpty) {
      dateController.text = edit.date;
    }
  }

  // ── Date ────────────────────────────────────────────────────────────────
  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFFF4D00)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      selectedDate = picked;
      dateController.text = reportHumanDate(picked);
    }
  }

  String _apiDate() {
    if (selectedDate != null) {
      final d = selectedDate!;
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    final parsed = DateTime.tryParse(dateController.text.trim());
    if (parsed != null) {
      return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
    }
    return dateController.text.trim();
  }

  // ── Slip selection ──────────────────────────────────────────────────────
  void onSlipConfirmed(List<MediaItem> items) {
    if (items.isEmpty) return;
    selectedSlip.value = items.first;
  }

  void clearSlip() {
    selectedSlip.value = null;
    existingSlipUrl.value = null;
    initialSlipIds.clear();
  }

  // ── Live balance (balance field is never typed into) ───────────────────
  void _recalcBalance() {
    if (_suspendRecalc) return;
    final total = double.tryParse(totalAmountController.text.trim());
    final paidRaw = paidAmountController.text.trim();
    final paid = paidRaw.isEmpty ? 0.0 : double.tryParse(paidRaw);

    paidExceedsTotal.value =
        total != null && paid != null && paid > total;

    if (total == null || paid == null) {
      // Leave any prefilled value alone; clear only what we computed.
      if (total == null) balanceController.text = '';
      return;
    }
    final balance = total - paid;
    balanceController.text =
        (balance < 0 ? 0 : balance).toStringAsFixed(2);
  }

  // ── Submit ──────────────────────────────────────────────────────────────
  Future<void> save(BuildContext context) async {
    final total = totalAmountController.text.trim();
    final paid = paidAmountController.text.trim();
    final balance = balanceController.text.trim();
    final date = _apiDate();
    final method = paymentMethodController.text.trim();
    final status = statusController.text.trim();
    final txn = transactionIdController.text.trim();

    if (branchId == null ||
        total.isEmpty ||
        paid.isEmpty ||
        balance.isEmpty ||
        date.isEmpty ||
        method.isEmpty ||
        status.isEmpty) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'addNewPayment.validation.required'.trns(),
      );
      return;
    }
    if (double.tryParse(total) == null ||
        double.tryParse(paid) == null ||
        double.tryParse(balance) == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'addNewPayment.validation.invalidAmount'.trns(),
      );
      return;
    }
    if (paidExceedsTotal.value ||
        double.parse(paid) > double.parse(total)) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'addNewPayment.validation.paidExceedsTotal'.trns(),
      );
      return;
    }

    final body = <String, dynamic>{
      if (customerId != null) 'customer_id': customerId,
      if (branchId != null) 'branch_id': branchId,
      'booking_id': bookingId,
      'total_amount': total,
      'paid_amount': paid,
      'balance': balance,
      'date': date,
      'payment_method': method,
      'status': status,
      if (txn.isNotEmpty) 'transaction_id': txn,
      if (selectedSlip.value != null)
        'media_id': selectedSlip.value!.mediaId,
    };

    isLoading.value = true;
    final response = isEditMode
        ? await _repository.updatePayment(
            paymentId: paymentId!,
            body: body,
          )
        : await _repository.createPayment(body);
    isLoading.value = false;

    if (!response.isCompleted) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'addNewPayment.errors.saveFailed'.trns(),
      );
      return;
    }

    SnackbarService.showSuccess(
      title: 'common.success'.trns(),
      message: response.message ??
          (isEditMode
              ? 'addNewPayment.updatedSuccess'.trns()
              : 'addNewPayment.savedSuccess'.trns()),
    );
    if (!context.mounted) return;
    await NavigationHelper.safePop(context, true);
  }

  String _capitalize(String s) {
    final t = s.trim();
    if (t.isEmpty) return t;
    if (t.length == 1) return t.toUpperCase();
    return t[0].toUpperCase() + t.substring(1).toLowerCase();
  }

  @override
  void onClose() {
    totalAmountController.removeListener(_recalcBalance);
    paidAmountController.removeListener(_recalcBalance);
    branchController.dispose();
    totalAmountController.dispose();
    paidAmountController.dispose();
    balanceController.dispose();
    dateController.dispose();
    paymentMethodController.dispose();
    statusController.dispose();
    transactionIdController.dispose();
    super.onClose();
  }
}

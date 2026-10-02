import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/mediaLibrary/controllers/media_library_controller.dart';
import 'package:va_bookats/models/booking_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/media-selector-sheet.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

typedef StatusConfirm = void Function({
  required String status,
  String? returnAmount,
  String? paymentMethod,
  String? transactionId,
  int? mediaId,
});

class BookingStatusSheet extends StatefulWidget {
  final String currentStatus;
  final String totalAmount;
  final String discount;
  final String amountPaid;
  final String balance;
  final StatusConfirm onConfirmed;

  const BookingStatusSheet({
    super.key,
    required this.currentStatus,
    required this.totalAmount,
    required this.discount,
    required this.amountPaid,
    required this.balance,
    required this.onConfirmed,
  });

  static void show(
    BuildContext context, {
    required String currentStatus,
    required String totalAmount,
    required String discount,
    required String amountPaid,
    required String balance,
    required StatusConfirm onConfirmed,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingStatusSheet(
        currentStatus: currentStatus,
        totalAmount: totalAmount,
        discount: discount,
        amountPaid: amountPaid,
        balance: balance,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<BookingStatusSheet> createState() => _BookingStatusSheetState();
}

class _BookingStatusSheetState extends State<BookingStatusSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _selected;
  final _returnCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  final _txnCtrl = TextEditingController();
  final _methodCtrl = TextEditingController();
  final RxString _selectedMethod = ''.obs;
  final Rxn<MediaItem> _slip = Rxn<MediaItem>();

  static const List<String> methods = ['Cash', 'Card', 'Online'];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentStatus;
    _totalCtrl.text = widget.totalAmount;
    _discountCtrl.text = widget.discount;
    _paidCtrl.text = widget.amountPaid;
    _balanceCtrl.text = widget.balance;
  }

  @override
  void dispose() {
    _returnCtrl.dispose();
    _totalCtrl.dispose();
    _discountCtrl.dispose();
    _paidCtrl.dispose();
    _balanceCtrl.dispose();
    _txnCtrl.dispose();
    _methodCtrl.dispose();
    super.dispose();
  }

  bool get _isCancelled => _selected.toLowerCase() == 'cancelled';

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Change Status',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),
              ...BookingStatus.all.map((s) => _StatusOption(
                    label: s,
                    selected: _selected.toLowerCase() == s.toLowerCase(),
                    onTap: () => setState(() => _selected = s),
                  )),
                if (_isCancelled) ...[
                const SizedBox(height: 12),
                _label('Total Amount'),
                const SizedBox(height: 6),
                _summaryField(_totalCtrl),
                const SizedBox(height: 12),
                _label('Discount'),
                const SizedBox(height: 6),
                _summaryField(_discountCtrl),
                const SizedBox(height: 12),
                _label('Amount Paid'),
                const SizedBox(height: 6),
                _summaryField(_paidCtrl),
                const SizedBox(height: 12),
                _label('Balance'),
                const SizedBox(height: 6),
                _summaryField(_balanceCtrl),
                const SizedBox(height: 12),
                _label('Return Amount'),
                const SizedBox(height: 6),
                CommonTextInputField(
                  hintText: '0.00',
                  controller: _returnCtrl,
                  keyboardType: TextInputType.number,
                  height: 50,
                  hintTextSize: 13,
                  validator: (_) {
                    final value = _returnCtrl.text.trim();
                    if (value.isEmpty) return null;
                    final amount = double.tryParse(value);
                    if (amount == null || amount < 0) {
                      return 'Enter a valid return amount';
                    }
                    if (amount > _number(_paidCtrl.text)) {
                      return 'Return amount cannot exceed amount paid';
                    }
                    return null;
                  },
                  onChanged: (_) => _recalculateBalance(),
                ),
                const SizedBox(height: 12),
                _label('Payment Method'),
                const SizedBox(height: 6),
                CommonTextInputField(
                  hintText: 'Select Method',
                  controller: _methodCtrl,
                  readOnly: true,
                  height: 50,
                  hintTextSize: 13,
                    validator: (_) => _returnValue > 0 &&
                        _selectedMethod.value.isEmpty
                      ? 'Please select a payment method'
                      : null,
                  onTap: () => _pickMethod(context),
                ),
                const SizedBox(height: 12),
                _label('Transaction ID'),
                const SizedBox(height: 6),
                CommonTextInputField(
                  hintText: 'Enter transaction id',
                  controller: _txnCtrl,
                  height: 50,
                  hintTextSize: 13,
                ),
                const SizedBox(height: 12),
                _label('Payment Slip (from media library)'),
                const SizedBox(height: 6),
                Obx(() {
                  final slip = _slip.value;
                  return Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFE4E4E4)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: slip == null
                            ? const Icon(Icons.receipt_outlined,
                                color: Color(0xFFBBBBBB))
                            : AppCachedImage(
                                imageUrl: slip.thumbnailUrl ??
                                    slip.networkUrl,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          slip?.name ?? 'No slip chosen',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF777777),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => MediaSelectorSheet.show(
                          context,
                          allowMultiple: false,
                          initialSelectedIds: slip == null
                              ? const []
                              : [slip.mediaId],
                          onConfirmed: (items) {
                            if (items.isNotEmpty) _slip.value = items.first;
                          },
                        ),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              slip == null ? 'Choose' : 'Change',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
                const SizedBox(height: 20),
                MainBtn(
                  text: 'Update Status'.trns() == 'Update Status'
                      ? 'Update Status'
                      : 'Update Status'.trns(),
                  onPressed: () {
                    if (_isCancelled &&
                        !(_formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    _recalculateBalance();
                    Get.back();
                    widget.onConfirmed(
                      status: _selected,
                      returnAmount: _returnCtrl.text.trim().isEmpty
                          ? null
                          : _returnCtrl.text.trim(),
                      paymentMethod: _selectedMethod.value.isEmpty
                          ? null
                          : _selectedMethod.value,
                      transactionId: _txnCtrl.text.trim().isEmpty
                          ? null
                          : _txnCtrl.text.trim(),
                      mediaId: _slip.value?.mediaId,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) {
    return Text(
      t,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),
    );
  }

  Widget _summaryField(TextEditingController controller) {
    return CommonTextInputField(
      hintText: '0.00',
      controller: controller,
      keyboardType: TextInputType.number,
      enabled: false,
      readOnly: true,
      height: 50,
      hintTextSize: 13,
    );
  }

  double _number(String value) => double.tryParse(value.trim()) ?? 0;

  double get _returnValue =>
      (double.tryParse(_returnCtrl.text.trim()) ?? 0).clamp(0, double.infinity);

  void _recalculateBalance() {
    final total = _number(_totalCtrl.text).clamp(0, double.infinity).toDouble();
    final discount =
        _number(_discountCtrl.text).clamp(0, total).toDouble();
    final paid = _number(_paidCtrl.text).clamp(0, total).toDouble();
    final returnText = _returnCtrl.text.trim();
    final parsedReturn = double.tryParse(returnText);
    final returnAmount = (parsedReturn ?? 0).clamp(0, paid).toDouble();
    if (parsedReturn != null &&
      (parsedReturn < 0 || parsedReturn > paid)) {
      _returnCtrl.text = returnAmount.toStringAsFixed(2);
      _returnCtrl.selection = TextSelection.collapsed(
        offset: _returnCtrl.text.length,
      );
    }
    final balance = (total - discount - paid - returnAmount)
        .clamp(0, double.infinity)
        .toDouble();
    _balanceCtrl.text = balance.toStringAsFixed(2);
  }

  void _pickMethod(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              ...methods.map((m) => ListTile(
                    title: Text(m),
                    trailing: Obx(() => _selectedMethod.value == m
                        ? const Icon(Icons.check,
                            color: AppColors.secondary)
                        : const SizedBox.shrink()),
                    onTap: () {
                      _selectedMethod.value = m;
                      _methodCtrl.text = m;
                      Get.back();
                    },
                  )),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.secondary.withValues(alpha: 0.4)
                : const Color(0xFFEEEEEE),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: AppColors.secondary, size: 20),
          ],
        ),
      ),
    );
  }
}

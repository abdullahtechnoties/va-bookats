// lib/app/modules/dailyClosing/views/widgets/daily_closing_form_sheet.dart
//
// "Create opening balance" sheet, shared by the home card and the daily
// closings header button. Owners pick a branch inside the sheet; other
// roles are tied to their own branch (data supplied by AuthService).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/dailyClosing/controllers/opening_balance_controller.dart';
import 'package:va_bookats/app/modules/dailyClosing/models/daily_closing_model.dart';
import 'package:va_bookats/app/modules/dailyClosing/repositories/daily_closing_repository.dart';
import 'package:va_bookats/app/modules/dailyClosing/utilities/closing_formatters.dart';
import 'package:va_bookats/app/modules/dailyClosing/views/widgets/closing_branch_picker.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/navigation_helper.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class DailyClosingFormSheet extends StatefulWidget {
  final List<BranchModel> branches;
  final int? initialBranchId;
  final bool allowBranchSelection;

  const DailyClosingFormSheet({
    super.key,
    this.branches = const [],
    this.initialBranchId,
    this.allowBranchSelection = false,
  });

  /// Shows the sheet; resolves with the created closing (or `null`).
  static Future<DailyClosingModel?> show(
    BuildContext context, {
    List<BranchModel> branches = const [],
    int? initialBranchId,
    bool allowBranchSelection = false,
  }) {
    return showModalBottomSheet<DailyClosingModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DailyClosingFormSheet(
        branches: branches,
        initialBranchId: initialBranchId,
        allowBranchSelection: allowBranchSelection,
      ),
    );
  }

  @override
  State<DailyClosingFormSheet> createState() => _DailyClosingFormSheetState();
}

class _DailyClosingFormSheetState extends State<DailyClosingFormSheet> {
  final DailyClosingRepository _repository = DailyClosingRepository();
  final TextEditingController _openingCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late int? _branchId = widget.initialBranchId;
  late DateTime _date = DateTime.now();
  bool _submitting = false;

  BranchModel? get _selectedBranch {
    for (final b in widget.branches) {
      if (b.value == _branchId) return b;
    }
    return null;
  }

  @override
  void dispose() {
    _openingCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.secondary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _pickBranch() async {
    if (widget.branches.isEmpty) return;
    final picked = await showClosingBranchPicker(
      context,
      branches: widget.branches,
      selected: _selectedBranch,
    );
    if (picked == null) return;
    setState(() => _branchId = picked.value);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final branchId = _branchId;
    if (branchId == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'dailyClosing.selectBranch'.trns(),
      );
      return;
    }
    final amount = double.tryParse(_openingCtrl.text.trim()) ?? 0;

    setState(() => _submitting = true);
    final response = await _repository.create(
      branchId: branchId,
      date: closingCreateDate(_date),
      openingBalance: amount.toStringAsFixed(2),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (!response.isCompleted || response.data == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
      return;
    }

    SnackbarService.showSuccess(
      title: 'common.success'.trns(),
      message:
          response.message ??
          ('dailyClosing.createSuccess'.trns() == 'dailyClosing.createSuccess'
              ? 'Daily closing created successfully.'
              : 'dailyClosing.createSuccess'.trns()),
    );
    // Home card refreshes immediately; the list refreshes on return.
    await refreshOpeningBalanceIfMounted();
    Get.back(result: response.data);
    NavigationHelper.safePop(Get.overlayContext!);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'dailyClosing.createOpening'.trns(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _submitting ? null : () => Get.back(),
                      child: const Icon(
                        Icons.close,
                        size: 22,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'dailyClosing.createOpeningHint'.trns(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                if (widget.allowBranchSelection) ...[
                  _label('dailyClosing.branch'.trns()),
                  _field(
                    onTap: _submitting ? null : _pickBranch,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          size: 18,
                          color: Color(0xFF888888),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedBranch?.displayLabel ??
                                'dailyClosing.selectBranch'.trns(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _selectedBranch == null
                                  ? const Color(0xFF9CA3AF)
                                  : AppColors.black,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: Color(0xFF888888),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                _label('dailyClosing.date'.trns()),
                _field(
                  onTap: _submitting ? null : _pickDate,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 17,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          closingDisplayDate(closingApiDate(_date)),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      Text(
                        _sameDay(_date, DateTime.now())
                            ? 'dailyClosing.today'.trns()
                            : '',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _label('dailyClosing.openingBalance'.trns()),
                TextFormField(
                  controller: _openingCtrl,
                  enabled: !_submitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'dailyClosing.validation.openingRequired'.trns();
                    }
                    final parsed = double.tryParse(text);
                    if (parsed == null || parsed < 0) {
                      return 'dailyClosing.validation.openingInvalid'.trns();
                    }
                    return null;
                  },
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                    prefixIcon: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18,
                      color: Color(0xFF888888),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.secondary,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                GestureDetector(
                  onTap: _submitting ? null : _submit,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: _submitting
                          ? AppColors.secondary.withValues(alpha: 0.6)
                          : AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            'dailyClosing.createOpening'.trns(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6B7280),
      ),
    ),
  );

  Widget _field({VoidCallback? onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.black.withValues(alpha: 0.2)),
        ),
        child: Row(children: [Expanded(child: child)]),
      ),
    );
  }
}

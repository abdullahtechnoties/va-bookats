import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:flutter/material.dart';

/// Dummy report categories (translation keys).
const List<String> kReportCategoryKeys = [
  'report.category.spam',
  'report.category.harassment',
  'report.category.inappropriate',
  'report.category.fake',
  'report.category.offensive',
  'report.category.other',
];

/// Opens the global report bottom sheet.
///
/// [targetType] is a human-readable kind of content being reported
/// (e.g. "post", "comment", "story", "chat", "user") used for the header.
Future<void> showReportContentSheet(
  BuildContext context, {
  required int targetId,
  required String targetType,
  String? targetName,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ReportContentSheet(
      targetId: targetId,
      targetType: targetType,
      targetName: targetName,
    ),
  );
}

/// Global report sheet: category dropdown + message + loader + success snackbar.
/// Submission is simulated so it can be wired to a real API later.
class ReportContentSheet extends StatefulWidget {
  final int targetId;
  final String targetType;
  final String? targetName;

  const ReportContentSheet({
    super.key,
    required this.targetId,
    required this.targetType,
    this.targetName,
  });

  @override
  State<ReportContentSheet> createState() => _ReportContentSheetState();
}

class _ReportContentSheetState extends State<ReportContentSheet> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedCategoryKey;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedCategoryKey == null) {
      SnackbarService.showError(
        title: 'report.title'.trns(),
        message: 'report.categoryRequired'.trns(),
      );
      return;
    }
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    // Simulated API call — replace with real endpoint later.
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context);
    SnackbarService.showSuccess(
      title: 'report.successTitle'.trns(),
      message: 'report.successMessage'.trns(),
    );
  }

  void _pickCategory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'report.selectCategory'.trns(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
             Divider(height: 1, color: AppColors.dividerColor),
            ...kReportCategoryKeys.map(
              (key) => ListTile(
                leading: const Icon(
                  Icons.flag_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                title: Text(
                  key.trns(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: _selectedCategoryKey == key
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  setState(() => _selectedCategoryKey = key);
                  Navigator.pop(sheetContext);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flag_outlined,
                        color: AppColors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'report.title'.trns(),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        if (widget.targetName != null &&
                            widget.targetName!.trim().isNotEmpty)
                          Text(
                            '${'report.reporting'.trns()} ${widget.targetName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Category dropdown ─────────────────────────────────
                Text(
                  'report.categoryLabel'.trns(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickCategory,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8EBF0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedCategoryKey != null
                                ? _selectedCategoryKey!.trns()
                                : 'report.categoryHint'.trns(),
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedCategoryKey != null
                                  ? Colors.black87
                                  : AppColors.lightGrey,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.grey,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Message ──────────────────────────────────────────
                Text(
                  'report.messageLabel'.trns(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageController,
                  maxLines: 4,
                  minLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'report.messageHint'.trns(),
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.lightGrey,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF4F6F8),
                    counterStyle: const TextStyle(
                      fontSize: 11,
                      color: AppColors.lightGrey,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE8EBF0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.2,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // ── Submit ───────────────────────────────────────────
                GestureDetector(
                  onTap: _isSubmitting ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: _isSubmitting
                        ? const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              'report.submit'.trns(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
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
}

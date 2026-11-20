// lib/app/modules/dailyClosing/utilities/closing_formatters.dart
//
// Shared display/parse helpers for the daily closing module, so the list,
// detail and form widgets all format dates and money identically.

import 'package:va_bookats/utilities/report_filter_helpers.dart';

/// `DateTime` → `2026-11-20` (query params / from-to filters).
String closingApiDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// `DateTime` → `2026/11/20` (POST /daily-closings `date` field).
String closingCreateDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/'
    '${d.day.toString().padLeft(2, '0')}';

/// `2026-11-20` → `Nov 20, 2026`; unknown shapes are shown as-is.
String closingDisplayDate(String raw) {
  if (raw.isEmpty) return '—';
  final parsed = DateTime.tryParse(raw.replaceAll('/', '-'));
  if (parsed == null) return raw;
  return reportHumanDate(parsed);
}

/// `Sep 21, 2026` (filter sheet format) → `2026-09-21`.
String? closingFilterDateToApi(String text) {
  final t = text.trim();
  if (t.isEmpty) return null;
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final parts = t.split('/');
  if (parts.length == 3) {
    final month = months.indexWhere(
      (m) => m.toLowerCase() == parts[0].trim().toLowerCase(),
    );
    final day = int.tryParse(parts[1].trim());
    final year = int.tryParse(parts[2].trim());
    if (month > 0 && day != null && year != null) {
      return '${year.toString().padLeft(4, '0')}-'
          '${month.toString().padLeft(2, '0')}-'
          '${day.toString().padLeft(2, '0')}';
    }
  }
  final dashed = DateTime.tryParse(t);
  return dashed == null ? null : closingApiDate(dashed);
}

/// `6000.00` → `6,000.00` (no symbol).
String closingAmount(dynamic value) {
  final n = value is num
      ? value.toDouble()
      : double.tryParse(value?.toString().replaceAll(',', '') ?? '');
  if (n == null) return value?.toString() ?? '0.00';
  final fixed = n.toStringAsFixed(2);
  final parts = fixed.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$intPart.${parts[1]}';
}

/// `₨ 6,000.00` (symbol omitted when the branch has none).
String closingMoney(dynamic value, [String symbol = '']) {
  final amount = closingAmount(value);
  return symbol.trim().isEmpty ? amount : '${symbol.trim()} $amount';
}

/// `2026-11-20T14:47:44.000000Z` → `Nov 20, 2026 · 2:47 PM`.
String closingActivityTime(String iso) {
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;
  final local = parsed.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final suffix = local.hour >= 12 ? 'PM' : 'AM';
  return '${reportHumanDate(local)} · $hour:$minute $suffix';
}

/// Quick-range label → API value (`This Week` → `this_week`).
String? closingQuickRangeValue(String label) {
  if (label.trim().isEmpty) return null;
  return label.trim().toLowerCase().replaceAll(' ', '_');
}

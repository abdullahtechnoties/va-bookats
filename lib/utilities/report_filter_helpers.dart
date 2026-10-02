// lib/utilities/report_filter_helpers.dart
//
// Shared helpers for the reporting flows: multi-select dropdown state,
// Laravel-style indexed array params (`branch_ids[0]=2&branch_ids[1]=3`),
// and human readable filter dates.

import 'package:get/get.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// A single dropdown option with stringified ids so int/String API payloads
/// can never crash a sheet (`type 'int' is not a subtype of type 'String'`).
class ReportOption {
  final String label;
  final String value;

  const ReportOption({required this.label, required this.value});
}

/// A toggleable table column (key + already-resolved display label).
class ReportColumnOption {
  final String key;
  final String label;

  const ReportColumnOption({required this.key, required this.label});
}

/// Appends `baseKey[0]=v0&baseKey[1]=v1...` entries. An empty [values]
/// appends nothing (backend treats "absent" as "All").
void addIndexedParams(
  Map<String, dynamic> params,
  String baseKey,
  Iterable<String> values,
) {
  var i = 0;
  for (final v in values) {
    params['$baseKey[$i]'] = v;
    i++;
  }
}

/// "Sep 21, 2026" — the human readable filter-date format used by every
/// reporting sheet and date-range label.
String reportHumanDate(DateTime d) {
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
  return '${months[d.month]} ${d.day}, ${d.year}';
}

/// Display text for a multi-select field: All / single label / "n selected".
String multiSelectDisplay({
  required Set<String> selected,
  required List<ReportOption> options,
  required String allLabel,
  required String selectedSuffix,
}) {
  if (selected.isEmpty) return allLabel;
  if (selected.length == 1) {
    for (final o in options) {
      if (o.value == selected.first) return o.label;
    }
    return allLabel;
  }
  return '${selected.length} $selectedSuffix';
}

/// Copies an applied multi-selection into its temp (sheet) counterpart.
void initTempMulti(RxSet<String> temp, RxSet<String> applied) {
  temp.assignAll(applied);
}

/// True when an API dropdown list already ships its own "All" entry
/// (any option whose stringified value is "all"), so filter sheets must
/// not prepend another one (avoids twin "All Services / Products / …").
bool reportOptionsContainAll(Iterable options) {
  for (final o in options) {
    try {
      final v = (o as dynamic)?.value?.toString().toLowerCase();
      if (v == 'all') return true;
    } catch (_) {
      continue;
    }
  }
  return false;
}

/// Keys that exist in `monthlyData` rows but must never become columns
/// (identifiers and nested objects, not displayable data).
const Set<String> technicalReportKeys = {
  'id',
  'branch_id',
  'service_id',
  'product_id',
  'package_id',
  'staff_id',
  'customer_id',
  'expense_category_id',
  'category_id',
  'currency_symbol',
  'currencySymbol',
};

/// Discovers displayable column keys from raw row maps: every scalar field
/// that is neither technical nor already known, in first-seen order.
List<String> discoverReportColumns(
  Iterable<Map<String, dynamic>> rows,
  Set<String> knownKeys,
) {
  final out = <String>[];
  for (final row in rows) {
    for (final entry in row.entries) {
      final k = entry.key;
      if (knownKeys.contains(k) || out.contains(k)) continue;
      if (k.startsWith('_') || technicalReportKeys.contains(k)) continue;
      final v = entry.value;
      if (v is Map || v is List) continue;
      out.add(k);
    }
  }
  return out;
}

/// Reliable column-label technique: en.json first
/// (`<prefix>.<camelKey>`), graceful Title Case fallback for keys the
/// backend adds tomorrow.
String resolveReportColumnLabel(String prefix, String labelKey) {
  if (labelKey.contains('.')) return labelKey.trns();
  final full = '$prefix.${_snakeToCamel(labelKey)}';
  final t = full.trns();
  return t == full ? humanizeReportKey(labelKey) : t;
}

/// `total_amount` → `Total Amount`.
String humanizeReportKey(String key) {
  final parts = key.split('_').where((p) => p.isNotEmpty);
  return parts
      .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
      .join(' ');
}

String _snakeToCamel(String key) {
  final parts = key.split('_').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return key;
  return parts.first.toLowerCase() +
      parts
          .skip(1)
          .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
          .join();
}

/// Width that fits the header label without wasting space.
double reportColumnWidth(String label) =>
    (label.length * 7 + 70).clamp(110.0, 190.0).toDouble();

/// Graceful cell formatting for dynamic values: human dates, integer
/// counts, `$`-prefixed money, plain strings otherwise.
String formatReportCell(String key, dynamic value) {
  if (value == null) return '—';
  if (value is Map || value is List) return '—';
  final k = key.toLowerCase();
  if (k == 'from' || k == 'to' || k == 'date') {
    final parsed = DateTime.tryParse(value.toString());
    if (parsed != null) return reportHumanDate(parsed);
    return value.toString();
  }
  if (k.contains('count') ||
      k.endsWith('_sold') ||
      k.endsWith('_bookings') ||
      k == 'quantity') {
    final n = num.tryParse(value.toString());
    if (n != null) return n.toInt().toString();
    return value.toString();
  }
  const money = [
    'amount',
    'discount',
    'revenue',
    'balance',
    'payment',
    'price',
    'expense',
    'commission',
  ];
  if (money.any(k.contains)) {
    final n = double.tryParse(value.toString());
    if (n != null) return '\$${n.toStringAsFixed(2)}';
    return value.toString();
  }
  return value.toString();
}

// lib/utilities/report_filter_helpers.dart
//
// Shared helpers for the reporting flows: multi-select dropdown state,
// Laravel-style indexed array params (`branch_ids[0]=2&branch_ids[1]=3`),
// and human readable filter dates.

import 'package:get/get.dart';

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

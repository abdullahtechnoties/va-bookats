// lib/utilities/booking_form_helpers.dart
//
// App-wide helpers for booking (and any other) forms.
// Keeps formatting / money math / clamping in one place so every step
// behaves the same and validation never produces negative amounts.

import 'package:flutter/material.dart';

class BookingFormHelpers {
  const BookingFormHelpers._();

  // ─── Money ─────────────────────────────────────────────────────────────

  /// Parses user input safely. Empty / invalid → 0. Never negative.
  static double parseMoney(String? text) {
    final v = double.tryParse((text ?? '').trim()) ?? 0;
    if (v.isNaN || v.isInfinite) return 0;
    return v < 0 ? 0 : v;
  }

  static int parseQty(String? text) {
    final v = int.tryParse((text ?? '').trim()) ?? 0;
    return v < 0 ? 0 : v;
  }

  static String formatMoney(double value) {
    final v = value.isNaN || value.isInfinite ? 0 : value;
    return (v < 0 ? 0 : v).toStringAsFixed(2);
  }

  /// amount - discount, clamped to >= 0.
  static double rowTotal(double amount, double discount) =>
      (amount - discount).clamp(0, double.infinity).toDouble();

  static String rowTotalText(String amountText, String discountText) =>
      formatMoney(rowTotal(parseMoney(amountText), parseMoney(discountText)));

  /// Returns [grossTotal, afterDiscount].
  static List<double> productTotals({
    required String qtyText,
    required String unitPriceText,
    required String discountText,
  }) {
    final qty = parseMoney(qtyText);
    final unit = parseMoney(unitPriceText);
    final discount = parseMoney(discountText);
    final gross = qty * unit;
    final after = (gross - discount).clamp(0, double.infinity).toDouble();
    return [gross, after];
  }

  /// Sanitizes a money text field in place (removes minus / NaN).
  /// Returns the sanitized double.
  static double sanitizeMoneyController(TextEditingController ctrl) {
    final v = parseMoney(ctrl.text);
    final current = ctrl.text.trim();
    // Rewrite only when the field holds a negative / invalid number.
    if (current.startsWith('-') ||
        (current.isNotEmpty && double.tryParse(current) == null)) {
      ctrl.text = current.startsWith('-') ? formatMoney(v) : ctrl.text;
      // Keep cursor at end after rewrite.
      ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
    }
    return v;
  }

  static double sanitizeQtyController(
    TextEditingController ctrl, {
    int? maxStock,
  }) {
    var v = parseQty(ctrl.text);
    if (maxStock != null && maxStock >= 0 && v > maxStock) v = maxStock;
    if (ctrl.text.trim() != v.toString() &&
        (ctrl.text.trim().startsWith('-') ||
            (maxStock != null && parseQty(ctrl.text) > maxStock))) {
      ctrl.text = v == 0 && ctrl.text.trim().isEmpty ? '' : v.toString();
      ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
    }
    return v.toDouble();
  }

  // ─── Date / time ───────────────────────────────────────────────────────

  static const List<String> _months = [
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

  /// "2026-09-21" → "Sep 21, 2026". Pass-through when unparsable.
  static String formatDateHuman(String apiDate) {
    final t = apiDate.trim();
    if (t.isEmpty) return '';
    try {
      final dt = DateTime.parse(t);
      return '${_months[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return t;
    }
  }

  static String formatDateHumanFromParts(int y, int m, int d) =>
      '${_months[m]} $d, $y';

  /// "14:30" / "14:30:00" → "02:30 PM". Pass-through when unparsable.
  static String formatTimeHuman(String apiTime) {
    final t = apiTime.trim();
    if (t.isEmpty) return '';
    try {
      final parts = t.split(':');
      var h = int.parse(parts[0]);
      final m = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
      final suffix = h >= 12 ? 'PM' : 'AM';
      h = h % 12;
      if (h == 0) h = 12;
      return '${h.toString().padLeft(2, '0')}:$m $suffix';
    } catch (_) {
      return t;
    }
  }

  static String formatTimeHumanFromTimeOfDay(TimeOfDay t) {
    var h = t.hour;
    final suffix = h >= 12 ? 'PM' : 'AM';
    h = h % 12;
    if (h == 0) h = 12;
    return '${h.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $suffix';
  }

  /// "Sep 21, 2026", "09/21/2026" or "2026-09-21" → "2026-09-21".
  static String toApiDate(String display) {
    final t = display.trim();
    if (t.isEmpty) return '';
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(t)) return t;
    // Try legacy "MM/DD/YYYY".
    final slash = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(t);
    if (slash != null) {
      final m = int.tryParse(slash.group(1)!) ?? 0;
      final d = int.tryParse(slash.group(2)!) ?? 0;
      if (m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        return '${slash.group(3)}-'
            '${m.toString().padLeft(2, '0')}-'
            '${d.toString().padLeft(2, '0')}';
      }
    }
    try {
      final dt = DateTime.parse(t);
      return '${dt.year.toString().padLeft(4, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {}
    // Try "Sep 21, 2026".
    final m = RegExp(r'^([A-Za-z]{3})\s+(\d{1,2}),\s*(\d{4})$').firstMatch(t);
    if (m != null) {
      final mon = _months.indexWhere(
        (e) => e.toLowerCase() == m.group(1)!.toLowerCase(),
      );
      if (mon > 0) {
        final d = int.tryParse(m.group(2)!) ?? 1;
        return '${m.group(3)}-'
            '${mon.toString().padLeft(2, '0')}-'
            '${d.toString().padLeft(2, '0')}';
      }
    }
    return t;
  }

  /// "02:30 PM" or "14:30" → "14:30".
  static String toApiTime(String display) {
    final t = display.trim();
    if (t.isEmpty) return '';
    if (RegExp(r'^\d{2}:\d{2}$').hasMatch(t)) return t;
    if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(t)) return t.substring(0, 5);
    final m = RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$').firstMatch(t);
    if (m != null) {
      var h = int.tryParse(m.group(1)!) ?? 0;
      final min = m.group(2)!;
      final pm = m.group(3)!.toUpperCase() == 'PM';
      if (pm && h < 12) h += 12;
      if (!pm && h == 12) h = 0;
      return '${h.toString().padLeft(2, '0')}:$min';
    }
    return t;
  }

  /// API date "2026-09-21" → "2026/09/21" for staff-availability query.
  static String toSlashDate(String apiDate) =>
      toApiDate(apiDate).replaceAll('-', '/');
}

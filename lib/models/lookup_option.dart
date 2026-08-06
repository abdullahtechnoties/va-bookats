class LookupOption {
  const LookupOption({
    required this.label,
    required this.value,
    this.raw = const <String, dynamic>{},
  });

  final String label;
  final String value;
  final Map<String, dynamic> raw;

  int? get valueAsInt => int.tryParse(value);

  factory LookupOption.fromJson(Map<String, dynamic> json) {
    final label = _firstString(json, const ['label', 'name', 'title', 'text']);
    final value = _firstString(json, const ['value', 'id', 'code']);
    return LookupOption(
      label: label.isEmpty ? value : label,
      value: value.isEmpty ? label : value,
      raw: json,
    );
  }

  static String _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }
}
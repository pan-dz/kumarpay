/// Common JSON value converters for robust model parsing.
/// Prefer using these instead of inline helpers to keep models clean.

String asString(Object? v, [String fallback = '']) {
  return v?.toString() ?? fallback;
}

int asInt(Object? v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('${v ?? ''}') ?? fallback;
}

double asDouble(Object? v, [double fallback = 0.0]) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse('${v ?? ''}') ?? fallback;
}

num asNum(Object? v, [num fallback = 0]) {
  if (v is num) return v;
  return num.tryParse('${v ?? ''}') ?? fallback;
}

bool asBool(Object? v, [bool fallback = false]) {
  if (v is bool) return v;
  final s = '${v ?? ''}'.toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return fallback;
}

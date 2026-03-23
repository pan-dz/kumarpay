import 'package:flutter/services.dart';

/// Input formatter for Indian phone numbers with prefix-aware max length.
///
/// Allows:
/// - Local 10-digit mobile numbers starting with 6–9 (length cap 10).
/// - `0` + local (cap 11).
/// - `91` + local (cap 12).
/// - `+91` + local (cap 13).
/// - `0091` + local (cap 14).
///
/// Only digits are allowed, plus an optional leading `+` at index 0.
class IndianPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    final cleaned = _filterAllowed(raw);
    final maxLen = _maxLengthForPrefix(cleaned);
    final truncated = cleaned.length > maxLen
        ? cleaned.substring(0, maxLen)
        : cleaned;

    // Try to keep cursor position relative to allowed chars before original cursor.
    final originalCursor = newValue.selection.baseOffset;
    int desiredCursor;
    if (originalCursor <= 0) {
      desiredCursor = truncated.length;
    } else {
      final prefix = raw.substring(0, raw.length.clamp(0, originalCursor));
      final cleanedPrefix = _filterAllowed(prefix);
      desiredCursor = cleanedPrefix.length;
    }
    if (desiredCursor > truncated.length) {
      desiredCursor = truncated.length;
    }

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: desiredCursor),
      composing: TextRange.empty,
    );
  }

  String _filterAllowed(String input) {
    final sb = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      final isDigit = ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
      if (isDigit) {
        sb.write(ch);
      } else if (ch == '+' && i == 0) {
        sb.write(ch);
      } // other characters are dropped
    }
    // If '+' appears not at index 0 after filtering (e.g., due to edits), remove it.
    final s = sb.toString();
    final plusIndex = s.indexOf('+');
    if (plusIndex > 0) {
      // Remove '+' not at start.
      return s.replaceAll('+', '');
    }
    return s;
  }

  int _maxLengthForPrefix(String s) {
    if (s.startsWith('+')) {
      // Prefer +91 path, otherwise cap at 13 while user is typing.
      return 13;
    }
    if (s.startsWith('0091')) {
      return 14;
    }
    if (s.startsWith('00')) {
      // User likely typing 0091; use the larger cap to avoid early truncation.
      return 14;
    }
    if (s.startsWith('91')) {
      return 12;
    }
    if (s.startsWith('0')) {
      return 11;
    }
    return 10;
  }
}

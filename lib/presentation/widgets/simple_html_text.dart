import 'package:flutter/material.dart';

class SimpleHtmlText extends StatelessWidget {
  final String html;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const SimpleHtmlText({
    super.key,
    required this.html,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.visible,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      _stripHtml(html),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  String _stripHtml(String input) {
    if (input.isEmpty) return '';
    var text = input;

    text = text.replaceAll(RegExp(r'<\s*br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<\s*p[^>]*>', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');

    const entities = <String, String>{
      '&nbsp;': ' ',
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&#39;': "'",
    };
    entities.forEach((k, v) {
      text = text.replaceAll(k, v);
    });

    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return text.trim();
  }
}

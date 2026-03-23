import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HxInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final TextInputType keyboardType;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final int? minValue;
  final int? maxValue;
  final ValueChanged<int>? onValidated;

  const HxInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.textAlign = TextAlign.end,
    this.keyboardType = TextInputType.number,
    this.style,
    this.onChanged,
    this.decoration,
    this.inputFormatters,
    this.textInputAction,
    this.minValue,
    this.maxValue,
    this.onValidated,
  });

  @override
  State<HxInput> createState() => _HxInputState();
}

class _HxInputState extends State<HxInput> {
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    _attachFocusNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(covariant HxInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _detachFocusNode(oldWidget.focusNode);
      _attachFocusNode(widget.focusNode);
    }
  }

  @override
  void dispose() {
    _detachFocusNode(widget.focusNode);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _attachFocusNode(FocusNode? node) {
    if (node != null) {
      _focusNode = node;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  void _detachFocusNode(FocusNode? node) {
    (node ?? (_ownsFocusNode ? _focusNode : null))?.removeListener(
      _handleFocusChange,
    );
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) return;
    final min = widget.minValue;
    final max = widget.maxValue;
    if (min == null && max == null) return;

    final text = widget.controller.text.trim();
    if (text.isEmpty) {
      final fallback = min ?? max;
      if (fallback == null) return;
      widget.controller.text = fallback.toString();
      widget.controller.selection = TextSelection.collapsed(
        offset: widget.controller.text.length,
      );
      widget.onValidated?.call(fallback);
      return;
    }

    final parsed = int.tryParse(text);
    if (parsed == null) return;

    final normalized = parsed.clamp(min ?? parsed, max ?? parsed);
    if (normalized != parsed) {
      widget.controller.text = normalized.toString();
      widget.controller.selection = TextSelection.collapsed(
        offset: widget.controller.text.length,
      );
    }
    widget.onValidated?.call(normalized);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      textAlign: widget.textAlign,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      style:
          widget.style ??
          const TextStyle(
            color: Color(0xFF8F9098),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
      onChanged: widget.onChanged,
      decoration:
          widget.decoration ??
          const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            hintText: '',
          ),
    );
  }
}

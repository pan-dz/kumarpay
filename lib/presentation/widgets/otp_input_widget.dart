import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPInputWidget extends StatefulWidget {
  final int length;
  final Function(String) onCompleted;
  final bool autoFocus;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;
  final double fieldWidth;
  final double fieldHeight;
  final InputDecoration? decoration;
  final bool obscureText;
  final bool showCursor;
  final bool enabled;

  const OTPInputWidget({
    super.key,
    this.length = 4,
    required this.onCompleted,
    this.autoFocus = false,
    this.keyboardType = TextInputType.number,
    this.onChanged,
    this.textStyle,
    this.fieldWidth = 50,
    this.fieldHeight = 60,
    this.decoration,
    this.obscureText = false,
    this.showCursor = true,
    this.enabled = true,
  });

  @override
  // ignore: library_private_types_in_public_api
  _OTPInputWidgetState createState() => _OTPInputWidgetState();
}

class _OTPInputWidgetState extends State<OTPInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _otp;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _otp = List.generate(widget.length, (index) => '');
  }

  void _onTextChanged(int index, String text) {
    if (text.isEmpty) {
      _otp[index] = '';

      // 如果当前框为空且不是第一个，则前移焦点
      if (index > 0) {
        _focusNodes[index].unfocus();
        _focusNodes[index - 1].requestFocus();
      }
    } else if (text.length == 1) {
      _otp[index] = text;

      // 如果当前框已输入且不是最后一个，则后移焦点
      if (index < widget.length - 1) {
        _focusNodes[index].unfocus();
        _focusNodes[index + 1].requestFocus();
      }

      // 检查是否所有字段都已填满
      _checkAndComplete();
    } else if (text.length > 1) {
      // 处理粘贴多个字符的情况
      if (text.length == widget.length) {
        // 粘贴了整个验证码
        for (int i = 0; i < widget.length && i < text.length; i++) {
          _otp[i] = text[i];
          _controllers[i].text = text[i];
        }
        _checkAndComplete();
      } else {
        // 只取第一个字符
        _controllers[index].text = text[0];
      }
    }

    // 通知外部变化
    if (widget.onChanged != null) {
      widget.onChanged!(_otp.join());
    }
  }

  void _checkAndComplete() {
    String otpString = _otp.join();
    if (otpString.length == widget.length) {
      widget.onCompleted(otpString);
    }
  }

  // 退格键行为由 onChanged 处理：当从有值变为空时会自动聚焦到上一格。

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void clear() {
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].text = '';
      _otp[i] = '';
    }
    if (widget.length > 0) {
      _focusNodes[0].requestFocus();
    }
  }

  void setOTP(String otp) {
    if (otp.length != widget.length) return;

    for (int i = 0; i < widget.length; i++) {
      _controllers[i].text = otp[i];
      _otp[i] = otp[i];
    }
    _checkAndComplete();
  }

  String getOTP() {
    return _otp.join();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: widget.fieldWidth,
          height: widget.fieldHeight,
          child: TextField(
            enabled: widget.enabled,
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: widget.keyboardType,
            textInputAction: index < widget.length - 1
                ? TextInputAction.next
                : TextInputAction.done,
            maxLength: 1,
            obscureText: widget.obscureText,
            showCursor: widget.showCursor && widget.enabled,
            autofocus: widget.enabled && widget.autoFocus && index == 0,
            style: widget.textStyle ?? Theme.of(context).textTheme.titleLarge,
            decoration:
                widget.decoration ??
                const InputDecoration(
                  counterText: '',
                  // 默认灰色下边框
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFC5C6CC),
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFC5C6CC),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFC5C6CC),
                      width: 0.5,
                    ),
                  ),
                ),
            onChanged: (value) => _onTextChanged(index, value),
          ),
        );
      }),
    );
  }
}

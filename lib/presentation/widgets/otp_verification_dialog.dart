import 'dart:async';
import 'package:flutter/material.dart';
import 'otp_input_widget.dart';

class OtpVerificationDialog extends StatefulWidget {
  final String phone;
  final Future<bool> Function(String phone)? onSendOtp;
  final void Function(String otp) onVerified;
  final int length;
  final int countdownSeconds;
  final String? errorText;
  final int closeDelaySeconds;
  final bool autoStartCountdown;

  const OtpVerificationDialog({
    super.key,
    required this.phone,
    required this.onVerified,
    this.onSendOtp,
    this.length = 4,
    this.countdownSeconds = 120,
    this.errorText,
    this.closeDelaySeconds = 0,
    this.autoStartCountdown = false,
  });

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  late int _seconds;
  Timer? _timer;
  Timer? _closeTimer;
  bool _isSending = false;
  bool _canInputOtp = false;
  bool _canClose = true;

  @override
  void initState() {
    super.initState();
    // 初始不倒计时，只有在发送成功后再开始倒计时
    _seconds = 0;
    _canClose = widget.closeDelaySeconds <= 0;
    if (widget.autoStartCountdown) {
      setState(() => _canInputOtp = true);
      _scheduleCloseButton();
      _restartTimer();
    } else {
      _sendOtp();
    }
  }

  void _sendOtpAndStartTimer() {
    // 仅在发送成功后才开始倒计时
    _sendOtp();
  }

  Future<void> _sendOtp() async {
    if (_isSending) return;
    _isSending = true;
    try {
      if (widget.onSendOtp != null) {
        final ok = await widget.onSendOtp!(widget.phone);
        if (ok) {
          setState(() => _canInputOtp = true);
          _scheduleCloseButton();
          _restartTimer();
        } else {
          setState(() => _canInputOtp = false);
          // 失败保持秒数为0，允许立即再次发送
          setState(() => _seconds = 0);
          if (widget.closeDelaySeconds > 0) {
            setState(() => _canClose = true);
          }
        }
      }
    } catch (_) {}
    _isSending = false;
  }

  void _scheduleCloseButton() {
    if (widget.closeDelaySeconds <= 0) {
      setState(() => _canClose = true);
      return;
    }
    _closeTimer?.cancel();
    setState(() => _canClose = false);
    _closeTimer = Timer(Duration(seconds: widget.closeDelaySeconds), () {
      if (!mounted) return;
      setState(() => _canClose = true);
    });
  }

  void _restartTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = widget.countdownSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 1) {
        t.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _closeTimer?.cancel();
    super.dispose();
  }

  String _maskPhone(String phone) {
    final p = phone.replaceAll(RegExp(r'\s+'), '');
    if (p.length <= 4) return p;
    final start = p.substring(0, p.length >= 3 ? 3 : 1);
    final end = p.substring(p.length - (p.length >= 4 ? 4 : 1));
    return "$start****$end";
  }

  @override
  Widget build(BuildContext context) {
    final fieldWidth = widget.length >= 6 ? 42.0 : 50.0;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Please enter OTP',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2024),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_canClose)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'OTP sent to ${_maskPhone(widget.phone)}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF71727A)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Center(
                child: OTPInputWidget(
                  length: widget.length,
                  fieldWidth: fieldWidth,
                  autoFocus: true,
                  enabled: _canInputOtp,
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2024),
                  ),
                  onCompleted: (code) {
                    // 不在此处关闭弹窗，等待外部验证登录成功后再关闭
                    widget.onVerified(code);
                  },
                ),
              ),
              if ((widget.errorText ?? '').trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.errorText!.trim(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE74C3C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _seconds > 0
                          ? RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8F9098),
                                  height: 2.2,
                                ),
                                children: [
                                  const TextSpan(text: 'Resend in '),
                                  TextSpan(
                                    text: '$_seconds',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const TextSpan(text: ' seconds'),
                                ],
                              ),
                            )
                          : TextButton(
                              onPressed: _sendOtpAndStartTimer,
                              child: Text(
                                'ReSend OTP',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColor,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

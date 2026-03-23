import 'package:flutter/material.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';

class SuccessResultPage extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final String? subtitle;
  final String? assetIconPath;
  final Color? buttonColor;

  const SuccessResultPage({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onButtonPressed,
    this.subtitle,
    this.assetIconPath,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = buttonColor ?? Theme.of(context).primaryColor;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: assetIconPath != null ? 162 : 120,
                    height: assetIconPath != null ? 162 : 120,
                    decoration: assetIconPath != null
                        ? null
                        : BoxDecoration(
                            color: const Color.fromARGB(255, 242, 255, 239),
                            shape: BoxShape.circle,
                          ),
                    alignment: Alignment.center,
                    child: assetIconPath != null
                        ? Image.asset(
                            assetIconPath!,
                            width: 162,
                            height: 162,
                            fit: BoxFit.contain,
                          )
                        : Icon(Icons.check_circle, color: primary, size: 95),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2024),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8F9098),
                      ),
                    ),
                  ],
                  const SizedBox(height: 35),

                  HxButton(
                    width: double.infinity,
                    height: 52,
                    color: Theme.of(context).primaryColor,
                    fontColor: Colors.white,
                    text: buttonText,
                    onButtonPressed: onButtonPressed,
                  ),

                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

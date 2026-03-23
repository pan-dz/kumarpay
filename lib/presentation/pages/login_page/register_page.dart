import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kumar_pay/presentation/widgets/customer_service.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:provider/provider.dart';
import 'package:kumar_pay/presentation/viewmodels/login_viewmodel/register_viewmodel.dart';
import 'package:kumar_pay/presentation/pages/login_page/login_page.dart';

class RegisterPage extends StatelessWidget {
  final String? inviterCode;
  const RegisterPage({super.key, this.inviterCode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(initialInviterCode: inviterCode ?? ''),
      child: Consumer<RegisterViewModel>(
        builder: (context, vm, _) {
          final customerServiceUrl = vm.customerServiceUrl;
          final shouldOpenCustomerServiceDialog = vm.customerServiceType == 3;
          final isRegisterDisabled = vm.isStoredPhoneMatched;
          return Scaffold(
            body: Stack(
              children: [
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 16.0,
                      ),
                      child: SizedBox(
                        height: 610,
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Image.asset(
                                  'assets/images/login_logo.webp',
                                  width: 152,
                                  height: 76,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 15),
                                const Text(
                                  'Welcome to join us',
                                  style: TextStyle(
                                    color: Color(0xFF2F3036),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),

                            const SizedBox(height: 50),

                            _LabeledInputRow(
                              label: 'Phone',
                              child: TextField(
                                keyboardType: TextInputType.phone,
                                textAlign: TextAlign.end,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10),
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'),
                                  ),
                                ],
                                style: const TextStyle(
                                  color: Color(0xFF1F2024),
                                  fontSize: 16,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'Enter phone number',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF1F2024),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: vm.setPhone,
                              ),
                            ),

                            const SizedBox(height: 12),

                            _LabeledInputRow(
                              label: 'Password',
                              trailing: IconButton(
                                icon: Icon(
                                  vm.obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF8F9098),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 0,
                                  minHeight: 0,
                                ),
                                onPressed: vm.toggleObscure,
                              ),
                              child: TextField(
                                obscureText: vm.obscure,
                                textAlign: TextAlign.end,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(30),
                                ],
                                style: const TextStyle(fontSize: 16),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  hintText: 'Enter password',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF1F2024),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                ),
                                onChanged: vm.setPassword,
                              ),
                            ),

                            const SizedBox(height: 12),

                            _LabeledInputRow(
                              label: 'Confirm',
                              trailing: IconButton(
                                icon: Icon(
                                  vm.obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF8F9098),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 0,
                                  minHeight: 0,
                                ),
                                onPressed: vm.toggleObscureConfirm,
                              ),
                              child: TextField(
                                obscureText: vm.obscureConfirm,
                                textAlign: TextAlign.end,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(30),
                                ],
                                style: const TextStyle(fontSize: 16),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  hintText: 'Password, Again',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF1F2024),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                ),
                                onChanged: vm.setConfirm,
                              ),
                            ),
                            if (vm.confirmMismatch) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: const [
                                  Text(
                                    'The password confirmation does not match',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 12),

                            _LabeledInputRow(
                              label: 'Invitercode',
                              child: Builder(
                                builder: (context) {
                                  final hasInviter = vm.inviterCode
                                      .trim()
                                      .isNotEmpty;
                                  return TextFormField(
                                    controller: vm.inviterController,
                                    readOnly: hasInviter,
                                    enabled: !hasInviter,
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(fontSize: 16),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      hintText: 'Enter inviter code',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF1F2024),
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 68),

                            HxButton(
                              color: isRegisterDisabled
                                  ? const Color(0xFFC5C6CC)
                                  : Theme.of(context).primaryColor,
                              fontColor: Colors.white,
                              text: 'Register',
                              loading: vm.isLoading,
                              onButtonPressed: isRegisterDisabled
                                  ? () {}
                                  : () => vm.handleOpenOtpPopup(context),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Already have an account?",
                                  style: TextStyle(
                                    color: Color(0xFF2F3036),
                                    fontSize: 12,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: Text(
                                    'Go login',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (vm.showCustomerService)
                  CustomerServiceButton(
                    type: CustomerServiceButtonType.contact,
                    visible: true,
                    initiallyOpen: shouldOpenCustomerServiceDialog,
                    chatUrl: customerServiceUrl,
                    autoLaunchOnAppear: !shouldOpenCustomerServiceDialog,
                    launchExternallyForSocialLinks:
                        !shouldOpenCustomerServiceDialog,
                    // topReservedHeight: 48,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LabeledInputRow extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? trailing;

  const _LabeledInputRow({
    required this.label,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.only(top: 0.0, bottom: 14.0),
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(color: Color(0xFFC5C6CC), width: 0.5),
        ),
      ),
      height: 48,
      child: Material(
        color: Colors.transparent,
        // borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8F9098),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: child),
            const SizedBox(width: 6),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

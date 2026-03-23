import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:provider/provider.dart';
import 'package:kumar_pay/presentation/widgets/nav_app_bar.dart';
import 'package:kumar_pay/presentation/pages/login_page/login_page.dart';
import 'package:kumar_pay/presentation/viewmodels/login_viewmodel/modify_pwd_viewmodel.dart';
import 'package:kumar_pay/presentation/viewmodels/login_viewmodel/login_viewmodel.dart';
import 'package:kumar_pay/core/formatters/indian_phone_input_formatter.dart';

class ModifyPwdPage extends StatelessWidget {
  final String? phone;
  final String? type;
  const ModifyPwdPage({super.key, this.phone, this.type});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ModifyPwdViewModel(phone: phone ?? ''),
        ),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: Consumer<ModifyPwdViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: const NavAppBar(title: 'Modify password'),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 32.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LabeledInputRow(
                      label: 'Phone',
                      child: TextFormField(
                        initialValue: vm.phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [IndianPhoneInputFormatter()],
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Enter phone number',
                          hintStyle: TextStyle(color: Color(0xFF1F2024)),
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                        onChanged: vm.setPhone,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _LabeledInputRow(
                      label: 'Password',
                      trailing: IconButton(
                        icon: Icon(
                          vm.obscure ? Icons.visibility_off : Icons.visibility,
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
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Enter new password',
                          hintStyle: TextStyle(color: Color(0xFF1F2024)),
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(30)],
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
                        style: const TextStyle(fontSize: 16),
                        inputFormatters: [LengthLimitingTextInputFormatter(30)],
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Password, Again',
                          hintStyle: TextStyle(color: Color(0xFF1F2024)),
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
                            style: TextStyle(color: Colors.red, fontSize: 12),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 40),

                    HxButton(
                      color: vm.canSubmit
                          ? Theme.of(context).primaryColor
                          : const Color(0xFF66D98F),
                      fontColor: Colors.white,
                      text: 'Modify',
                      loading: vm.isLoading,
                      onButtonPressed: vm.canSubmit
                          ? () => vm.handleOpenModify(context)
                          : () {},
                    ),

                    const SizedBox(height: 10),

                    if (type != 'mine modify')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account,",
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
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFC5C6CC), width: 0.5),
        ),
      ),
      height: 48,
      child: Row(
        children: [
          const SizedBox(width: 4),
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
    );
  }
}

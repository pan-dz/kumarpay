import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:kumar_pay/app/services/app_update_service.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:provider/provider.dart';
import 'package:kumar_pay/presentation/viewmodels/login_viewmodel/login_viewmodel.dart';
import 'package:kumar_pay/presentation/pages/login_page/register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, vm, _) {
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                                'Earn with UPI - Link & Share',
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

                          // Phone input
                          _InputContainer(
                            child: TextField(
                              controller: vm.phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'),
                                ),
                              ],
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter the phone number',
                                hintStyle: TextStyle(
                                  color: Color(0xFF8F9098),
                                  fontWeight: FontWeight.w500,
                                  height: 1.20,
                                ),
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Color(0xFF00BC48),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                              ),
                              onChanged: vm.setPhone,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Password input
                          _InputContainer(
                            child: TextField(
                              controller: vm.passwordController,
                              obscureText: vm.obscure,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(30),
                              ],
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Please enter the password',
                                hintStyle: TextStyle(
                                  color: Color(0xFF8F9098),
                                  fontWeight: FontWeight.w500,
                                  height: 1.20,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Theme.of(context).primaryColor,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    vm.obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Color(0xFF8F9098),
                                  ),
                                  onPressed: vm.toggleObscure,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                              ),
                              onChanged: vm.setPassword,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Save and change password text buttons, left and right
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              runSpacing: 8,
                              spacing: 12,
                              children: [
                                TextButton(
                                  onPressed: vm.toggleSavePassword,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            vm.savePassword
                                                ? Container(
                                                    width: 9,
                                                    height: 9,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Save Password',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                TextButton(
                                  onPressed: () => vm.resetPassword(context),
                                  child: Text(
                                    'Change Password',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 90),

                          HxButton(
                            color: Theme.of(context).primaryColor,
                            fontColor: Colors.white,
                            text: 'Login',
                            loading: vm.isLoading,
                            onButtonPressed: () =>
                                vm.checkNeedVerificationCode(context),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: Color(0xFF2F3036),
                                  fontSize: 12,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Register',
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
                if (!kIsWeb)
                  const Positioned(
                    right: 12,
                    bottom: 8,
                    child: _LoginVersionText(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InputContainer extends StatelessWidget {
  final Widget child;

  const _InputContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(color: Color(0xFFC5C6CC), width: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        // borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}

class _LoginVersionText extends StatefulWidget {
  const _LoginVersionText();

  @override
  State<_LoginVersionText> createState() => _LoginVersionTextState();
}

class _LoginVersionTextState extends State<_LoginVersionText> {
  late final Future<String> _versionFuture;

  @override
  void initState() {
    super.initState();
    _versionFuture = _getVersionText();
  }

  Future<String> _getVersionText() async {
    return AppUpdateService.getDisplayVersionText();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _versionFuture,
      builder: (context, snapshot) {
        final versionText = snapshot.data ?? 'v--+--';
        return Text(
          versionText,
          style: const TextStyle(
            color: Color(0xFF8F9098),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';
import 'package:kumar_pay/app/services/app_update_service.dart';
import 'package:kumar_pay/presentation/pages/layout_page.dart';
import 'package:kumar_pay/presentation/pages/login_page/login_page.dart';
import 'package:kumar_pay/presentation/pages/login_page/register_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final splashDelay = Future<void>.delayed(
      const Duration(milliseconds: 1500),
    );
    final updateCheck = AppUpdateService.ensureChecked(context);

    await splashDelay;
    if (!mounted) return;

    if (kIsWeb) {
      final rs = Uri.base.queryParameters['rs'];
      if (rs != null && rs.trim().isNotEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RegisterPage(inviterCode: rs.trim()),
          ),
        );
        return;
      }
    }

    await updateCheck;
    if (!mounted) return;

    // Navigator.of(
    //   context,
    // ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));

    if (GetStorage().read(StorageKeys.token) != null) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LayoutPage()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/login_logo.webp',
              width: 152,
              height: 76,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            const Text('Loading...', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

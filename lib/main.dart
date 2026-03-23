import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumar_pay/app/config/base_config.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';
import 'package:kumar_pay/app/services/inappwebview_platform_initializer.dart';
import 'package:kumar_pay/app/theme/app_theme.dart';
import 'package:kumar_pay/presentation/pages/splash_page.dart';
import 'package:kumar_pay/app/router/app_router.dart';
import 'package:kumar_pay/presentation/viewmodels/home_viewmodel/home_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/customer_service.dart';
import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:kumar_pay/app/analytics/adjust_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeInAppWebViewPlatform();

  await GetStorage.init();

  const AdjustEnvironment adjustEnvironment = AdjustEnvironment.sandbox;
  final AdjustConfig adjustConfig = AdjustConfig(
    KumarBaseConfig.adjustAppToken,
    adjustEnvironment,
  );
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    adjustConfig.logLevel = AdjustLogLevel.verbose;
  }
  Adjust.initSdk(adjustConfig);
  AdjustTracker.fetchIdsOnLaunch();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'KumarPay',
      theme: appTheme,
      navigatorKey: AppRouter.navigatorKey,
      navigatorObservers: [AppRouter.routeObserver],
      onGenerateRoute: AppRouter.generateRoute,
      home: const SplashPage(),
      builder: (context, child) {
        return _GlobalCustomerServiceHost(
          child: child ?? const SizedBox.shrink(),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class _GlobalCustomerServiceHost extends ConsumerStatefulWidget {
  final Widget child;

  const _GlobalCustomerServiceHost({required this.child});

  @override
  ConsumerState<_GlobalCustomerServiceHost> createState() =>
      _GlobalCustomerServiceHostState();
}

class _GlobalCustomerServiceHostState
    extends ConsumerState<_GlobalCustomerServiceHost> {
  final GetStorage _box = GetStorage();
  late final VoidCallback _disposeTokenListener;

  @override
  void initState() {
    super.initState();
    _disposeTokenListener = _box.listenKey(StorageKeys.token, (_) {
      if (!mounted) {
        return;
      }
      final token = _box.read<String>(StorageKeys.token) ?? '';
      if (token.isEmpty) {
        ref.read(customerServiceVisibilityProvider.notifier).clear();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _disposeTokenListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final token = _box.read<String>(StorageKeys.token) ?? '';
    final customerServiceLink = ref.watch(homeViewModelProvider).tgChannelLink;
    final visibilityKeys = ref.watch(customerServiceVisibilityProvider);
    final shouldShowCustomerService =
        token.isNotEmpty && visibilityKeys.isNotEmpty;

    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        if (shouldShowCustomerService)
          CustomerServiceButton(
            type: CustomerServiceButtonType.contact,
            visible: shouldShowCustomerService,
            chatUrl: customerServiceLink,
            launchExternallyForSocialLinks: true,
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../presentation/pages/login_page/login_page.dart' deferred as login;
import '../../presentation/pages/buy_page/buy_page.dart' deferred as buy;
import '../../presentation/pages/home_page/home_page.dart' deferred as home;
import '../../presentation/pages/login_page/register_page.dart'
    deferred as register;

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final RouteObserver<PageRoute<dynamic>> routeObserver =
      RouteObserver<PageRoute<dynamic>>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return _deferredRoute(
          settings,
          login.loadLibrary,
          (_) => login.LoginPage(),
        );
      case '/register':
        return _deferredRoute(
          settings,
          register.loadLibrary,
          (_) => register.RegisterPage(),
        );
      case '/':
        return _deferredRoute(
          settings,
          home.loadLibrary,
          (_) => home.HomePage(),
        );
      case '/buy':
        return _deferredRoute(settings, buy.loadLibrary, (_) => buy.BuyPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
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
          ),
        );
    }
  }
}

Route<dynamic> _deferredRoute(
  RouteSettings settings,
  Future<void> Function() loadLibrary,
  WidgetBuilder builder,
) {
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => _DeferredPage(loadLibrary: loadLibrary, builder: builder),
  );
}

class _DeferredPage extends StatefulWidget {
  const _DeferredPage({required this.loadLibrary, required this.builder});

  final Future<void> Function() loadLibrary;
  final WidgetBuilder builder;

  @override
  State<_DeferredPage> createState() => _DeferredPageState();
}

class _DeferredPageState extends State<_DeferredPage> {
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = widget.loadLibrary();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text('页面加载失败，请重试')));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return widget.builder(context);
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

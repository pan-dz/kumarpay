import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/app/router/app_router.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher.dart';

final InAppWebViewKeepAlive _customerServiceKeepAlive = InAppWebViewKeepAlive();

final customerServiceVisibilityProvider =
    StateNotifierProvider<CustomerServiceVisibilityController, Set<String>>(
      (ref) => CustomerServiceVisibilityController(),
    );

class CustomerServiceVisibilityController extends StateNotifier<Set<String>> {
  CustomerServiceVisibilityController() : super(<String>{});

  void activate(String key) {
    if (state.contains(key)) {
      return;
    }
    state = {...state, key};
  }

  void deactivate(String key) {
    if (!state.contains(key)) {
      return;
    }
    final next = {...state};
    next.remove(key);
    state = next;
  }

  void clear() {
    if (state.isEmpty) {
      return;
    }
    state = <String>{};
  }
}

enum CustomerServiceButtonType {
  contact, // 联系客服
  feedback, // 意见反馈
  faq, // 常见问题
}

class CustomerServiceRouteScope extends ConsumerStatefulWidget {
  final String pageId;
  final Widget child;

  const CustomerServiceRouteScope({
    super.key,
    required this.pageId,
    required this.child,
  });

  @override
  ConsumerState<CustomerServiceRouteScope> createState() =>
      _CustomerServiceRouteScopeState();
}

class _CustomerServiceRouteScopeState
    extends ConsumerState<CustomerServiceRouteScope>
    with RouteAware {
  PageRoute<dynamic>? _route;
  bool _isActive = false;
  late final String _visibilityKey =
      '${widget.pageId}_${identityHashCode(this)}';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is! PageRoute<dynamic> || identical(route, _route)) {
      return;
    }

    if (_route != null) {
      AppRouter.routeObserver.unsubscribe(this);
    }

    _route = route;
    AppRouter.routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    AppRouter.routeObserver.unsubscribe(this);
    _setActive(false);
    super.dispose();
  }

  @override
  void didPush() {
    _setActive(true);
  }

  @override
  void didPopNext() {
    _setActive(true);
  }

  @override
  void didPushNext() {
    _setActive(false);
  }

  @override
  void didPop() {
    _setActive(false);
  }

  void _setActive(bool active) {
    if (_isActive == active) {
      return;
    }
    _isActive = active;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final notifier = ref.read(customerServiceVisibilityProvider.notifier);
      if (active) {
        notifier.activate(_visibilityKey);
      } else {
        notifier.deactivate(_visibilityKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class CustomerServiceButton extends StatefulWidget {
  final CustomerServiceButtonType type;
  final double defaultSize;
  final double bottomReservedHeight; // 底部保留高度（如底部导航栏）
  final double topReservedHeight; // 顶部保留高度
  final String openImageAssetPath;
  final String closeImageAssetPath;
  final String chatUrl;
  final bool visible;
  final bool initiallyOpen;
  final bool launchExternallyForSocialLinks;
  final bool autoLaunchOnAppear;

  const CustomerServiceButton({
    super.key,
    required this.type,
    this.defaultSize = 70.0,
    this.bottomReservedHeight = 100.0,
    this.topReservedHeight = 100.0,
    this.openImageAssetPath = 'assets/images/customer_service.webp',
    this.closeImageAssetPath = 'assets/images/customer_service1.webp',
    this.chatUrl = '',
    this.visible = true,
    this.initiallyOpen = false,
    this.launchExternallyForSocialLinks = false,
    this.autoLaunchOnAppear = false,
  });

  @override
  State<CustomerServiceButton> createState() => _CustomerServiceButtonState();
}

class _CustomerServiceButtonState extends State<CustomerServiceButton> {
  late Offset _position;
  double _currentSize = 70.0;
  bool _isDialogVisible = false;
  String _effectiveChatUrl = '';
  bool _hasAutoLaunched = false;

  @override
  void initState() {
    super.initState();
    // 初始位置
    _position = const Offset(20, 300);
    _currentSize = widget.defaultSize;
    _isDialogVisible = widget.initiallyOpen;
    _effectiveChatUrl = widget.chatUrl.trim();
    _scheduleAutoLaunchIfNeeded();

    // 首帧后再读取 MediaQuery 以避免在 initState 访问上下文依赖
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      final effectiveHeight = size.height - widget.bottomReservedHeight;
      const defaultBottomOffset = 70.0;
      setState(() {
        // 默认位置
        _position = Offset(
          size.width - _currentSize - 5,
          effectiveHeight - _currentSize - defaultBottomOffset,
        );
      });
    });
  }

  @override
  void didUpdateWidget(covariant CustomerServiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextChatUrl = widget.chatUrl.trim();
    if (nextChatUrl != _effectiveChatUrl) {
      _effectiveChatUrl = nextChatUrl;
      _hasAutoLaunched = false;
    }

    if (oldWidget.visible != widget.visible && widget.visible) {
      _hasAutoLaunched = false;
    }

    _scheduleAutoLaunchIfNeeded();
  }

  void _scheduleAutoLaunchIfNeeded() {
    if (!widget.autoLaunchOnAppear ||
        !widget.visible ||
        _hasAutoLaunched ||
        !_shouldAutoLaunchExternally()) {
      return;
    }

    _hasAutoLaunched = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _handleTap();
    });
  }

  bool _shouldAutoLaunchExternally() {
    return widget.launchExternallyForSocialLinks &&
        _shouldLaunchExternally(_effectiveChatUrl);
  }

  @override
  Widget build(BuildContext context) {
    final isExternalChat =
        widget.launchExternallyForSocialLinks &&
        _shouldLaunchExternally(_effectiveChatUrl);
    final screenSize = MediaQuery.of(context).size;
    final effectiveHeight = screenSize.height - widget.bottomReservedHeight;
    const horizontalMargin = 10.0;
    const bottomMargin = 8.0;
    const popupSpacing = 12.0;
    final availableWidth = (screenSize.width - horizontalMargin * 2).clamp(
      220.0,
      double.infinity,
    );
    final popupWidth = availableWidth.clamp(220.0, 360.0);
    final availableHeight =
        (effectiveHeight - widget.topReservedHeight - bottomMargin).clamp(
          220.0,
          double.infinity,
        );
    final popupHeight = (screenSize.height * 0.76).clamp(
      220.0,
      availableHeight,
    );
    final popupLeftMax = screenSize.width - popupWidth - horizontalMargin;
    final popupLeft = _safeClamp(
      _position.dx + _currentSize - popupWidth,
      horizontalMargin,
      popupLeftMax,
    );
    final popupTopMax = effectiveHeight - popupHeight - bottomMargin;
    final aboveSpace = _position.dy - widget.topReservedHeight - popupSpacing;
    final belowTop = _position.dy + _currentSize + popupSpacing;
    final belowSpace = effectiveHeight - bottomMargin - belowTop;
    final shouldShowBelow = aboveSpace < popupHeight && belowSpace > aboveSpace;
    final desiredPopupTop = shouldShowBelow
        ? belowTop
        : _position.dy - popupHeight - popupSpacing;
    final popupTop = _safeClamp(
      desiredPopupTop,
      widget.topReservedHeight,
      popupTopMax,
    );
    final imageAssetPath = _isDialogVisible
        ? widget.closeImageAssetPath
        : widget.openImageAssetPath;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !widget.visible,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          opacity: widget.visible ? 1 : 0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: popupLeft,
                top: popupTop,
                width: popupWidth,
                height: popupHeight,
                child: IgnorePointer(
                  ignoring:
                      !_isDialogVisible || !widget.visible || isExternalChat,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    opacity:
                        _isDialogVisible && widget.visible && !isExternalChat
                        ? 1
                        : 0,
                    child: _CustomerServicePanel(url: _effectiveChatUrl),
                  ),
                ),
              ),
              Positioned(
                left: _position.dx,
                top: _position.dy,
                child: PointerInterceptor(
                  child: GestureDetector(
                    onPanStart: (details) {},
                    onPanUpdate: (details) {
                      setState(() {
                        _position = Offset(
                          _position.dx + details.delta.dx,
                          _position.dy + details.delta.dy,
                        );
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _snapToEdge(context);
                        _ensureInScreen(context);
                      });
                    },
                    onTap: _handleTap,
                    onLongPress: () {},
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _currentSize,
                      height: _currentSize,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: ClipOval(
                          key: ValueKey<String>(imageAssetPath),
                          child: Image.asset(
                            imageAssetPath,
                            width: _currentSize,
                            height: _currentSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF1F2024),
                                alignment: Alignment.center,
                                child: Icon(
                                  _isDialogVisible
                                      ? Icons.close_rounded
                                      : Icons.support_agent,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _togglePopup() {
    setState(() {
      _isDialogVisible = !_isDialogVisible;
    });
  }

  Future<void> _handleTap() async {
    final chatUrl = _effectiveChatUrl.trim();
    if (chatUrl.isEmpty) {
      return;
    }

    if (widget.launchExternallyForSocialLinks &&
        _shouldLaunchExternally(chatUrl)) {
      final uri = Uri.tryParse(chatUrl);
      if (uri == null) {
        return;
      }

      final appUri = _buildPreferredExternalUri(uri);
      if (appUri != null && await canLaunchUrl(appUri)) {
        final launched = await launchUrl(
          appUri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          return;
        }
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        return;
      }

      await launchUrl(uri, mode: LaunchMode.platformDefault);
      return;
    }

    _togglePopup();
  }

  Uri? _buildPreferredExternalUri(Uri uri) {
    final host = uri.host.toLowerCase();

    if (host == 'wa.me' || host.endsWith('.whatsapp.com')) {
      String phone = '';
      if (host == 'wa.me') {
        phone = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      } else {
        phone = uri.queryParameters['phone'] ?? '';
      }
      phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (phone.isEmpty) {
        return null;
      }
      return Uri.parse('whatsapp://send?phone=$phone');
    }

    if (host == 't.me' || host == 'telegram.me' || host.endsWith('.t.me')) {
      final domain = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      if (domain.isEmpty) {
        return null;
      }
      return Uri.parse('tg://resolve?domain=$domain');
    }

    return null;
  }

  bool _shouldLaunchExternally(String url) {
    final uri = Uri.tryParse(url.trim());
    final host = uri?.host.toLowerCase() ?? '';
    if (host.isEmpty) {
      return false;
    }

    return host == 't.me' ||
        host == 'telegram.me' ||
        host.endsWith('.t.me') ||
        host == 'wa.me' ||
        host.endsWith('.whatsapp.com');
  }

  double _safeClamp(double value, double min, double max) {
    if (max < min) {
      return min;
    }
    return value.clamp(min, max).toDouble();
  }

  void _snapToEdge(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final effectiveHeight = size.height - widget.bottomReservedHeight;
    const snapThreshold = 30.0;

    // 如果靠近左边缘
    if (_position.dx < snapThreshold) {
      _position = Offset(0, _position.dy);
    }
    // 如果靠近右边缘
    else if (_position.dx > screenWidth - _currentSize - snapThreshold) {
      _position = Offset(screenWidth - _currentSize, _position.dy);
    }
    // 如果靠近上边缘
    if (_position.dy < snapThreshold) {
      _position = Offset(_position.dx, widget.topReservedHeight);
    }
    // 如果靠近下边缘
    else if (_position.dy > effectiveHeight - _currentSize - snapThreshold) {
      _position = Offset(_position.dx, effectiveHeight - _currentSize);
    }
  }

  void _ensureInScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final effectiveHeight = size.height - widget.bottomReservedHeight;

    _position = Offset(
      _position.dx.clamp(0, screenWidth - _currentSize),
      _position.dy.clamp(
        widget.topReservedHeight,
        effectiveHeight - _currentSize,
      ),
    );
  }
}

class _CustomerServicePanel extends StatefulWidget {
  final String url;

  const _CustomerServicePanel({required this.url});

  @override
  State<_CustomerServicePanel> createState() => _CustomerServicePanelState();
}

class _CustomerServicePanelState extends State<_CustomerServicePanel> {
  InAppWebViewController? _controller;
  double _progress = 0;
  String? _errorMessage;

  @override
  void didUpdateWidget(covariant _CustomerServicePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url == widget.url) {
      return;
    }

    final controller = _controller;
    if (controller == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = null;
        _progress = 0;
      });
      await controller.loadUrl(urlRequest: URLRequest(url: WebUri(widget.url)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (_progress > 0 && _progress < 1)
            LinearProgressIndicator(
              value: _progress,
              minHeight: 2,
              backgroundColor: const Color(0xFFF2F3F5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2C8DFF),
              ),
            ),
          Expanded(
            child: _errorMessage != null
                ? _CustomerServiceErrorView(
                    message: _errorMessage!,
                    onRetry: _reload,
                  )
                : InAppWebView(
                    keepAlive: _customerServiceKeepAlive,
                    initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                      clearCache: false,
                      cacheEnabled: true,
                      domStorageEnabled: true,
                      thirdPartyCookiesEnabled: true,
                      mixedContentMode:
                          MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                      supportZoom: false,
                      transparentBackground: true,
                    ),
                    onWebViewCreated: (controller) {
                      _controller = controller;
                    },
                    onProgressChanged: (controller, progress) {
                      if (!mounted) {
                        return;
                      }
                      setState(() {
                        _progress = progress / 100;
                      });
                    },
                    onLoadStart: (controller, url) {
                      if (!mounted) {
                        return;
                      }
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                    onReceivedError: (controller, request, error) {
                      if (request.isForMainFrame == false || !mounted) {
                        return;
                      }
                      setState(() {
                        _errorMessage = error.description;
                        _progress = 1;
                      });
                    },
                    onReceivedHttpError: (controller, request, errorResponse) {
                      if (request.isForMainFrame == false || !mounted) {
                        return;
                      }
                      setState(() {
                        _errorMessage =
                            'HTTP ${errorResponse.statusCode}: ${errorResponse.reasonPhrase ?? 'Page load failed'}';
                        _progress = 1;
                      });
                    },
                    onPermissionRequest: (controller, permissionRequest) async {
                      return PermissionResponse(
                        action: PermissionResponseAction.GRANT,
                        resources: permissionRequest.resources,
                      );
                    },
                    onCreateWindow: (controller, createWindowAction) async {
                      await controller.loadUrl(
                        urlRequest: createWindowAction.request,
                      );
                      return true;
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _reload() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _progress = 0;
    });
    await controller.loadUrl(urlRequest: URLRequest(url: WebUri(widget.url)));
  }
}

class _CustomerServiceErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CustomerServiceErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F7F9),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: Color(0xFF8F9098),
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to open customer service',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1F2024),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8F9098),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1F2024),
              foregroundColor: Colors.white,
              minimumSize: const Size(140, 44),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

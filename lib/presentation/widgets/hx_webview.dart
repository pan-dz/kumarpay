import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kumar_pay/app/router/app_router.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'package:kumar_pay/presentation/widgets/nav_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class HxWebViewCookie {
  final String name;
  final String value;
  final String path;
  final String? domain;
  final int? expiresDate;
  final int? maxAge;
  final bool? isSecure;
  final bool? isHttpOnly;
  final HTTPCookieSameSitePolicy? sameSite;

  const HxWebViewCookie({
    required this.name,
    required this.value,
    this.path = '/',
    this.domain,
    this.expiresDate,
    this.maxAge,
    this.isSecure,
    this.isHttpOnly,
    this.sameSite,
  });
}

class HxWebView extends StatefulWidget {
  static const Set<String> _downloadableExtensions = {
    'apk',
    'zip',
    'rar',
    '7z',
    'pdf',
    'csv',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'mp3',
    'mp4',
    'avi',
    'mov',
  };

  final String url;
  final String title;
  final bool showAppBar;
  final bool clearCache;
  final bool enableDebugLogging;
  final bool autoGrantPermissions;
  final String? userAgent;
  final Map<String, String> initialHeaders;
  final List<HxWebViewCookie> initialCookies;
  final VoidCallback? onClose;
  final Future<void> Function(InAppWebViewController controller, Uri? url)?
  onLoadStart;
  final Future<void> Function(InAppWebViewController controller, Uri? url)?
  onLoadStop;
  final Future<NavigationActionPolicy?> Function(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  )?
  shouldOverrideUrlLoading;

  const HxWebView({
    super.key,
    required this.url,
    this.title = '',
    this.showAppBar = true,
    this.clearCache = false,
    this.enableDebugLogging = true,
    this.autoGrantPermissions = true,
    this.userAgent,
    this.initialHeaders = const {},
    this.initialCookies = const [],
    this.onClose,
    this.onLoadStart,
    this.onLoadStop,
    this.shouldOverrideUrlLoading,
  });

  @override
  State<HxWebView> createState() => _HxWebViewState();

  static Future<void> openUrl(String url) async {
    final normalizedUrl = url.trim();
    final rootContext = AppRouter.navigatorKey.currentContext;

    if (normalizedUrl.isEmpty) {
      if (rootContext != null) {
        AppToast.warning(rootContext, 'Invalid link');
      }
      return;
    }

    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null || uri.scheme.isEmpty) {
      if (rootContext != null) {
        AppToast.warning(rootContext, 'Invalid link');
      }
      return;
    }

    if (_shouldOpenExternally(uri)) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && rootContext != null) {
        AppToast.error(rootContext, 'Could not open link');
      }
      return;
    }

    final navigator = AppRouter.navigatorKey.currentState;
    if (navigator == null) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && rootContext != null) {
        AppToast.error(rootContext, 'Could not open link');
      }
      return;
    }

    await navigator.push(
      MaterialPageRoute(builder: (_) => HxWebView(url: normalizedUrl)),
    );
  }

  static bool _shouldOpenExternally(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return true;
    }

    final lastSegment = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
    final extension = lastSegment.contains('.')
        ? lastSegment.split('.').last.toLowerCase()
        : '';

    if (_downloadableExtensions.contains(extension)) {
      return true;
    }

    if (uri.queryParameters.containsKey('download')) {
      return true;
    }

    return false;
  }
}

class _HxWebViewState extends State<HxWebView> {
  final CookieManager _cookieManager = CookieManager.instance();
  InAppWebViewController? _controller;
  bool _isPreparing = true;
  double _progress = 0;
  String _pageTitle = '';
  String? _errorTitle;
  String? _errorMessage;
  int? _errorStatusCode;
  WebUri? _failingUrl;
  int _webViewKey = 0;

  @override
  void initState() {
    super.initState();
    _prepareWebView();
  }

  Future<void> _prepareWebView() async {
    setState(() {
      _isPreparing = true;
      _progress = 0;
      _errorTitle = null;
      _errorMessage = null;
      _errorStatusCode = null;
      _failingUrl = null;
    });

    if (widget.clearCache) {
      await _cookieManager.deleteAllCookies();
      await _cookieManager.removeSessionCookies();
    }

    final url = WebUri(widget.url);
    for (final cookie in widget.initialCookies) {
      await _cookieManager.setCookie(
        url: url,
        name: cookie.name,
        value: cookie.value,
        path: cookie.path,
        domain: cookie.domain,
        expiresDate: cookie.expiresDate,
        maxAge: cookie.maxAge,
        isSecure: cookie.isSecure,
        isHttpOnly: cookie.isHttpOnly,
        sameSite: cookie.sameSite,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isPreparing = false;
    });
  }

  URLRequest _buildInitialRequest() {
    return URLRequest(
      url: WebUri(widget.url),
      headers: widget.initialHeaders.isEmpty ? null : widget.initialHeaders,
    );
  }

  void _resetPageError() {
    if (_errorTitle == null &&
        _errorMessage == null &&
        _errorStatusCode == null) {
      return;
    }
    setState(() {
      _errorTitle = null;
      _errorMessage = null;
      _errorStatusCode = null;
      _failingUrl = null;
    });
  }

  void _setMainFrameHttpError(
    WebResourceRequest request,
    WebResourceResponse errorResponse,
  ) {
    if (request.isForMainFrame == false) {
      return;
    }

    if (widget.enableDebugLogging) {
      debugPrint(
        '[HxWebView] HTTP error ${errorResponse.statusCode} for ${request.url}',
      );
    }

    setState(() {
      _errorTitle = 'Page load failed';
      _errorMessage = errorResponse.reasonPhrase?.trim().isNotEmpty == true
          ? errorResponse.reasonPhrase
          : 'The server returned an unexpected status code.';
      _errorStatusCode = errorResponse.statusCode;
      _failingUrl = request.url;
      _progress = 1;
    });
  }

  void _setMainFrameLoadError(
    WebResourceRequest request,
    WebResourceError error,
  ) {
    if (request.isForMainFrame == false) {
      return;
    }

    if (widget.enableDebugLogging) {
      debugPrint(
        '[HxWebView] Load error for ${request.url}: ${error.description}',
      );
    }

    setState(() {
      _errorTitle = 'Unable to open page';
      _errorMessage = error.description;
      _errorStatusCode = null;
      _failingUrl = request.url;
      _progress = 1;
    });
  }

  Future<void> _retry() async {
    _resetPageError();
    final controller = _controller;
    if (controller != null) {
      await controller.loadUrl(urlRequest: _buildInitialRequest());
      return;
    }

    await _prepareWebView();
    if (!mounted) {
      return;
    }
    setState(() {
      _webViewKey += 1;
    });
  }

  Widget _buildErrorView(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: Color(0xFF8F9098),
          ),
          const SizedBox(height: 16),
          Text(
            _errorTitle ?? 'Page load failed',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1F2024),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_errorStatusCode != null) ...[
            const SizedBox(height: 8),
            Text(
              'HTTP $_errorStatusCode',
              style: const TextStyle(
                color: Color(0xFF8F9098),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            _errorMessage ??
                'The page could not be loaded in the current WebView.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8F9098),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          if (_failingUrl != null) ...[
            const SizedBox(height: 8),
            Text(
              _failingUrl.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB1B3BB),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _retry,
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

  Future<void> _handleBack() async {
    final controller = _controller;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
      return;
    }

    if (!mounted) {
      return;
    }

    if (widget.onClose != null) {
      widget.onClose!();
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentTitle = _pageTitle.isNotEmpty ? _pageTitle : widget.title;
    final webView = InAppWebView(
      key: ValueKey(_webViewKey),
      initialUrlRequest: _buildInitialRequest(),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        clearCache: widget.clearCache,
        cacheEnabled: true,
        domStorageEnabled: true,
        thirdPartyCookiesEnabled: true,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        supportZoom: false,
        transparentBackground: true,
        allowsBackForwardNavigationGestures: true,
        useOnDownloadStart: true,
        userAgent: widget.userAgent,
        useShouldOverrideUrlLoading: widget.shouldOverrideUrlLoading != null,
      ),
      onWebViewCreated: (controller) {
        _controller = controller;
      },
      onTitleChanged: (controller, title) {
        if (!mounted || title == null || title.isEmpty) {
          return;
        }
        setState(() {
          _pageTitle = title;
        });
      },
      onProgressChanged: (controller, progress) {
        if (!mounted) {
          return;
        }
        setState(() {
          _progress = progress / 100;
        });
      },
      onLoadStart: (controller, url) async {
        if (mounted) {
          _resetPageError();
        }
        if (widget.enableDebugLogging) {
          debugPrint('[HxWebView] onLoadStart: $url');
        }
        if (widget.onLoadStart != null) {
          await widget.onLoadStart!(controller, url);
        }
      },
      onLoadStop: (controller, url) async {
        if (!mounted) {
          return;
        }
        setState(() {
          _progress = 1;
        });
        if (widget.enableDebugLogging) {
          debugPrint('[HxWebView] onLoadStop: $url');
        }
        if (widget.onLoadStop != null) {
          await widget.onLoadStop!(controller, url);
        }
      },
      onReceivedError: (controller, request, error) {
        _setMainFrameLoadError(request, error);
      },
      onReceivedHttpError: (controller, request, errorResponse) {
        _setMainFrameHttpError(request, errorResponse);
      },
      onConsoleMessage: (controller, consoleMessage) {
        if (!widget.enableDebugLogging) {
          return;
        }
        debugPrint(
          '[HxWebView][${consoleMessage.messageLevel}] ${consoleMessage.message}',
        );
      },
      onPermissionRequest: (controller, permissionRequest) async {
        if (!widget.autoGrantPermissions) {
          return PermissionResponse(
            action: PermissionResponseAction.DENY,
            resources: permissionRequest.resources,
          );
        }
        return PermissionResponse(
          action: PermissionResponseAction.GRANT,
          resources: permissionRequest.resources,
        );
      },
      onCreateWindow: (controller, createWindowAction) async {
        if (widget.enableDebugLogging) {
          debugPrint(
            '[HxWebView] onCreateWindow: ${createWindowAction.request.url}',
          );
        }
        await controller.loadUrl(urlRequest: createWindowAction.request);
        return true;
      },
      shouldOverrideUrlLoading: widget.shouldOverrideUrlLoading,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: widget.showAppBar
            ? NavAppBar(
                title: currentTitle.isEmpty ? 'Web View' : currentTitle,
                onBack: _handleBack,
              )
            : null,
        body: Column(
          children: [
            if (_progress > 0 && _progress < 1)
              LinearProgressIndicator(
                value: _progress,
                minHeight: 2,
                backgroundColor: const Color(0xFFF2F3F5),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF1F2024),
                ),
              ),
            Expanded(
              child: _isPreparing
                  ? const Center(child: CircularProgressIndicator())
                  : (_errorTitle != null || _errorMessage != null)
                  ? _buildErrorView(context)
                  : webView,
            ),
          ],
        ),
      ),
    );
  }
}

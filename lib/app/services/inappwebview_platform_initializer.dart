import 'inappwebview_platform_initializer_stub.dart'
    if (dart.library.io) 'inappwebview_platform_initializer_io.dart'
    if (dart.library.js_interop) 'inappwebview_platform_initializer_web.dart'
    as initializer;

void initializeInAppWebViewPlatform() {
  initializer.initializeInAppWebViewPlatform();
}

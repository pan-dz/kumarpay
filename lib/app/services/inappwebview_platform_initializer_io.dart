import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_inappwebview_macos/flutter_inappwebview_macos.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';

void initializeInAppWebViewPlatform() {
  if (Platform.isAndroid) {
    AndroidInAppWebViewPlatform.registerWith();
  } else if (Platform.isIOS) {
    IOSInAppWebViewPlatform.registerWith();
  } else if (Platform.isMacOS) {
    MacOSInAppWebViewPlatform.registerWith();
  } else if (Platform.isWindows) {
    WindowsInAppWebViewPlatform.registerWith();
  }
}

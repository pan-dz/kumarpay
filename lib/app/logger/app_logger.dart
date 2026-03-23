import 'dart:convert';

import 'package:flutter/foundation.dart';

extension LogExtension on dynamic {
  void log([String tag = 'LOG']) {
    if (kReleaseMode) return;

    final time = DateTime.now().toString().split('.').first;
    final value = this;
    debugPrint(
      ' ✅ ====================================== Log Start  ====================================== ✅ ',
    );
    debugPrint('$time [$tag] $value');
    debugPrint(
      ' ✅ ====================================== Log End  ====================================== ✅ ',
    );
  }

  void logJson() {
    if (kReleaseMode) return;

    try {
      final time = DateTime.now().toString().split('.').first;
      final encoder = JsonEncoder.withIndent('  ');
      final formatted = encoder.convert(this);

      debugPrint(
        ' 🔔 ====================================== logJson Start  ====================================== 🔔 ',
      );
      debugPrint('$time $formatted');
      debugPrint(
        ' 🔔 ====================================== logJson End  ====================================== 🔔 ',
      );
    } catch (e) {
      debugPrint('JSON格式化失败: $e');
    }
  }
}

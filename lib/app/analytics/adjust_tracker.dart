import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:advertising_id/advertising_id.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumar_pay/app/config/api.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';
import 'package:kumar_pay/core/network/dio_client.dart';

class AdjustTracker {
  static const String revenueEventToken = 'YOUR_REVENUE_EVENT_TOKEN';

  static Future<void> fetchIdsOnLaunch() async {
    final box = GetStorage();

    if (!kIsWeb) {
      try {
        final adid = await Adjust.getAdid();
        if (adid != null && adid.isNotEmpty) {
          box.write(StorageKeys.adjustAdid, adid);
        }
      } catch (_) {}
    }

    // Web 端先不触发（不生成/不上报）
    if (kIsWeb) {
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final gpsid = await AdvertisingId.id(false);
        if (gpsid != null && gpsid.isNotEmpty) {
          box.write(StorageKeys.gpsid, gpsid);
        }
      } catch (_) {}
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        final idfa = await AdvertisingId.id(true);
        if (idfa != null && idfa.isNotEmpty) {
          box.write(StorageKeys.gpsid, idfa);
        }
      } catch (_) {}
    }

    // 上报在登录成功后触发
  }

  static void trackStandardEvent({
    required String eventToken,
    Map<String, String>? parameters,
  }) {
    final AdjustEvent event = AdjustEvent(eventToken);
    parameters?.forEach(event.addCallbackParameter);
    Adjust.trackEvent(event);
  }

  static void trackRevenue({
    required double amount,
    required String currency,
    String? orderId,
    Map<String, String>? parameters,
  }) {
    final AdjustEvent event = AdjustEvent(revenueEventToken);
    event.setRevenue(amount, currency);
    if (orderId != null && orderId.isNotEmpty) {
      event.transactionId = orderId;
    }
    parameters?.forEach(event.addCallbackParameter);
    Adjust.trackEvent(event);
  }

  static Future<void> _reportAdjustIds() async {
    final box = GetStorage();
    final adId = box.read<String>(StorageKeys.adjustAdid) ?? '';
    final gpsid = box.read<String>(StorageKeys.gpsid) ?? '';
    if (adId.isEmpty && gpsid.isEmpty) {
      return;
    }

    try {
      final dioClient = DioClient();
      await dioClient.get(
        Api.getAdjustId,
        queryParameters: {'adId': adId, 'gpsid': gpsid},
      );
    } catch (_) {}
  }

  static Future<void> reportAdjustIds() async {
    await _reportAdjustIds();
  }
}

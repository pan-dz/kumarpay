import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/network/dio_client.dart';
import 'package:kumar_pay/store/actiions/mine/sell_history_actions.dart';
import 'package:kumar_pay/store/request/mine/sell_history_api.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final sellHistoryStoreApiProvider = Provider<SellHistoryStoreApi>(
  (ref) => SellHistoryStoreApi(ref.read(dioClientProvider)),
);

final sellHistoryActionsProvider = Provider<SellHistoryActions>(
  (ref) => SellHistoryActions(ref.read(sellHistoryStoreApiProvider)),
);

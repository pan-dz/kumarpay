import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/network/dio_client.dart';
import 'package:kumar_pay/store/actiions/buy/buy_actions.dart';
import 'package:kumar_pay/store/request/buy/buy_api.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final buyStoreApiProvider = Provider<BuyStoreApi>(
  (ref) => BuyStoreApi(ref.read(dioClientProvider)),
);
final buyActionsProvider = Provider<BuyActions>(
  (ref) => BuyActions(ref.read(buyStoreApiProvider)),
);

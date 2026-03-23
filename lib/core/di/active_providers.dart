import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/network/dio_client.dart';
import 'package:kumar_pay/store/actiions/active/active_actions.dart';
import 'package:kumar_pay/store/request/active/active_api.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final activeStoreApiProvider = Provider<ActiveStoreApi>(
  (ref) => ActiveStoreApi(ref.read(dioClientProvider)),
);
final activeActionsProvider = Provider<ActiveActions>(
  (ref) => ActiveActions(ref.read(activeStoreApiProvider)),
);

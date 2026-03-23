import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/network/dio_client.dart';
import 'package:kumar_pay/store/actiions/upi/upi_actions.dart';
import 'package:kumar_pay/store/request/upi/upi_api.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final upiStoreApiProvider = Provider<UpiStoreApi>(
  (ref) => UpiStoreApi(ref.read(dioClientProvider)),
);

final upiActionsProvider = Provider<UpiActions>(
  (ref) => UpiActions(ref.read(upiStoreApiProvider)),
);

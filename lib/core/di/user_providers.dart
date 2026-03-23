import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/network/dio_client.dart';
import 'package:kumar_pay/store/actiions/login/login_actions.dart';
import 'package:kumar_pay/store/actiions/user/user_actions.dart';
import 'package:kumar_pay/store/request/login/login_api.dart';
import 'package:kumar_pay/store/request/user/user_api.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

/// 钱包地址
final trc20Address = StateProvider<String>((ref) => '');

final userStoreApiProvider = Provider<UserStoreApi>(
  (ref) => UserStoreApi(ref.read(dioClientProvider)),
);
final userActionsProvider = Provider<UserActions>(
  (ref) => UserActions(ref.read(userStoreApiProvider)),
);

final loginStoreApiProvider = Provider<LoginStoreApi>(
  (ref) => LoginStoreApi(ref.read(dioClientProvider)),
);
final loginActionsProvider = Provider<LoginActions>(
  (ref) => LoginActions(ref.read(loginStoreApiProvider)),
);

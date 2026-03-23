import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/di/user_providers.dart';
import 'package:kumar_pay/store/models/user/user_res_model.dart';

// State
class CustomerServiceState {
  final bool isLoading;
  final List<CustomerserviceModel> services;
  final String? error;

  const CustomerServiceState({
    this.isLoading = true,
    this.services = const [],
    this.error,
  });

  CustomerServiceState copyWith({
    bool? isLoading,
    List<CustomerserviceModel>? services,
    String? error,
  }) {
    return CustomerServiceState(
      isLoading: isLoading ?? this.isLoading,
      services: services ?? this.services,
      error: error,
    );
  }
}

// ViewModel
class CustomerServiceViewModel extends StateNotifier<CustomerServiceState> {
  final Ref ref;
  CustomerServiceViewModel(this.ref) : super(const CustomerServiceState());

  /// 刷新数据
  Future<void> refresh() async {
    await fetchCustomerServices();
  }

  /// 重试加载
  Future<void> retry() async {
    await fetchCustomerServices();
  }

  Future<void> fetchCustomerServices() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final userActions = ref.read(userActionsProvider);
      final response = await userActions.customerserviceApi();
      if (response.success) {
        state = state.copyWith(isLoading: false, services: response.data);
      } else {
        state = state.copyWith(isLoading: false, error: response.msg);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Provider
final customerServiceProvider =
    StateNotifierProvider.autoDispose<
      CustomerServiceViewModel,
      CustomerServiceState
    >((ref) {
      return CustomerServiceViewModel(ref);
    });

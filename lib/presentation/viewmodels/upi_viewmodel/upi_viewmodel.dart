import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/app/config/base_config.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'package:kumar_pay/core/utils/enum.dart';
import 'package:kumar_pay/core/di/upi_providers.dart';
import 'package:kumar_pay/presentation/pages/upi_page/add_upi_page.dart';
import 'package:kumar_pay/presentation/viewmodels/upi_viewmodel/add_upi_viewmodel.dart';
import 'package:kumar_pay/store/models/upi/upi_res_model.dart';
import 'package:kumar_pay/store/models/upi/upi_req_model.dart';
import 'package:url_launcher/url_launcher.dart';

class UpiStatus {
  final String label;
  final Color color;
  const UpiStatus(this.label, this.color);
}

class UpiAccount {
  final UpiProviderType provider;
  final String id;
  final String maskedNumber;
  final String upiId;
  final String pnname;
  final bool inSell;
  final Color brandColor;
  final String iconAsset;
  final List<UpiStatus> statuses;

  const UpiAccount({
    required this.provider,
    required this.id,
    required this.maskedNumber,
    required this.upiId,
    required this.pnname,
    required this.inSell,
    required this.brandColor,
    required this.iconAsset,
    required this.statuses,
  });
}

class UpiState {
  final bool isLoading;
  final String? error;
  final List<UpiAccount> accounts;

  const UpiState({
    this.isLoading = false,
    this.error,
    this.accounts = const [],
  });

  UpiState copyWith({
    bool? isLoading,
    String? error,
    List<UpiAccount>? accounts,
  }) {
    return UpiState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      accounts: accounts ?? this.accounts,
    );
  }
}

class UpiViewModel extends StateNotifier<UpiState> {
  final Ref ref;
  UpiViewModel(this.ref) : super(const UpiState());

  Future<void> getUpiList() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final actions = ref.read(upiActionsProvider);
      final response = await actions.getUpiListApi();

      if (!response.success) {
        state = state.copyWith(
          isLoading: false,
          error: response.msg ?? 'Request fail: getUpiListApi',
          accounts: const [],
        );
        return;
      }

      final accounts = (response.data ?? const <UpiInfoModel>[])
          .map(_mapUpiInfoToAccount)
          .toList();
      state = state.copyWith(isLoading: false, error: null, accounts: accounts);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  UpiAccount _mapUpiInfoToAccount(UpiInfoModel info) {
    final provider = UpiProviderType.fromCtType(info.ctType);
    final brandColor = provider.brandColor;

    final inSell = info.inSell == 1;
    final statuses = <UpiStatus>[
      _mapStatus(info.state),
      UpiStatus(
        inSell ? 'In Sell' : 'Stop Sell',
        inSell ? const Color(0xFF2ECC71) : const Color(0xFFF1C40F),
      ),
    ];

    return UpiAccount(
      provider: provider,
      id: info.id.toString(),
      maskedNumber: info.account,
      upiId: info.upi,
      pnname: info.pnname,
      inSell: inSell,
      brandColor: brandColor,
      iconAsset: provider.iconAsset,
      statuses: statuses,
    );
  }

  UpiStatus _mapStatus(int status) {
    switch (status) {
      case 0:
        return const UpiStatus('Disabled', Color(0xFFE74C3C));
      case 1:
        return const UpiStatus('Active', Color(0xFF2ECC71));
      case 2:
        return const UpiStatus('Idle', Color(0xFF2ECC71));
      case 3:
        return const UpiStatus('Not Online', Color(0xFF3498DB));
      case 4:
        return const UpiStatus('Timeout', Color(0xFFE74C3C));
      case 5:
        return const UpiStatus('Login Error', Color(0xFFE74C3C));
      case 6:
        return const UpiStatus('Waiting Online', Color(0xFFF1C40F));
      case 7:
        return const UpiStatus('Waiting Authupi', Color(0xFF3498DB));
      default:
        return const UpiStatus('Unknown', Color(0xFF8F9098));
    }
  }

  Future<void> handleClickVideo() async {
    final uri = Uri.parse(KumarBaseConfig.addUpiVideo);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> updateUpiStatus(
    BuildContext context, {
    required String id,
    required int status,
  }) async {
    if (id.trim().isEmpty) return;
    try {
      state = state.copyWith(isLoading: true, error: null);
      final actions = ref.read(upiActionsProvider);

      // 跳转addUpi页面
      if (context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddUpiPage()));
        });
      }

      // 修改状态请求
      await actions.updateUpiStatusApi(
        IUpdateUpiStatusReqModel(id: id, status: status),
      );

      try {
        // upi详情请求
        final detailRes = await actions.getUpiDetailsApi(
          IGetUpiDetailsReqModel(id: id),
        );
        final info = detailRes.data;
        if (detailRes.success && info != null) {
          ref.read(addUpiViewModelProvider.notifier).prefillFromUpiInfo(info);
        }
      } catch (_) {}

      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
      AppToast.show(
        context,
        message: 'Relink request failed, please try again later',
        type: AppToastType.error,
      );
    }
  }

  Future<bool> stopSell(BuildContext context, {required String ctId}) async {
    if (ctId.trim().isEmpty) return false;
    try {
      state = state.copyWith(isLoading: true, error: null);
      final actions = ref.read(upiActionsProvider);
      final res = await actions.stopSellApi(IStopSellReqModel(ctId: ctId));
      if (!res.success) {
        state = state.copyWith(isLoading: false);
        if (context.mounted) {
          AppToast.show(
            context,
            message: res.msg ?? 'Request fail: stopSell',
            type: AppToastType.error,
          );
        }
        return false;
      }

      if (context.mounted) {
        AppToast.show(
          context,
          message: res.msg ?? 'Stop sell success',
          type: AppToastType.success,
        );
      }
      try {
        await actions.getUpiDetailsApi(IGetUpiDetailsReqModel(id: ctId));
      } catch (_) {}
      await getUpiList();
      return true;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        AppToast.show(
          context,
          message: 'Stop sell failed, please try again later',
          type: AppToastType.error,
        );
      }
      return false;
    }
  }

  Future<bool> startSell(BuildContext context, {required String ctId}) async {
    if (ctId.trim().isEmpty) return false;
    try {
      state = state.copyWith(isLoading: true, error: null);
      final actions = ref.read(upiActionsProvider);
      final res = await actions.startSellApi(IStartSellReqModel(ctId: ctId));
      if (!res.success) {
        state = state.copyWith(isLoading: false);
        if (context.mounted) {
          AppToast.show(
            context,
            message: res.msg ?? 'Request fail: startSell',
            type: AppToastType.error,
          );
        }
        return false;
      }

      if (context.mounted) {
        AppToast.show(
          context,
          message: res.msg ?? 'Start sell success',
          type: AppToastType.success,
        );
      }
      try {
        await actions.getUpiDetailsApi(IGetUpiDetailsReqModel(id: ctId));
      } catch (_) {}
      await getUpiList();
      return true;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        AppToast.show(
          context,
          message: 'Start sell failed, please try again later',
          type: AppToastType.error,
        );
      }
      return false;
    }
  }

  Future<void> operate(UpiAccount account) async {}

  Future<void> details(UpiAccount account) async {}
}

final upiViewModelProvider = StateNotifierProvider<UpiViewModel, UpiState>((
  ref,
) {
  final vm = UpiViewModel(ref);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    vm.getUpiList();
  });
  return vm;
});

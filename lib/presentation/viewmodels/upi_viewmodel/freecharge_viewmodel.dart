import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'package:kumar_pay/core/di/buy_providers.dart';
import 'package:kumar_pay/presentation/pages/mine_page/buy_history_page.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:kumar_pay/presentation/widgets/popup_dialog.dart';
import 'package:kumar_pay/store/models/buy/buy_req_model.dart';
import 'package:kumar_pay/store/models/buy/buy_res_model.dart';
import 'package:url_launcher/url_launcher.dart';

class FreechargeArgs {
  final String id;
  final int ctime;
  final String upiName;
  final int ctType;
  final String walletAddress;

  const FreechargeArgs({
    required this.id,
    required this.ctime,
    required this.upiName,
    required this.ctType,
    required this.walletAddress,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FreechargeArgs &&
        other.id == id &&
        other.ctime == ctime &&
        other.upiName == upiName &&
        other.ctType == ctType &&
        other.walletAddress == walletAddress;
  }

  @override
  int get hashCode => Object.hash(id, ctime, upiName, ctType, walletAddress);
}

class FreechargeInfoItem {
  final String label;
  final String value;
  const FreechargeInfoItem({required this.label, required this.value});
}

class FreechargeState {
  final int remainingSeconds;
  final int currentStep;
  final String walletAddress;
  final String upiName;
  final int ctType;
  final List<FreechargeInfoItem> infoItems;
  final bool isLoading;
  final String? error;

  const FreechargeState({
    this.remainingSeconds = 1800,
    this.currentStep = 0,
    this.walletAddress = '',
    this.upiName = '',
    this.ctType = 0,
    this.infoItems = const [
      FreechargeInfoItem(label: 'Name', value: ''),
      FreechargeInfoItem(label: 'Account', value: ''),
      FreechargeInfoItem(label: 'IFSC', value: ''),
      FreechargeInfoItem(label: 'Bank', value: ''),
      FreechargeInfoItem(label: 'Amount', value: ''),
    ],
    this.isLoading = false,
    this.error,
  });

  FreechargeState copyWith({
    int? remainingSeconds,
    int? currentStep,
    String? walletAddress,
    String? upiName,
    int? ctType,
    List<FreechargeInfoItem>? infoItems,
    bool? isLoading,
    String? error,
  }) {
    return FreechargeState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentStep: currentStep ?? this.currentStep,
      walletAddress: walletAddress ?? this.walletAddress,
      upiName: upiName ?? this.upiName,
      ctType: ctType ?? this.ctType,
      infoItems: infoItems ?? this.infoItems,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  String get remainingText {
    final safeSeconds = remainingSeconds <= 0 ? 0 : remainingSeconds;
    final m = (safeSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (safeSeconds % 60).toString().padLeft(2, '0');
    return '00:$m:$s';
  }
}

class FreechargeViewModel extends StateNotifier<FreechargeState> {
  final Ref ref;
  final FreechargeArgs args;
  Timer? _timer;
  bool _fetched = false;
  bool _hasShownCopyNotice = false;

  FreechargeViewModel(this.ref, this.args) : super(const FreechargeState()) {
    if (args.walletAddress.isNotEmpty || args.upiName.isNotEmpty) {
      state = state.copyWith(
        walletAddress: args.walletAddress,
        upiName: args.upiName,
        ctType: args.ctType,
      );
    }
    _startCountdown();
    Future.microtask(fetchPaymentSlipDetail);
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds <= 0) {
        timer.cancel();
        return;
      }
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    });
  }

  void onTapHistory(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BuyHistoryPage()));
  }

  Future<void> onGoPay(BuildContext context) async {
    // AppToast.show(
    //   context,
    //   message:
    //       'Please copy the info, open the FreeCharge app, and complete the payment.',
    //   type: AppToastType.warning,
    // );

    final Uri appUri = Uri.parse('freecharge://');

    // Android Play Store
    final Uri androidStore = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.freecharge.android',
    );

    // // iOS App Store
    // final Uri iosStore = Uri.parse(
    //   'https://apps.apple.com/in/app/freecharge/id692495696',
    // );

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } else {
      // 未安装时跳转商店
      if (Platform.isAndroid) {
        await launchUrl(androidStore, mode: LaunchMode.externalApplication);
      }
      // else if (Platform.isIOS) {
      //   await launchUrl(iosStore, mode: LaunchMode.externalApplication);
      // }
    }
  }

  void onFinishPayment() {
    state = state.copyWith(currentStep: 1);
  }

  void onPrevious() {
    state = state.copyWith(currentStep: 0);
  }

  void resetCurrentStep() {
    state = state.copyWith(currentStep: 0);
  }

  void onConfirm(BuildContext context) {
    PopupDialog.show(
      context: context,
      config: PopupDialogConfig(
        position: DialogPosition.center,
        title: 'Confirm payment',
        showCloseButton: false,
        showFooterButtons: true,
        showDoubleButtons: true,
        primaryButtonText: 'Got it',
        secondaryButtonText: 'Continue to pay',
        buttonType: HxButtonType.medium,
        minHeight: 220,
      ),
      child: Text(
        'Please confirm that you have completed the payment with the\n ${state.walletAddress}\naccount. If you do not complete the\npayment, your credit will be affected and\nyour transactions will be limited!',
        style: const TextStyle(
          color: Color(0xFF8F9098),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
      onConfirm: () {
        processpaymentslipsApi(context);
      },
      onCancel: () {
        state = state.copyWith(currentStep: 1);
      },
    );
  }

  Future<void> processpaymentslipsApi(BuildContext context) async {
    if (state.isLoading) return;
    if (args.id.trim().isEmpty) return;
    try {
      state = state.copyWith(isLoading: true, error: null);
      final actions = ref.read(buyActionsProvider);
      final res = await actions.processpaymentslipsApi(
        orderId: args.id,
        process: 'finish',
      );
      if (!res.success) {
        state = state.copyWith(
          isLoading: false,
          error: res.msg ?? 'Request failed: processpaymentslipsApi',
        );
        AppToast.show(
          context,
          message: res.msg ?? 'Request failed: processpaymentslipsApi',
          type: AppToastType.error,
        );
        return;
      }
      state = state.copyWith(currentStep: 2);
      state = state.copyWith(isLoading: false);
      AppToast.show(
        context,
        message: 'Payment confirmed',
        type: AppToastType.success,
      );
    } catch (_) {
      AppToast.show(
        context,
        message: 'Payment confirmation failed, please try again later',
        type: AppToastType.error,
      );
    } finally {
      if (state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  void onHelp() {}

  void onCancelOrder(BuildContext context) {
    _showCancelReasonDialog(context);
  }

  void onCopy(FreechargeInfoItem item, BuildContext context) {
    if (!context.mounted) {
      return;
    }
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    if (!rootNavigator.mounted) {
      return;
    }
    final rootContext = rootNavigator.context;
    if (_hasShownCopyNotice) {
      Clipboard.setData(ClipboardData(text: item.value));
      AppToast.success(rootContext, '${item.label} Copied');
      return;
    }

    PopupDialog.show(
      context: rootContext,
      config: PopupDialogConfig(
        position: DialogPosition.center,
        title: 'Notice',
        showCloseButton: false,
        showFooterButtons: true,
        showDoubleButtons: true,
        primaryButtonText: 'OK',
        minHeight: 220,
      ),
      onConfirm: () {
        if (!rootNavigator.mounted) {
          return;
        }
        _hasShownCopyNotice = true;
      },
      child: const Text(
        'After the payment is completed, please upload a picture of the payment proof. Not upload proof will loss! Please click OK and copy again',
        style: TextStyle(
          color: Color(0xFF8F9098),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
    );
  }

  Future<void> fetchPaymentSlipDetail() async {
    if (_fetched) return;
    _fetched = true;
    if (args.id.isEmpty || args.ctime <= 0) return;
    try {
      state = state.copyWith(isLoading: true, error: null);
      final actions = ref.read(buyActionsProvider);
      final res = await actions.paymentslipDetailApi(
        IPaymentSlipDetailReqModel(id: args.id, ctime: args.ctime),
      );
      if (!res.success || res.data == null) {
        state = state.copyWith(
          isLoading: false,
          error: res.msg ?? 'Request fail: paymentslipDetailApi',
        );
        return;
      }
      _applyDetail(res.data!);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _applyDetail(PaymentSlipDetailData data) {
    final items = <FreechargeInfoItem>[
      FreechargeInfoItem(label: 'Name', value: data.payeeRecipientsName),
      FreechargeInfoItem(label: 'Account', value: data.payeeBankAccount),
      FreechargeInfoItem(label: 'IFSC', value: data.payeeIfsc),
      FreechargeInfoItem(label: 'Bank', value: data.payeeBankname),
      FreechargeInfoItem(label: 'Amount', value: data.amount.toString()),
    ];

    state = state.copyWith(
      isLoading: false,
      walletAddress: data.ctAccountUpi,
      remainingSeconds: data.countdown,
      infoItems: items,
    );
  }

  Future<void> _showCancelReasonDialog(BuildContext context) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final reasons = [
      'Incorrect bank account information',
      "Don't want to buy",
      'Payment Fail',
      'Other',
    ];
    String? selectedReason;
    String otherReason = '';
    final controller = TextEditingController();

    await PopupDialog.show(
      context: rootContext,
      config: PopupDialogConfig(
        position: DialogPosition.center,
        title: 'why cancel',
        showCloseButton: true,
        showFooterButtons: true,
        showDoubleButtons: false,
        primaryButtonText: 'Confirm',
        minHeight: 520,
      ),
      onConfirm: () async {
        final reason = selectedReason == 'Other'
            ? otherReason.trim()
            : (selectedReason ?? '');
        if (reason.isEmpty) {
          AppToast.show(
            context,
            message: 'Please select a reason',
            type: AppToastType.warning,
          );
          return;
        }
        final rootNavigator = Navigator.of(context, rootNavigator: true);
        if (!rootNavigator.mounted) {
          return;
        }
        try {
          state = state.copyWith(isLoading: true, error: null);
          final actions = ref.read(buyActionsProvider);
          final res = await actions.processpaymentslipsApi(
            orderId: args.id,
            process: 'Cancel',
            cancelRemark: reason,
          );
          if (!res.success) {
            state = state.copyWith(
              isLoading: false,
              error: res.msg ?? 'Request failed: processpaymentslipsApi',
            );
            AppToast.show(
              context,
              message: res.msg ?? 'Request failed: processpaymentslipsApi',
              type: AppToastType.error,
            );
            return;
          }

          // AppToast.show(
          //   context,
          //   message: 'Cancel success',
          //   type: AppToastType.success,
          // );
          if (rootNavigator.canPop()) {
            rootNavigator.pop();
          }
        } catch (_) {
          AppToast.show(
            context,
            message: 'Cancel failed, please try again later',
            type: AppToastType.error,
          );
        } finally {
          if (state.isLoading) {
            state = state.copyWith(isLoading: false);
          }
        }
      },
      child: StatefulBuilder(
        builder: (context, setState) {
          final maxHeight = MediaQuery.of(context).size.height * 0.6;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Warning: if you try to cancel and money is debited from your bank, we can\'t give it back.',
                    style: const TextStyle(
                      color: Color(0xFFFF2E2E),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order No',
                        style: const TextStyle(
                          color: Color(0xFF71727A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        args.id,
                        style: const TextStyle(
                          color: Color(0xFF1F2024),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  ...reasons.map(
                    (r) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Material(
                        color: selectedReason == r
                            ? const Color(0xFFEFF4FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            setState(() {
                              selectedReason = r;
                            });
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: selectedReason == r
                                    ? const Color(0xFF2F7CF0)
                                    : const Color(0xFFD3D5DD),
                                width: 0.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selectedReason == r
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: selectedReason == r
                                      ? const Color(0xFF2F7CF0)
                                      : const Color(0xFF8F9098),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    r,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: selectedReason == r
                                          ? const Color(0xFF2F7CF0)
                                          : const Color(0xFF1F2024),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (selectedReason == 'Other')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: controller,
                        maxLength: 100,
                        minLines: 4,
                        maxLines: 8,
                        onChanged: (v) => otherReason = v,
                        decoration: const InputDecoration(
                          hintText: 'Please enter a reason',
                          counterText: '',
                          filled: true,
                          fillColor: Color(0xFFF5F6FA),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                              color: Color(0xFFD3D5DD),
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                              color: Color(0xFFD3D5DD),
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                              color: Color(0xFF2F7CF0),
                              width: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );

    controller.dispose();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final freechargeViewModelFamilyProvider = StateNotifierProvider.autoDispose
    .family<FreechargeViewModel, FreechargeState, FreechargeArgs>((ref, args) {
      return FreechargeViewModel(ref, args);
    });

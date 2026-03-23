import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/core/di/upi_providers.dart';
import 'package:kumar_pay/core/utils/enum.dart';
import 'package:kumar_pay/store/models/upi/upi_req_model.dart';
import 'package:kumar_pay/store/models/upi/upi_res_model.dart';

class UpiOrderRecord {
  final String orderNo;
  final String stateText; // success / pay failed
  final Color stateColor; // 绿/黄
  final String dealDate;
  const UpiOrderRecord({
    required this.orderNo,
    required this.stateText,
    required this.stateColor,
    required this.dealDate,
  });
}

class UpiDetailsState {
  final UpiProviderType provider;
  final String upiId;
  final String allocationQuota;
  final bool ordersExpanded;
  final List<UpiOrderRecord> orders;

  final bool isLoading;
  final String? error;

  final bool inSellOk; // false => 红叉
  final bool lockTimeOk; // true => 绿勾
  final bool onlineOk;
  final String? onlineWarning; // 非空时在同一行展示红色提示

  const UpiDetailsState({
    this.provider = UpiProviderType.unknown,
    this.upiId = '',
    this.allocationQuota = '',
    this.ordersExpanded = false,
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.inSellOk = false,
    this.lockTimeOk = true,
    this.onlineOk = true,
    this.onlineWarning,
  });

  UpiDetailsState copyWith({
    UpiProviderType? provider,
    String? upiId,
    String? allocationQuota,
    bool? ordersExpanded,
    List<UpiOrderRecord>? orders,
    bool? isLoading,
    String? error,
    bool? inSellOk,
    bool? lockTimeOk,
    bool? onlineOk,
    String? onlineWarning, // 传 null 显示为空，传空字符串也按有值显示
  }) {
    return UpiDetailsState(
      provider: provider ?? this.provider,
      upiId: upiId ?? this.upiId,
      allocationQuota: allocationQuota ?? this.allocationQuota,
      ordersExpanded: ordersExpanded ?? this.ordersExpanded,
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      inSellOk: inSellOk ?? this.inSellOk,
      lockTimeOk: lockTimeOk ?? this.lockTimeOk,
      onlineOk: onlineOk ?? this.onlineOk,
      onlineWarning: onlineWarning == null
          ? this.onlineWarning
          : onlineWarning.isEmpty
          ? ''
          : onlineWarning,
    );
  }
}

class UpiDetailsViewModel extends StateNotifier<UpiDetailsState> {
  final Ref ref;
  final String upiName;

  UpiDetailsViewModel(this.ref, this.upiName) : super(const UpiDetailsState()) {
    // _loadMock();
    Future.microtask(refresh);
  }

  void _loadMock() {
    const mockCtType = 2;
    const mockUpi = '8942838381@ikwik';
    const mockInSell = 1;
    const mockLockedTime = 0;
    const mockReceiving = 0;

    final provider = UpiProviderType.fromCtType(mockCtType);
    final mockOrders = <({String rptNo, int orderState, int uptDate})>[
      (rptNo: '4215142569476101', orderState: 3, uptDate: 1764317971),
      (rptNo: '4215114020159493', orderState: 3, uptDate: 1764317535),
      (rptNo: '4215112568995845', orderState: 3, uptDate: 1764317513),
      (rptNo: '4215109456363525', orderState: 3, uptDate: 1764317466),
      (rptNo: '4215106060812293', orderState: 5, uptDate: 1764317414),
      (rptNo: '4214441139699717', orderState: 5, uptDate: 1764307268),
      (rptNo: '4214432098746373', orderState: 5, uptDate: 1764307130),
      (rptNo: '4214393625182213', orderState: 5, uptDate: 1764306543),
      (rptNo: '4214392357060613', orderState: 3, uptDate: 1764306524),
      (rptNo: '4214299814854661', orderState: 3, uptDate: 1764305111),
    ];

    final orders = mockOrders
        .map(
          (o) => _mapOrder(
            UpiOrderModel(
              rptNo: o.rptNo,
              orderState: o.orderState,
              uptDate: o.uptDate,
            ),
          ),
        )
        .toList();

    state = state.copyWith(
      isLoading: false,
      error: null,
      provider: provider,
      upiId: mockUpi,
      allocationQuota: '1000000',
      orders: orders,
      ordersExpanded: false,
      inSellOk: mockInSell == 1,
      lockTimeOk: mockLockedTime == 0,
      onlineOk: mockReceiving == 1,
      onlineWarning: mockReceiving == 1
          ? ''
          : 'Please make a payment to this UPI of more\nthan 168 to activate the account online.',
    );
  }

  Future<void> refresh() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final actions = ref.read(upiActionsProvider);
      final response = await actions.getUpiDetailApi(
        IGetUpiDetailReqModel(name: upiName),
      );

      if (!response.success) {
        state = state.copyWith(
          isLoading: false,
          error: response.msg ?? 'Request fail: getUpiDetailApi',
        );
        return;
      }

      final vo = response.data?.vo;
      final provider = vo == null
          ? UpiProviderType.unknown
          : UpiProviderType.fromCtType(vo.ctType);

      final orders = (response.data?.orders ?? const <UpiOrderModel>[])
          .take(10)
          .map(_mapOrder)
          .toList();

      state = state.copyWith(
        isLoading: false,
        error: null,
        provider: provider,
        upiId: vo?.upi ?? upiName,
        allocationQuota: vo?.allocationQuota.toString() ?? '',
        orders: orders,
        inSellOk: (vo?.inSell ?? 0) == 1,
        lockTimeOk: (vo?.lockedTime ?? 0) == 0,
        onlineOk: (vo?.status ?? 0) == 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  UpiOrderRecord _mapOrder(UpiOrderModel order) {
    final (String text, Color color) = switch (order.orderState) {
      3 => ('success', Colors.green),
      5 => ('pay failed', Colors.orange),
      _ => ('state:${order.orderState}', Colors.orange),
    };

    // 后端是秒级时间戳
    final dt = DateTime.fromMillisecondsSinceEpoch(order.uptDate * 1000);
    String two(int n) => n.toString().padLeft(2, '0');
    final dealDate =
        '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';

    return UpiOrderRecord(
      orderNo: order.rptNo,
      stateText: text,
      stateColor: color,
      dealDate: dealDate,
    );
  }

  void toggleOrdersExpanded(bool expanded) {
    state = state.copyWith(ordersExpanded: expanded);
  }

  void setStatuses({bool? inSellOk, bool? lockTimeOk, bool? onlineOk}) {
    state = state.copyWith(
      inSellOk: inSellOk,
      lockTimeOk: lockTimeOk,
      onlineOk: onlineOk,
    );
  }

  void setOnlineWarning(String? msg) {
    state = state.copyWith(onlineWarning: msg ?? '');
  }
}

final upiDetailsViewModelProvider = StateNotifierProvider.autoDispose
    .family<UpiDetailsViewModel, UpiDetailsState, String>((ref, upiName) {
      return UpiDetailsViewModel(ref, upiName);
    });

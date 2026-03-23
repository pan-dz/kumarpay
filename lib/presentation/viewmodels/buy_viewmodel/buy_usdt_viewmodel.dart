import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';
import 'package:kumar_pay/core/di/buy_providers.dart';
import 'package:kumar_pay/store/models/buy/buy_res_model.dart';
import 'package:kumar_pay/store/models/buy/usdt_res_model.dart';

class BuyRecord {
  final String amount; // e.g. "2USDT"
  final String receive; // e.g. "96"
  final String dateTime; // e.g. "2025-12-15 09:27:46"
  final int blockTimestamp; // 排序依据（毫秒时间戳）

  const BuyRecord({
    required this.amount,
    required this.receive,
    required this.dateTime,
    required this.blockTimestamp,
  });
}

class BuyUsdtState {
  final String address;
  final String network;
  final String approxSymbol;
  final double ratio;
  final String input;
  final String approxDisplay;
  final bool showHistory;
  final List<BuyRecord> records;

  const BuyUsdtState({
    this.address = '',
    this.network = 'Tron(TRC20)',
    this.approxSymbol = 'IToken',
    this.ratio = 0,
    this.input = '',
    this.approxDisplay = '0',
    this.showHistory = true,
    this.records = const [],
  });

  BuyUsdtState copyWith({
    String? address,
    String? network,
    String? approxSymbol,
    double? ratio,
    String? input,
    String? approxDisplay,
    bool? showHistory,
    List<BuyRecord>? records,
  }) {
    return BuyUsdtState(
      address: address ?? this.address,
      network: network ?? this.network,
      approxSymbol: approxSymbol ?? this.approxSymbol,
      ratio: ratio ?? this.ratio,
      input: input ?? this.input,
      approxDisplay: approxDisplay ?? this.approxDisplay,
      showHistory: showHistory ?? this.showHistory,
      records: records ?? this.records,
    );
  }
}

class BuyUsdtViewModel extends StateNotifier<BuyUsdtState> {
  final Ref ref;
  BuyUsdtViewModel(this.ref) : super(const BuyUsdtState()) {
    _loadAddressFromStorage();
    _recalc();
    _fetchUsdtRecords();
  }

  void _loadAddressFromStorage() {
    try {
      final raw = GetStorage().read(StorageKeys.userInfo);
      if (raw is Map) {
        final map = raw.cast<String, dynamic>();
        final trc20 = map['trc20Address'];
        if (trc20 != null && trc20.toString().isNotEmpty) {
          state = state.copyWith(address: trc20.toString());
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchUsdtRecords() async {
    final address = state.address.trim();
    if (address.isEmpty) {
      state = state.copyWith(records: const []);
      return;
    }

    try {
      final actions = ref.read(buyActionsProvider);
      await actions.getUsdtListApi(address: address);
      await actions.buyUsdtNotifyApi();
      final response = await actions.getBuyUsdtListApi();
      final items = response.data ?? const <BuyUsdtListItem>[];
      final records = items.map((item) => _mapBuyUsdtItem(item)).toList();
      records.sort((a, b) => b.blockTimestamp.compareTo(a.blockTimestamp));
      final latestTwo = records.take(2).toList(growable: false);
      state = state.copyWith(records: latestTwo);
    } catch (_) {}
  }

  BuyRecord _mapBuyUsdtItem(BuyUsdtListItem item) {
    final amountValue = item.amount.toDouble();
    final amountText =
        '${_stripTrailingZeros(amountValue.toStringAsFixed(6))}USDT';
    final receiveValue = item.itoken.toDouble();
    final receiveText = _stripTrailingZeros(receiveValue.toStringAsFixed(2));
    final tsMillis = _normalizeTimestamp(item.crtDate);
    final dateText = _formatDateTime(tsMillis);
    return BuyRecord(
      amount: amountText,
      receive: receiveText,
      dateTime: dateText,
      blockTimestamp: tsMillis,
    );
  }

  BuyRecord _mapTxToRecord(UsdtTransaction tx) {
    final amountValue = _calcUsdtAmount(tx);
    final amountText =
        '${_stripTrailingZeros(amountValue.toStringAsFixed(6))}USDT';
    final receiveValue = amountValue * _readRate();
    final receiveText = _stripTrailingZeros(receiveValue.toStringAsFixed(2));
    final dateText = _formatDateTime(tx.blockTimestamp);
    return BuyRecord(
      amount: amountText,
      receive: receiveText,
      dateTime: dateText,
      blockTimestamp: tx.blockTimestamp,
    );
  }

  double _calcUsdtAmount(UsdtTransaction tx) {
    final raw = double.tryParse(tx.value) ?? 0.0;
    final decimals = tx.tokenInfo?.decimals ?? 6;
    final divisor = _pow10(decimals);
    if (divisor == 0) return 0.0;
    return raw / divisor;
  }

  double _pow10(int n) {
    if (n <= 0) return 1.0;
    double v = 1.0;
    for (var i = 0; i < n; i++) {
      v *= 10.0;
    }
    return v;
  }

  String _formatDateTime(int millis) {
    if (millis <= 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm:$ss';
  }

  int _normalizeTimestamp(int value) {
    if (value <= 0) return 0;
    // 10位秒级时间戳转为毫秒
    if (value < 1000000000000) return value * 1000;
    return value;
  }

  void configure({
    String? address,
    String? network,
    String? approxSymbol,
    double? ratio,
  }) {
    state = state.copyWith(
      address: address,
      network: network,
      approxSymbol: approxSymbol,
      ratio: ratio,
    );
    _recalc();
  }

  void setInput(String value) {
    state = state.copyWith(input: value);
    _recalc();
  }

  void toggleHistory() {
    state = state.copyWith(showHistory: !state.showHistory);
  }

  Future<void> refreshUsdtRecords() async {
    _loadAddressFromStorage();
    await _fetchUsdtRecords();
  }

  void _recalc() {
    final v = double.tryParse(state.input) ?? 0.0;
    final rate = _readRate();
    final approx = v * rate;
    final fixed = approx.toStringAsFixed(2);
    state = state.copyWith(
      ratio: rate,
      approxDisplay: _stripTrailingZeros(fixed),
    );
  }

  double _readRate() {
    final raw = GetStorage().read(StorageKeys.usdtExchangerate);
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0.0;
    return 0.0;
  }

  String _stripTrailingZeros(String s) {
    if (!s.contains('.')) return s;
    s = s.replaceFirst(RegExp(r"0+$"), '');
    if (s.endsWith('.')) return s.substring(0, s.length - 1);
    return s;
  }
}

final buyUsdtViewModelProvider =
    StateNotifierProvider<BuyUsdtViewModel, BuyUsdtState>((ref) {
      return BuyUsdtViewModel(ref);
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// USDT 汇率提供者
final usdtExchangerateProvider = StateProvider<String>((ref) => '');

/// 货币单位提供者
final currencyProvider = StateProvider<String>((ref) => '');

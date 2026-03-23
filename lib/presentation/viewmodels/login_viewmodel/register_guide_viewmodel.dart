import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/app/logger/app_logger.dart';
import 'package:kumar_pay/core/di/user_providers.dart';
import 'package:kumar_pay/store/models/login/login_res_model.dart';

class RegisterGuideContact {
  final String title;
  final String number;
  final String url;

  const RegisterGuideContact({
    required this.title,
    required this.number,
    required this.url,
  });
}

class RegisterGuideState {
  final bool isLoading;
  final String? error;
  final int accountPoolTotal;
  final List<AccountPoolItem> accountPoolList;
  final RegisterGuideContact whatsapp;
  final RegisterGuideContact telegram;

  const RegisterGuideState({
    this.isLoading = true,
    this.error,
    this.accountPoolTotal = 0,
    this.accountPoolList = const [],
    this.whatsapp = const RegisterGuideContact(
      title: 'Our WhatsApp Number',
      number: '',
      url: '',
    ),
    this.telegram = const RegisterGuideContact(
      title: 'Our Telegram Number',
      number: '',
      url: '',
    ),
  });

  RegisterGuideState copyWith({
    bool? isLoading,
    String? error,
    int? accountPoolTotal,
    List<AccountPoolItem>? accountPoolList,
    RegisterGuideContact? whatsapp,
    RegisterGuideContact? telegram,
  }) {
    return RegisterGuideState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      accountPoolTotal: accountPoolTotal ?? this.accountPoolTotal,
      accountPoolList: accountPoolList ?? this.accountPoolList,
      whatsapp: whatsapp ?? this.whatsapp,
      telegram: telegram ?? this.telegram,
    );
  }
}

class RegisterGuideViewModel extends StateNotifier<RegisterGuideState> {
  RegisterGuideViewModel(this.ref) : super(const RegisterGuideState());

  final Ref ref;
  final Random _random = Random();

  Future<void> refresh() async {
    debugPrint('registerGuide: refresh');
    await fetchAccountPoolList();
  }

  Future<void> retry() async {
    await fetchAccountPoolList();
  }

  Future<bool> copyContactText(String value) async {
    final text = value.trim();
    if (text.isEmpty) return false;

    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchAccountPoolList() async {
    try {
      state = state.copyWith(
        accountPoolTotal: 0,
        accountPoolList: const [],
        whatsapp: _defaultContact('whatsapp'),
        telegram: _defaultContact('telegram'),
      );
      final loginActions = ref.read(loginActionsProvider);
      final response = await loginActions.getAccountPoolListApi();

      final list = response.data!.list;
      _logAccountPoolList(list);
      final whatsapp = _pickAccountContact(list, 1, 'whatsapp');
      final telegram = _pickAccountContact(list, 2, 'telegram');
      whatsapp.logJson();

      state = state.copyWith(
        accountPoolTotal: response.data!.total,
        accountPoolList: list,
        whatsapp: whatsapp,
        telegram: telegram,
        isLoading: false,
        error: state.error,
      );
    } catch (_) {}
  }

  void _logAccountPoolList(List<AccountPoolItem> list) {
    final payload = list
        .map(
          (item) => {
            'id': item.id,
            'name': item.name,
            'account': item.account,
            'type': item.type,
          },
        )
        .toList();
    payload.logJson();
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String _buildWhatsAppUrl(String number) {
    final digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    return 'https://wa.me/$digits?text=Hi%20KumarPay';
  }

  RegisterGuideContact _defaultContact(String keyword) {
    return RegisterGuideContact(
      title: 'Our ${_capitalize(keyword)} Number',
      number: '',
      url: '',
    );
  }

  RegisterGuideContact _pickAccountContact(
    List<AccountPoolItem> list,
    int type,
    String keyword,
  ) {
    final matches = list.where((item) => item.type == type).toList();
    if (matches.isEmpty) {
      if (list.isEmpty) {
        return _defaultContact(keyword);
      }
      final fallback = list[_random.nextInt(list.length)];
      return RegisterGuideContact(
        title: 'Our ${_capitalize(keyword)} Number',
        number: fallback.account,
        url: keyword.toLowerCase() == 'whatsapp'
            ? _buildWhatsAppUrl(fallback.account)
            : '',
      );
    }

    final selected = matches[_random.nextInt(matches.length)];
    return RegisterGuideContact(
      title: selected.name.isEmpty
          ? 'Our ${_capitalize(keyword)} Number'
          : selected.name,
      number: selected.account,
      url: keyword.toLowerCase() == 'whatsapp'
          ? _buildWhatsAppUrl(selected.account)
          : '',
    );
  }
}

final registerGuideProvider =
    StateNotifierProvider.autoDispose<
      RegisterGuideViewModel,
      RegisterGuideState
    >((ref) {
      return RegisterGuideViewModel(ref);
    });

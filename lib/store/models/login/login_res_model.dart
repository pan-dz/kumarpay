import 'package:kumar_pay/data/models/api_response.dart';
import 'package:kumar_pay/core/utils/json_conv.dart';

class AccountPoolItem {
  final int id;
  final String name;
  final String account;
  final String channel;
  final int type;
  final int status;
  final int deleted;
  final String creator;
  final int crtDate;

  const AccountPoolItem({
    required this.id,
    required this.name,
    required this.account,
    required this.channel,
    required this.type,
    required this.status,
    required this.deleted,
    required this.creator,
    required this.crtDate,
  });

  factory AccountPoolItem.fromJson(Map<String, dynamic> json) {
    return AccountPoolItem(
      id: asInt(json['id']),
      name: asString(json['name']),
      account: asString(json['account']),
      channel: asString(json['channel']),
      type: asInt(json['type']),
      status: asInt(json['status']),
      deleted: asInt(json['deleted']),
      creator: asString(json['creator']),
      crtDate: asInt(json['crtDate']),
    );
  }
}

class AccountPoolListData {
  final int total;
  final List<AccountPoolItem> list;

  const AccountPoolListData({required this.total, required this.list});

  factory AccountPoolListData.fromList(List<dynamic> raw) {
    final items = raw
        .whereType<Map<String, dynamic>>()
        .map(AccountPoolItem.fromJson)
        .toList();
    return AccountPoolListData(total: items.length, list: items);
  }

  factory AccountPoolListData.fromJson(Map<String, dynamic> json) {
    return AccountPoolListData(
      total: asInt(json['total']),
      list: json['list'] is List
          ? (json['list'] as List)
                .whereType<Map<String, dynamic>>()
                .map(AccountPoolItem.fromJson)
                .toList()
          : const <AccountPoolItem>[],
    );
  }
}

class IAccountPoolListResModel extends ApiResponse<AccountPoolListData> {
  const IAccountPoolListResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IAccountPoolListResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<AccountPoolListData>(json, (raw) {
      if (raw is Map<String, dynamic>) {
        return AccountPoolListData.fromJson(raw);
      }
      if (raw is List) {
        return AccountPoolListData.fromList(raw);
      }
      return null;
    });
    return IAccountPoolListResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

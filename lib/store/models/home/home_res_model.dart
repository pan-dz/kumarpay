import 'package:kumar_pay/data/models/api_response.dart';

/// 首页信息数据模型
class HomeInfoModel {
  final String usdtExchangerate;
  final String currency;
  final String registerHost;
  final String tgChannelLink;
  final String appDownloadUrl;
  final String okTurnstileSitekey;
  final String apiHost;
  final Map<String, dynamic> rewardRules;
  final List<String> bannerSrcs;
  final List<HomeNews> newsList;
  final String payerTimeoutTime;
  final String siteKey;
  final bool pinFlag;
  final List<String> ctTypes;
  final int ifFinishNewbieActivity;
  final int rptPaymentMode;
  final int rsKeyMode;

  const HomeInfoModel({
    required this.usdtExchangerate,
    required this.currency,
    required this.registerHost,
    required this.tgChannelLink,
    required this.appDownloadUrl,
    required this.okTurnstileSitekey,
    required this.apiHost,
    required this.rewardRules,
    required this.bannerSrcs,
    required this.newsList,
    required this.payerTimeoutTime,
    required this.siteKey,
    required this.pinFlag,
    required this.ctTypes,
    required this.ifFinishNewbieActivity,
    required this.rptPaymentMode,
    required this.rsKeyMode,
  });

  static String _asString(Object? v) => v?.toString() ?? '';
  static int _asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('${v ?? ''}') ?? 0;
  }

  static bool _asBool(Object? v) {
    if (v is bool) return v;
    final s = '${v ?? ''}'.toLowerCase();
    return s == 'true' || s == '1';
  }

  static List<String> _asStringList(Object? v) {
    if (v is List) {
      return v
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  static List<HomeNews> _asNewsList(Object? v) {
    if (v is List) {
      return v
          .where((e) => e is Map<String, dynamic>)
          .map((e) => HomeNews.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return <HomeNews>[];
  }

  factory HomeInfoModel.fromJson(Map<String, dynamic> json) {
    return HomeInfoModel(
      usdtExchangerate: _asString(json['usdtExchangerate']),
      currency: _asString(json['currency']),
      registerHost: _asString(json['registerHost']),
      tgChannelLink: _asString(json['tgChannelLink']),
      appDownloadUrl: _asString(json['appDownloadUrl']),
      okTurnstileSitekey: _asString(json['okTurnstileSitekey']),
      apiHost: _asString(json['apiHost']),
      rewardRules:
          (json['rewardRules'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{},
      bannerSrcs: _asStringList(json['bannerSrcs']),
      newsList: _asNewsList(json['newsList']),
      payerTimeoutTime: _asString(json['payerTimeoutTime']),
      siteKey: _asString(json['siteKey']),
      pinFlag: _asBool(json['pinFlag']),
      ctTypes: _asStringList(json['ctTypes']),
      ifFinishNewbieActivity: _asInt(json['ifFinishNewbieActivity']),
      rptPaymentMode: _asInt(json['rptPaymentMode']),
      rsKeyMode: _asInt(json['rsKeyMode']),
    );
  }

  Map<String, dynamic> toJson() => {
    'usdtExchangerate': usdtExchangerate,
    'currency': currency,
    'registerHost': registerHost,
    'tgChannelLink': tgChannelLink,
    'appDownloadUrl': appDownloadUrl,
    'okTurnstileSitekey': okTurnstileSitekey,
    'apiHost': apiHost,
    'rewardRules': rewardRules,
    'bannerSrcs': bannerSrcs,
    'newsList': newsList.map((e) => e.toJson()).toList(),
    'payerTimeoutTime': payerTimeoutTime,
    'siteKey': siteKey,
    'pinFlag': pinFlag,
    'ctTypes': ctTypes,
    'ifFinishNewbieActivity': ifFinishNewbieActivity,
    'rptPaymentMode': rptPaymentMode,
    'rsKeyMode': rsKeyMode,
  };
}

/// 首页新闻
class HomeNews {
  final int id;
  final String cover;
  final String name;
  final String code;
  final int type;
  final String content;
  final int crtDate;
  final String crtUser;
  final int sort;

  const HomeNews({
    required this.id,
    required this.cover,
    required this.name,
    required this.code,
    required this.type,
    required this.content,
    required this.crtDate,
    required this.crtUser,
    required this.sort,
  });

  static String _s(Object? v) => v?.toString() ?? '';
  static int _i(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('${v ?? ''}') ?? 0;
  }

  factory HomeNews.fromJson(Map<String, dynamic> json) => HomeNews(
    id: _i(json['id']),
    cover: _s(json['cover']),
    name: _s(json['name']),
    code: _s(json['code']),
    type: _i(json['type']),
    content: _s(json['content']),
    crtDate: _i(json['crtDate']),
    crtUser: _s(json['crtUser']),
    sort: _i(json['sort']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cover': cover,
    'name': name,
    'code': code,
    'type': type,
    'content': content,
    'crtDate': crtDate,
    'crtUser': crtUser,
    'sort': sort,
  };
}

/// 获取首页信息响应
class IGetHomeInfoResModel extends ApiResponse<HomeInfoModel> {
  const IGetHomeInfoResModel({required super.code, super.msg, super.data});

  factory IGetHomeInfoResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<HomeInfoModel>(
      json,
      (raw) => raw is Map<String, dynamic> ? HomeInfoModel.fromJson(raw) : null,
    );
    return IGetHomeInfoResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

class CustomerServiceInfoModel {
  final String username;
  final String channel;
  final String account;
  final int type;
  final String mid;
  final String name;

  const CustomerServiceInfoModel({
    required this.username,
    required this.channel,
    required this.account,
    required this.type,
    required this.mid,
    required this.name,
  });

  static String _s(Object? v) => v?.toString() ?? '';
  static int _i(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('${v ?? ''}') ?? 0;
  }

  factory CustomerServiceInfoModel.fromJson(Map<String, dynamic> json) {
    return CustomerServiceInfoModel(
      username: _s(json['username']),
      channel: _s(json['channel']),
      account: _s(json['account']),
      type: _i(json['type']),
      mid: _s(json['mid']),
      name: _s(json['name']),
    );
  }
}

class IGetCustomerServiceResModel
    extends ApiResponse<CustomerServiceInfoModel> {
  const IGetCustomerServiceResModel({
    required super.code,
    required super.msg,
    super.data,
  });

  factory IGetCustomerServiceResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<CustomerServiceInfoModel>(
      json,
      (raw) => raw is Map<String, dynamic>
          ? CustomerServiceInfoModel.fromJson(raw)
          : null,
    );
    return IGetCustomerServiceResModel(
      code: base.code,
      msg: base.msg ?? '',
      data: base.data,
    );
  }
}

/// 获取未读消息
class IUnReadCountResModel extends ApiResponse<double> {
  const IUnReadCountResModel({required super.code, super.msg, super.data});

  factory IUnReadCountResModel.fromJson(Map<String, dynamic> json) {
    final base = ApiResponse.fromJsonGeneric<double>(json, (raw) {
      if (raw is num) return raw.toDouble();
      if (raw is String) return double.tryParse(raw);
      return null;
    });
    return IUnReadCountResModel(
      code: base.code,
      msg: base.msg,
      data: base.data,
    );
  }
}

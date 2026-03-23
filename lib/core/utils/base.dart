import 'package:kumar_pay/app/config/base_config.dart';
import 'package:kumar_pay/store/models/home/home_res_model.dart';

///
/// 去除手机号中的常见格式字符：空格、短横线、括号
/// 不会移除前导的加号（用于 E.164 格式判断）
///
String stripPhoneFormatting(String input) {
  final trimmed = input.trim();
  // 仅移除空格、短横线和括号，保留其他字符（如开头的 +）
  return trimmed.replaceAll(RegExp(r'[ \-()]'), '');
}

///
/// 校验印度手机号是否合法
/// 支持以下几种常见输入：
/// - 本地 10 位：XXXXXXXXXX（首位 7-9）
/// - 前缀 0：0XXXXXXXXXX
/// - 前缀国家码：91XXXXXXXXXX
/// - 国际拨号：0091XXXXXXXXXX
/// - E.164：+91XXXXXXXXXX
///
bool isValidIndianPhone(String? input) {
  if (input == null) return false;
  final s = stripPhoneFormatting(input);
  if (s.isEmpty) return false;

  // 严格完整匹配
  final localPattern = RegExp(r'^[6-9]\d{9}$');
  final e164Pattern = RegExp(r'^\+91[6-9]\d{9}$');

  if (s.startsWith('+')) {
    // 仅支持 +91 的 E.164
    return e164Pattern.hasMatch(s);
  }

  if (s.length == 10 && localPattern.hasMatch(s)) return true;

  if (s.length == 11 && s.startsWith('0')) {
    final local = s.substring(1);
    return localPattern.hasMatch(local);
  }

  if (s.length == 12 && s.startsWith('91')) {
    final local = s.substring(2);
    return localPattern.hasMatch(local);
  }

  if (s.length == 14 && s.startsWith('0091')) {
    final local = s.substring(4);
    return localPattern.hasMatch(local);
  }

  return false;
}

///
/// 通用脱敏：保留前后指定字符，中间用固定掩码替换。
/// 如果包含 '@'，默认仅脱敏 '@' 之前的部分。
///
String maskMiddle(
  String input, {
  int prefix = 4,
  int suffix = 4,
  String mask = '****',
  bool preserveAfterAt = true,
}) {
  final raw = input.trim();
  if (raw.isEmpty) return raw;

  var head = raw;
  var tail = '';
  if (preserveAfterAt) {
    final atIndex = raw.indexOf('@');
    if (atIndex >= 0) {
      head = raw.substring(0, atIndex);
      tail = raw.substring(atIndex);
    }
  }

  if (head.length <= prefix + suffix) return raw;

  final start = head.substring(0, prefix);
  final end = head.substring(head.length - suffix);
  return '$start$mask$end$tail';
}

///
/// 密码校验：长度 6–30 位
/// - 纯数字
/// - 字母+数字（必须同时包含字母和数字）
///
bool isValidPassword(String value) {
  if (value.length < 6 || value.length > 30) return false;
  if (RegExp(r'^\d{6,30}$').hasMatch(value)) return true;
  final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
  final hasDigit = RegExp(r'\d').hasMatch(value);
  final isAlnum = RegExp(r'^[A-Za-z0-9]{6,30}$').hasMatch(value);
  return isAlnum && hasLetter && hasDigit;
}

///
/// 校验渠道是否匹配
///
bool isChannelMatched(String channelValue, String targetChannel) {
  final normalizedTarget = targetChannel.trim();
  if (normalizedTarget.isEmpty) return false;

  final cleaned = channelValue.replaceAll('[', '').replaceAll(']', '');
  final channels = cleaned
      .split(',')
      .map((item) => item.trim().replaceAll('"', '').replaceAll("'", ''))
      .where((item) => item.isNotEmpty);

  return channels.contains(normalizedTarget);
}

///
/// 客服跳转地址
///
String buildCustomerServiceLink(
  CustomerServiceInfoModel? info, {
  String visitorId = '',
  String visitorName = '',
  String fallback = '',
}) {
  if (info == null) {
    return fallback;
  }

  final account = info.account.trim();
  switch (info.type) {
    case 1:
      final waAccount = account.replaceAll(RegExp(r'[^0-9]'), '');
      if (waAccount.isEmpty) {
        return fallback;
      }
      return Uri.parse('https://wa.me/$waAccount').toString();

    case 2:
      final tgAccount = account.replaceFirst(RegExp(r'^@+'), '');
      if (tgAccount.isEmpty) {
        return fallback;
      }
      return Uri.parse('https://t.me/$tgAccount').toString();

    case 3:
      final mid = info.mid.trim();
      final username = info.username.trim();
      final base = KumarBaseConfig.customerServiceLink.replaceFirst(
        RegExp(r'/+$'),
        '',
      );
      final query =
          {'ent_id': mid, 'visitor_id': username, 'visitor_name': username}
              .entries
              .map((entry) {
                final key = Uri.encodeQueryComponent(entry.key);
                final value = Uri.encodeQueryComponent(entry.value);
                return '$key=$value';
              })
              .join('&');
      return '$base/#/chatIndex?$query';

    default:
      return fallback;
  }
}

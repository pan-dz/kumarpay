class UsdtTokenInfo {
  final String symbol;
  final String address;
  final int decimals;
  final String name;

  const UsdtTokenInfo({
    required this.symbol,
    required this.address,
    required this.decimals,
    required this.name,
  });

  factory UsdtTokenInfo.fromJson(Map<String, dynamic> json) {
    return UsdtTokenInfo(
      symbol: json['symbol']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      decimals: (json['decimals'] is num)
          ? (json['decimals'] as num).toInt()
          : int.tryParse(json['decimals']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class UsdtTransaction {
  final String transactionId;
  final UsdtTokenInfo? tokenInfo;
  final int blockTimestamp;
  final String from;
  final String to;
  final String type;
  final String value;

  const UsdtTransaction({
    required this.transactionId,
    required this.tokenInfo,
    required this.blockTimestamp,
    required this.from,
    required this.to,
    required this.type,
    required this.value,
  });

  factory UsdtTransaction.fromJson(Map<String, dynamic> json) {
    return UsdtTransaction(
      transactionId: json['transaction_id']?.toString() ?? '',
      tokenInfo: json['token_info'] is Map<String, dynamic>
          ? UsdtTokenInfo.fromJson(json['token_info'] as Map<String, dynamic>)
          : null,
      blockTimestamp: (json['block_timestamp'] is num)
          ? (json['block_timestamp'] as num).toInt()
          : int.tryParse(json['block_timestamp']?.toString() ?? '') ?? 0,
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }
}

class UsdtMeta {
  final int at;
  final int pageSize;

  const UsdtMeta({required this.at, required this.pageSize});

  factory UsdtMeta.fromJson(Map<String, dynamic> json) {
    return UsdtMeta(
      at: (json['at'] is num)
          ? (json['at'] as num).toInt()
          : int.tryParse(json['at']?.toString() ?? '') ?? 0,
      pageSize: (json['page_size'] is num)
          ? (json['page_size'] as num).toInt()
          : int.tryParse(json['page_size']?.toString() ?? '') ?? 0,
    );
  }
}

class UsdtListResponse {
  final List<UsdtTransaction> data;
  final bool success;
  final UsdtMeta? meta;

  const UsdtListResponse({
    required this.data,
    required this.success,
    required this.meta,
  });

  factory UsdtListResponse.fromJson(Map<String, dynamic> json) {
    return UsdtListResponse(
      data: (json['data'] is List)
          ? (json['data'] as List)
                .whereType<Map<String, dynamic>>()
                .map(UsdtTransaction.fromJson)
                .toList()
          : const <UsdtTransaction>[],
      success: json['success'] == true,
      meta: json['meta'] is Map<String, dynamic>
          ? UsdtMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }
}

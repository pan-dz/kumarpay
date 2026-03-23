import 'package:flutter/material.dart';

enum UpiProviderType {
  paytmBusiness(
    ctType: 16, // Paytm Business - 16
    label: 'Paytm Business',
    desc: 'Paytm Business is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-Paytm.webp',
    icon: Icons.bolt,
    brandColor: Color(0xFFE53935),
  ),

  mobiKwik(
    ctType: 2, // MobiKwik - 2
    label: 'MobiKwik',
    desc: 'MobiKwik is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-Mobikwik.webp',
    icon: Icons.account_balance_wallet,
    brandColor: Color(0xFF2F7CF0),
  ),

  paytm(
    ctType: 9, // Paytm - 9
    label: 'Paytm',
    desc: 'Paytm is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-Paytm.webp',
    icon: Icons.payment,
    brandColor: Color(0xFF2196F3),
  ),

  phonePe(
    ctType: 1, // PhonePe - 1
    label: 'PhonePe',
    desc: 'PhonePe is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-Phonepe.webp',
    icon: Icons.phone_android,
    brandColor: Color(0xFF673AB7),
  ),

  freecharge(
    ctType: 3, // Freecharge - 3
    label: 'Freecharge',
    desc:
        'Freecharge offers digital payment and mobile recharge services in India.',
    iconAsset: 'assets/images/upi-Freecharge.webp',
    icon: Icons.send,
    brandColor: Color(0xFFF37321),
  ),

  airtel(
    ctType: 6, // Airtel - 6
    label: 'Airtel',
    desc: 'Airtel is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-Airtel.webp',
    icon: Icons.bolt,
    brandColor: Color(0xFFE53935),
  ),

  slice(
    ctType: 15,
    label: 'Slice', // Slice - 15
    desc: 'Slice is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-Slice.webp',
    icon: Icons.credit_card,
    brandColor: Color(0xFF8E24AA),
  ),

  bharatpe(
    ctType: 4,
    label: 'BharatPe', // BharatPe - 4
    desc: 'BharatPe is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-BharatPe.webp',
    icon: Icons.credit_card,
    brandColor: Color(0xFF8E24AA),
  ),

  cubbank(
    ctType: 5,
    label: 'Cub Bank', // Cub Bank - 5
    desc: 'Cub Bank is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-CubBank.webp',
    icon: Icons.credit_card,
    brandColor: Color(0xFF8E24AA),
  ),

  induspay(
    ctType: 7,
    label: 'IndusPay', // IndusPay - 7
    desc: 'IndusPay is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-IndusPay.webp',
    icon: Icons.credit_card,
    brandColor: Color(0xFF8E24AA),
  ),

  icicibank(
    ctType: 8,
    label: 'ICICI Bank', // ICICI Bank - 8
    desc: 'ICICI Bank is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-ICICIBank.webp',
    icon: Icons.credit_card,
    brandColor: Color(0xFF8E24AA),
  ),

  yespay(
    ctType: 10,
    label: 'Yes Pay', // Yes Pay - 10
    desc: 'Yes Pay is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-YesPay.webp',
    icon: Icons.credit_card,
    brandColor: Color(0xFF8E24AA),
  ),

  bhim(
    ctType: 11,
    label: 'Bhim', // Bhim - 11
    desc: 'Bhim is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-Bhim.webp',
    icon: Icons.credit_card,
    brandColor: Color(0xFF8E24AA),
  ),

  esaf(
    ctType: 12,
    label: 'Esaf', // Esaf - 12
    desc: 'Esaf is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-Esaf.webp',
    icon: Icons.credit_card,
    brandColor: Color(0xFF8E24AA),
  ),

  utk(
    ctType: 13,
    label: 'Utk', // Utk - 13
    desc: 'Utk is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-UTK.webp',
    icon: Icons.credit_card,
    brandColor: Color(0xFF8E24AA),
  ),

  jiof(
    ctType: 14,
    label: 'JioFi', // JioFi - 14
    desc: 'JioFi is an Indian digital payment platform.',
    iconAsset: 'assets/images/upi-JioFi.webp',
    icon: Icons.credit_card,
    brandColor: Color(0xFF8E24AA),
  ),

  unknown(
    ctType: -1,
    label: 'UPI',
    desc: 'UPI is a digital payment platform.',
    iconAsset: 'assets/images/customer_service.webp',
    icon: Icons.account_balance_wallet,
    brandColor: Color(0xFF2F7CF0),
  );

  final int ctType;
  final String label;
  final String desc;
  final String iconAsset;
  final IconData icon;
  final Color brandColor;
  int get otpLength => switch (this) {
    UpiProviderType.mobiKwik => 6,
    UpiProviderType.freecharge => 4,
    UpiProviderType.paytm => 6,
    UpiProviderType.phonePe => 5,
    UpiProviderType.airtel => 4,
    UpiProviderType.slice => 4,
    _ => 4,
  };

  const UpiProviderType({
    required this.ctType,
    required this.label,
    required this.desc,
    required this.iconAsset,
    required this.icon,
    required this.brandColor,
  });

  static UpiProviderType fromCtType(int ctType) {
    return switch (ctType) {
      16 => UpiProviderType.paytmBusiness,
      2 => UpiProviderType.mobiKwik,
      9 => UpiProviderType.paytm,
      1 => UpiProviderType.phonePe,
      3 => UpiProviderType.freecharge,
      6 => UpiProviderType.airtel,
      15 => UpiProviderType.slice,
      4 => UpiProviderType.bharatpe,
      5 => UpiProviderType.cubbank,
      7 => UpiProviderType.induspay,
      8 => UpiProviderType.icicibank,
      10 => UpiProviderType.yespay,
      11 => UpiProviderType.bhim,
      12 => UpiProviderType.esaf,
      13 => UpiProviderType.utk,
      14 => UpiProviderType.jiof,

      _ => UpiProviderType.unknown,
    };
  }
}

/// 订单状态枚举
enum OrderStatus { init, paying, pending, success, close, fail }

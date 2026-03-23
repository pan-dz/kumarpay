import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'package:kumar_pay/presentation/viewmodels/login_viewmodel/register_guide_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterGuidePage extends ConsumerStatefulWidget {
  const RegisterGuidePage({super.key});

  @override
  ConsumerState<RegisterGuidePage> createState() => _RegisterGuidePageState();
}

class _RegisterGuidePageState extends ConsumerState<RegisterGuidePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(registerGuideProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      // appBar: const NavAppBar(title: 'Customer Service'),
      body: const _CustomerServiceBody(),
    );
  }
}

/// 客服页面主体内容组件
class _CustomerServiceBody extends ConsumerStatefulWidget {
  const _CustomerServiceBody();

  @override
  ConsumerState<_CustomerServiceBody> createState() =>
      _CustomerServiceBodyState();
}

class _CustomerServiceBodyState extends ConsumerState<_CustomerServiceBody> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerGuideProvider);
    final notifier = ref.read(registerGuideProvider.notifier);

    return _buildBody(context, state, notifier);
  }

  Widget _buildBody(
    BuildContext context,
    RegisterGuideState state,
    RegisterGuideViewModel notifier,
  ) {
    // 数据展示状态
    return _CustomerServiceList(state: state, notifier: notifier);
  }
}

/// 客服列表组件
enum _ContactType { whatsapp, telegram }

class _CustomerServiceList extends StatelessWidget {
  final RegisterGuideState state;
  final RegisterGuideViewModel notifier;

  const _CustomerServiceList({required this.state, required this.notifier});

  Future<void> _openContact(
    BuildContext context, {
    required String title,
    required String number,
    required String url,
  }) async {
    final lowerTitle = title.toLowerCase();
    final trimmedNumber = number.trim();
    final cleanedDigits = trimmedNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final cleanedTelegram = trimmedNumber.replaceAll(RegExp(r'\s+'), '');
    final telegramUsername = cleanedTelegram.replaceFirst(RegExp(r'^@'), '');
    final isTelegramUsername = RegExp(
      r'^@?[a-zA-Z][a-zA-Z0-9_]{4,31}$',
    ).hasMatch(cleanedTelegram);
    final numberUri = Uri.tryParse(trimmedNumber);

    final candidates = <Uri>[];

    if (lowerTitle.contains('whatsapp')) {
      if (numberUri != null && numberUri.hasScheme) {
        candidates.add(numberUri);
      }
      if (cleanedDigits.isNotEmpty) {
        candidates.add(Uri.parse('https://wa.me/$cleanedDigits'));
        candidates.add(Uri.parse('https://wa.me/$cleanedDigits'));
        candidates.add(Uri.parse('https://wa.me/$cleanedDigits'));
      }
    } else if (lowerTitle.contains('telegram')) {
      if (numberUri != null && numberUri.hasScheme) {
        candidates.add(numberUri);
      }
      if (isTelegramUsername && telegramUsername.isNotEmpty) {
        candidates.add(Uri.parse('tg://resolve?domain=$telegramUsername'));
        candidates.add(Uri.parse('https://t.me/$telegramUsername'));
      } else {
        candidates.add(Uri.parse('tg://'));
      }
    }

    final fallbackUri = Uri.tryParse(url);
    if (fallbackUri != null) {
      candidates.add(fallbackUri);
    }

    for (final uri in candidates) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    }

    if (!context.mounted) return;
    AppToast.error(context, 'Could not launch contact app');
  }

  Widget _buildHero() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: SizedBox(
        height: 235,
        width: double.infinity,
        child: Image.asset('assets/images/register_1.webp', fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required _ContactType contactType,
    required String title,
    required String number,
    required String url,
  }) {
    final openText = contactType == _ContactType.whatsapp
        ? 'Open WApp'
        : 'Open TG';

    return InkWell(
      onTap: () =>
          _openContact(context, title: title, number: number, url: url),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD8DCE5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF2B2F36),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              number,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF1F2024),
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 5),
                            IconButton(
                              onPressed: () async {
                                final copied = await notifier.copyContactText(
                                  number,
                                );
                                if (!context.mounted) return;
                                if (copied) {
                                  final label =
                                      contactType == _ContactType.whatsapp
                                      ? 'WhatsApp'
                                      : 'Telegram';
                                  AppToast.success(
                                    context,
                                    'Copied $label info',
                                  );
                                } else {
                                  AppToast.error(context, 'Copy failed');
                                }
                              },
                              icon: const Icon(
                                Icons.copy_rounded,
                                size: 18,
                                color: Color(0xFF9A9DA6),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              splashRadius: 18,
                              tooltip: 'Copy',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'KumarPay Support Agent',
                    style: TextStyle(
                      color: Color(0xFF8F9098),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () =>
                  _openContact(context, title: title, number: number, url: url),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      openText,
                      style: const TextStyle(
                        color: Color(0xFFF49A00),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Color(0xFFF49A00),
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required Color iconBg,
    required IconData icon,
    required String index,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E3E8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$index  ',
                        style: const TextStyle(
                          color: Color(0xFF00AF4D),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: title,
                        style: const TextStyle(
                          color: Color(0xFF1F2024),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF8F9098),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(
    BuildContext context, {
    required String number,
    required String url,
  }) {
    return InkWell(
      onTap: () => _openContact(
        context,
        title: 'Our WhatsApp Number',
        number: number,
        url: url,
      ),
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 77,
          width: double.infinity,
          child: Image.asset('assets/images/register_2.webp'),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E3E8)),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 18, color: Color(0xFF1F2024)),
            SizedBox(width: 8),
            Text(
              'Log in',
              style: TextStyle(
                color: Color(0xFF1F2024),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final whatsapp = state.whatsapp;
    final telegram = state.telegram;

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              _buildHero(),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    _buildContactCard(
                      context,
                      contactType: _ContactType.whatsapp,
                      title: 'Our WhatsApp Number',
                      number: whatsapp.number,
                      url: whatsapp.url,
                    ),
                    const SizedBox(height: 10),
                    _buildContactCard(
                      context,
                      contactType: _ContactType.telegram,
                      title: 'Our Telegram Number',
                      number: telegram.number,
                      url: telegram.url,
                    ),
                    const SizedBox(height: 10),
                    _buildStepItem(
                      iconBg: const Color(0xFFB55BFF),
                      icon: Icons.looks_one,
                      index: '01',
                      title: 'Save Our Number',
                      subtitle:
                          'Save ${whatsapp.number} as KumarPay Support in your contacts',
                    ),
                    const SizedBox(height: 10),
                    _buildStepItem(
                      iconBg: const Color(0xFF4B7BFF),
                      icon: Icons.apps,
                      index: '02',
                      title: 'Open WhatsApp',
                      subtitle:
                          'Open WhatsApp and find KumarPay Support from your contacts',
                    ),
                    const SizedBox(height: 10),
                    _buildStepItem(
                      iconBg: const Color(0xFF42C3FF),
                      icon: Icons.favorite,
                      index: '03',
                      title: "Send 'Hi'",
                      subtitle:
                          "Send a message saying 'Hi KumarPay' to\nstart the conversation 'Hi KumarPay'",
                    ),
                    const SizedBox(height: 10),
                    _buildStepItem(
                      iconBg: const Color(0xFFFF6D6D),
                      icon: Icons.phone,
                      index: '04',
                      title: 'Wait for Callback',
                      subtitle:
                          'Our agent will call you within 30 minutes to guide you through setup 30',
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPromoBanner(
                  context,
                  number: whatsapp.number,
                  url: whatsapp.url,
                ),
                const SizedBox(height: 6),
                _buildLoginButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

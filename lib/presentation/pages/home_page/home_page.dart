import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';
import 'package:kumar_pay/presentation/pages/home_page/sell_set_page.dart';
import 'package:kumar_pay/presentation/pages/layout_page.dart';
import 'package:kumar_pay/presentation/pages/mine_page/buy_history_page.dart';
import 'package:kumar_pay/presentation/pages/mine_page/sell_history_page.dart';
import 'package:kumar_pay/presentation/pages/upi_page/add_upi_page.dart';
import 'package:kumar_pay/presentation/viewmodels/buy_viewmodel/buy_viewmodel.dart';
import 'package:kumar_pay/presentation/viewmodels/home_viewmodel/home_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:kumar_pay/presentation/widgets/hx_webview.dart';
import 'package:kumar_pay/presentation/pages/home_page/new_details_page.dart';
import 'package:kumar_pay/presentation/widgets/hx_inkwell_button.dart';
import 'package:kumar_pay/presentation/widgets/popup_dialog.dart';
import 'package:kumar_pay/presentation/widgets/simple_html_text.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _msgController = ScrollController();
  ProviderSubscription<List<String>>? _bannerImagesSub;
  int _currentMessageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(0),
            sliver: SliverToBoxAdapter(child: _buildBannerWithCard(context)),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverToBoxAdapter(child: _buildMessageTicker(context)),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(child: _buildNewsHeader(context)),
          ),

          _buildNewsListSliver(context),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 初始化时只触发一次用户信息拉取
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   if (!mounted) return;
    //   try {
    //     final actions = ref.read(userActionsProvider);
    //     final res = await actions.loginApi(IUserInfoReqModel());
    //     '===== userInfo: ${res.data}'.log();
    //   } catch (e) {
    //     '===== userInfo error: $e'.log();
    //   }
    // });

    // 预加载 Banner 图片，减少进入页面时的首屏等待
    _bannerImagesSub = ref.listenManual<List<String>>(
      homeViewModelProvider.select((s) => s.bannerImages),
      (prev, next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          for (final url in next) {
            if (url.isEmpty) continue;
            precacheImage(NetworkImage(url), context);
          }
        });
      },
    );

    // 首帧后预缓存当前列表，避免只在变化时缓存
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final current = ref.read(homeViewModelProvider).bannerImages;
      for (final url in current) {
        if (url.isEmpty) continue;
        precacheImage(NetworkImage(url), context);
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _bannerImagesSub?.close();
    super.dispose();
  }

  /* Banner + Card 叠加布局 */
  Widget _buildBannerWithCard(BuildContext context) {
    const double bannerHeight = 280;
    const double extraSpaceForCard = 250;
    return SizedBox(
      height: bannerHeight + extraSpaceForCard,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 顶部 Banner（保持原有样式与指示点）
          Positioned.fill(
            top: 0,
            bottom: extraSpaceForCard,
            child: _buildCarousel(context),
          ),

          // 底部悬浮卡片
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildInfoCard(context),
          ),
        ],
      ),
    );
  }

  /* 轮播图 */
  Widget _buildCarousel(BuildContext context) {
    final bannerImages = ref.watch(homeViewModelProvider).bannerImages;
    final bannerIndex = ref.watch(homeViewModelProvider).bannerIndex;
    return ClipRRect(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: 280,
            width: double.infinity,
            child: CarouselSlider.builder(
              itemCount: bannerImages.length,
              options: CarouselOptions(
                height: 280,
                viewportFraction: 1,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 600),
                onPageChanged: (i, _) {
                  ref
                      .read(homeViewModelProvider.notifier)
                      .onBannerPageChanged(i);
                },
              ),
              itemBuilder: (context, index, _) {
                final img = bannerImages[index];
                final size = MediaQuery.of(context).size;
                final dpr = MediaQuery.of(context).devicePixelRatio;
                final cacheWidth = (size.width * dpr).round();
                final cacheHeight = (280 * dpr).round();
                return Image.network(
                  img,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  cacheWidth: cacheWidth,
                  cacheHeight: cacheHeight,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stack) {
                    return Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.black26,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            bottom: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannerImages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: bannerIndex == i ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: bannerIndex == i
                        ? Theme.of(context).primaryColor
                        : Colors.white.withOpacity(1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* 卡片信息 */
  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final usdtExchangerate = ref.watch(homeViewModelProvider).usdtExchangerate;
    final reward = ref.watch(homeViewModelProvider).reward;

    final box = GetStorage();
    final userInfo = box.read(StorageKeys.userInfo);
    // 从缓存解析 itoken 显示文本
    String itokenText = '0';
    String todayProfit = '0';
    if (userInfo is Map) {
      try {
        final map = userInfo.cast<String, dynamic>();
        final parsed = num.tryParse(map['itoken'].toString());
        if (parsed != null && parsed < 0) {
          itokenText = '0';
        } else {
          itokenText = map['itoken'].toString();
        }
        todayProfit = map['todayProfit'].toString();
      } catch (_) {}
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HxButton(
            color: Color.fromARGB(255, 19, 67, 255),
            fontColor: Color.fromARGB(255, 255, 255, 255),
            text: 'Test WebView',
            loading: false,
            height: 44,
            onButtonPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const HxWebView(
                    title: 'Paytm Login',
                    // url: 'https://dashboard.paytm.com',
                    url:
                        'https://custom.bibilabu.click/#/chatIndex?ent_id=30&visitor_id=9200000001&visitor_name=9200000001',
                    userAgent:
                        'Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Mobile Safari/537.36',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          HxButton(
            color: Color.fromARGB(255, 19, 67, 255),
            fontColor: Color.fromARGB(255, 255, 255, 255),
            text: 'Down New Apk ddd123123123',
            loading: false,
            height: 44,
            onButtonPressed: () async {
              // 下载apk并提示安装
              final url = 'https://down.kumarpay-in.com/test/kumarpay-test.apk';
              if (url.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new version available')),
                );
                return;
              }
              await HxWebView.openUrl(url);
            },
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'My IToken',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '1 Rs = 1 IToken, 1 USDT = $usdtExchangerate IToken',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF8F9098),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text('🇮🇳', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    itokenText,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              // _BuyButton(),
              HxButton(
                color: Theme.of(context).primaryColor,
                fontColor: Colors.white,
                text: 'Buy',
                loading: false,
                width: 120,
                height: 44,
                type: HxButtonType.small,
                onButtonPressed: () {
                  ref.read(buyViewModelProvider.notifier).handleSearchRefresh();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const LayoutPage(initialIndex: 1),
                    ),
                    (route) => false,
                  );
                },
                leading: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.currency_rupee,
                    size: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                // leadingGap: 4,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today Profit',
                      style: TextStyle(
                        color: Color(0xFF8F9098),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      todayProfit,
                      style: TextStyle(
                        color: Color(0xFF1F2024),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reward',
                      style: TextStyle(
                        color: Color(0xFF8F9098),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      reward,
                      style: TextStyle(
                        color: Color(0xFF1F2024),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              HxButton(
                color: Color(0xFF1F2024),
                fontColor: Color(0xFF1F2024),
                text: 'Buy History',
                loading: false,
                width: 120,
                height: 44,
                outlined: true,
                type: HxButtonType.small,
                onButtonPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BuyHistoryPage()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto Selling',
                      style: TextStyle(
                        color: Color(0xFF8F9098),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    _LinkRow(
                      label: 'Sell Set',
                      onButtonPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SellSetPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sell Faster',
                      style: TextStyle(
                        color: Color(0xFF8F9098),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    _LinkRow(
                      label: 'Link Upi',
                      onButtonPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddUpiPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              HxButton(
                color: Color(0xFF1F2024),
                fontColor: Color(0xFF1F2024),
                text: 'Sell History',
                loading: false,
                width: 120,
                height: 44,
                outlined: true,
                type: HxButtonType.small,
                onButtonPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SellHistoryPage()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: Color(0xFFD3D5DD), height: 0.5),
        ],
      ),
    );
  }

  /* 公共提示 */
  Widget _buildMessageTicker(BuildContext context) {
    final messages = ref.watch(homeViewModelProvider).messages;
    final hasData = messages.isNotEmpty;

    return GestureDetector(
      onTap: () {
        _showTickerDialog(context, messages[_currentMessageIndex]);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0x19FFA300),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.campaign, color: Color(0xFFFFA300)),
            const SizedBox(width: 8),
            Expanded(
              child: hasData
                  ? VerticalTicker(
                      messages: messages,
                      controller: _msgController,
                      onIndexChanged: (i) {
                        if (mounted) {
                          setState(() => _currentMessageIndex = i);
                        }
                      },
                    )
                  : SizedBox(),
            ),
            if (hasData) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.info_outline,
                size: 20,
                color: Color(0xFFD9D9D9),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showTickerDialog(BuildContext context, Map<String, String> item) {
    final theme = Theme.of(context);

    final maxH = MediaQuery.of(context).size.height * 0.7;
    final dialogChild = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['title'] ?? '',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Color(0xFF8F9098),
                ),
                const SizedBox(width: 6),
                Text(
                  item['subtitle'] ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8F9098),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SimpleHtmlText(
              html: item['content'] ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );

    PopupDialog.show(
      context: context,
      config: PopupDialogConfig(
        title: 'Notify',
        showFooterButtons: false,
        showDoubleButtons: false,
        minHeight: 400,
      ),
      child: dialogChild,
    );
  }

  /* 新闻标题 */
  Widget _buildNewsHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 36,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      // padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'News',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          // HxInkWellButton(
          //     onButtonPressed: () {},
          //     child: Text(
          //       'More',
          //       style: TextStyle(color: Color(0xFF1F2024), fontSize: 14),
          //     ),
          //   ),
        ],
      ),
    );
  }

  /* 新闻列表 */
  Widget _buildNewsListSliver(BuildContext context) {
    final news = ref.watch(homeViewModelProvider).news;

    if (news.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: Center(
                  child: Image.asset(
                    'assets/images/no_data.webp',
                    width: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Text(
                'No data',
                textAlign: TextAlign.center,
                style: TextStyle(color: const Color(0xFF8E9199), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = news[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),

            child: Container(
              width: double.infinity,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 0.5, color: const Color(0xFFD3D5DD)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),

                title: Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF2F3036),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    item['subtitle'] ?? '',
                    style: const TextStyle(
                      color: Color(0xFF8F9098),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.black26,
                ),
                onTap: () {
                  final title = item['title']?.toString() ?? '';
                  final content = item['content']?.toString() ?? '';
                  final time = item['subtitle']?.toString() ?? '';

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NewDetailsPage(
                        title: title,
                        content: content,
                        time: time,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }, childCount: news.length),
      ),
    );
  }
}

// 文本链接行，带右箭头
class _LinkRow extends StatelessWidget {
  final String label;
  final VoidCallback onButtonPressed;
  const _LinkRow({required this.label, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return HxInkWellButton(
      onButtonPressed: onButtonPressed,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_right, size: 18, color: Color(0xFF1F2024)),
        ],
      ),
    );
  }
}

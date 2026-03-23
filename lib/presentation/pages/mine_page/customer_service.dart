import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:kumar_pay/presentation/widgets/nav_app_bar.dart';
import 'package:kumar_pay/presentation/widgets/common_widgets.dart';
import 'package:kumar_pay/presentation/viewmodels/mine_viewmodel/customer_service_viewmodel.dart';
import 'package:kumar_pay/store/models/user/user_res_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerServicePage extends ConsumerStatefulWidget {
  const CustomerServicePage({super.key});

  @override
  ConsumerState<CustomerServicePage> createState() =>
      _CustomerServicePageState();
}

class _CustomerServicePageState extends ConsumerState<CustomerServicePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(customerServiceProvider.notifier).refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: const NavAppBar(title: 'Customer Service'),
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
    final state = ref.watch(customerServiceProvider);
    final notifier = ref.read(customerServiceProvider.notifier);

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      child: _buildBody(context, state, notifier),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CustomerServiceState state,
    CustomerServiceViewModel notifier,
  ) {
    // 加载中状态
    if (state.isLoading && state.services.isEmpty) {
      return const CommonLoadingView();
    }

    // 错误状态
    if (state.error != null && state.services.isEmpty) {
      return _ErrorView(error: state.error!, onRetry: () => notifier.retry());
    }

    // 空数据状态
    if (state.services.isEmpty) {
      return const _EmptyView();
    }

    // 数据展示状态
    return _CustomerServiceList(services: state.services);
  }
}

class _ServiceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String url;

  const _ServiceTile({
    required this.title,
    required this.subtitle,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const _TelegramIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1F2024),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8F9098),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          HxButton(
            width: 70,
            height: 32,
            color: Theme.of(context).primaryColor,
            fontColor: Colors.white,
            text: 'Go',
            type: HxButtonType.small,
            onButtonPressed: () async {
              final uri = Uri.parse(url);
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not launch')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TelegramIcon extends StatelessWidget {
  const _TelegramIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF2AABEE),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.send, color: Colors.white, size: 16),
    );
  }
}

class _DividerIndent extends StatelessWidget {
  const _DividerIndent();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 0.5,
      thickness: 0.5,
      indent: 12,
      endIndent: 12,
      color: Color(0xFFD3D5DD),
    );
  }
}

/// 错误视图组件
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Loading Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BC48),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 空状态视图组件
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No customer service information available',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// 客服列表组件
class _CustomerServiceList extends StatelessWidget {
  final List<CustomerserviceModel> services;

  const _CustomerServiceList({required this.services});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: services.length,
      separatorBuilder: (_, index) => const _DividerIndent(),
      itemBuilder: (context, index) {
        final item = services[index];
        return _ServiceTile(
          title: item.label,
          subtitle: item.nickname,
          url: item.url,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/presentation/pages/layout_page.dart';
import 'package:kumar_pay/presentation/viewmodels/active_viewmodel/newbie_reward_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:kumar_pay/presentation/widgets/nav_app_bar.dart';

class NewbieRewardPage extends ConsumerStatefulWidget {
  const NewbieRewardPage({super.key});

  @override
  ConsumerState<NewbieRewardPage> createState() => _NewbieRewardPageState();
}

class _NewbieRewardPageState extends ConsumerState<NewbieRewardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(newbieRewardProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newbieRewardProvider);
    final vm = ref.read(newbieRewardProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: NavAppBar(
        title: 'Newbie Rewards',
        onBack: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const LayoutPage(initialIndex: 4),
            ),
            (route) => false,
          );
        },
      ),
      body: SafeArea(child: _buildBody(state, vm)),
    );
  }

  Widget _buildBody(NewbieRewardState state, NewbieRewardViewModel vm) {
    if (state.isLoading && state.tasks.isEmpty) {
      return const _LoadingView();
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BonusCard(
              totalBonus: state.totalBonus,
              allDone: state.allDone,
              tasks: state.tasks,
              isLoading: state.isReceiving,
              onReceive: () => vm.onReceiveReward(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _TaskList(tasks: state.tasks, vm: vm),
            ),
          ],
        ),
        if (state.isLoading && state.tasks.isNotEmpty)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class _BonusCard extends StatelessWidget {
  final int totalBonus;
  final String allDone;
  final List<NewbieRewardTask> tasks;
  final bool isLoading;
  final VoidCallback onReceive;

  const _BonusCard({
    required this.totalBonus,
    required this.allDone,
    required this.tasks,
    required this.isLoading,
    required this.onReceive,
  });

  @override
  Widget build(BuildContext context) {
    final allTasksDone =
        tasks.isNotEmpty && tasks.every((task) => task.status == 1);
    final isClaimed = allDone == '1';
    final canReceive =
        !isClaimed && allTasksDone && (allDone.isEmpty || allDone == '0');

    final buttonColor = isClaimed
        ? const Color(0xFFFFA300)
        : canReceive
        ? const Color(0xFF00BC48)
        : const Color(0xFFE8E9F1);

    final buttonFontColor = isClaimed || canReceive
        ? Colors.white
        : const Color(0xFF8F9098);

    final buttonText = isClaimed ? 'Claimed' : 'Receive';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total bonus',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8F9098),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/newbie_5.webp',
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),

                    const SizedBox(width: 6),
                    Text(
                      totalBonus.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        color: Color(0xFF1F2024),
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          HxButton(
            width: isLoading ? 110 : 80,
            height: 32,
            color: buttonColor,
            fontColor: buttonFontColor,
            text: buttonText,
            type: HxButtonType.small,
            loading: isLoading,
            onButtonPressed: !canReceive ? () {} : onReceive,
          ),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<NewbieRewardTask> tasks;
  final NewbieRewardViewModel vm;
  const _TaskList({required this.tasks, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final isLast = index == tasks.length - 1;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TaskTile(task: task, vm: vm),
              if (!isLast) const Divider(height: 0.5, color: Color(0xFFE8E9F1)),
            ],
          );
        },
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final NewbieRewardTask task;
  final NewbieRewardViewModel vm;
  const _TaskTile({required this.task, required this.vm});

  @override
  Widget build(BuildContext context) {
    final bgColor = task.uiStatus == NewbieRewardTaskStatus.done
        ? const Color(0xFFFFA300)
        : const Color(0xFF00BC48);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Image.asset(
                  task.iconAsset,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 6),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1F2024),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Text(task.activityCode.toString()),
                  ],
                ),
              ],
            ),
          ),

          HxButton(
            width: 68,
            height: 28,
            color: bgColor,
            fontColor: Colors.white,
            text: task.actionText,
            type: HxButtonType.small,
            onButtonPressed: task.status == 1
                ? () {}
                : () => vm.onTaskTap(context, task),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

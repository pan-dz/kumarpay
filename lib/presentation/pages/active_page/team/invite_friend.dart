import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/presentation/viewmodels/active_viewmodel/team/invite_friend_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/common_widgets.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:kumar_pay/presentation/widgets/nav_app_bar.dart';
import 'package:kumar_pay/store/models/active/active_res_model.dart';

class InviteFriendPage extends ConsumerStatefulWidget {
  const InviteFriendPage({super.key});

  @override
  ConsumerState<InviteFriendPage> createState() => _InviteFriendPageState();
}

class _InviteFriendPageState extends ConsumerState<InviteFriendPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(inviteFriendViewModelProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    ref.invalidate(inviteFriendViewModelProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inviteFriendViewModelProvider);
    final vm = ref.read(inviteFriendViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: const NavAppBar(title: 'Invite Friends Rewards'),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              children: [
                // _TipBanner(text: state.tipText),
                // const SizedBox(height: 12),
                // _SummaryCard(
                //   totalBonus: state.totalBonus,
                //   receivedBonus: state.receivedBonus,
                //   doneCount: state.doneCount,
                //   totalCount: state.totalCount,
                // ),
                const SizedBox(height: 4),
                _DoneAllCard(
                  doneCount: state.doneCount,
                  totalCount: state.totalCount,
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      _ShowFriendsHeader(
                        expanded: state.showFriends,
                        onTap: vm.toggleShowFriends,
                      ),
                      const SizedBox(height: 8),

                      if (state.showFriends) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              // _ReceiveButton(
                              //   state: state,
                              //   onPressed: vm.receiveRewards,
                              // ),
                              // const SizedBox(height: 12),
                              _FriendList(items: state.items),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (state.isLoading)
              const Positioned.fill(child: CommonLoadingView()),
          ],
        ),
      ),
    );
  }
}

class _TipBanner extends StatelessWidget {
  final String text;
  const _TipBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFFFF6E9)),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFFFF8B00),
          fontWeight: FontWeight.w500,
          height: 1.1,
        ),
      ),
    );
  }
}

class _DoneAllCard extends StatelessWidget {
  final int doneCount;
  final int totalCount;

  const _DoneAllCard({required this.doneCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      height: 76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: const DecorationImage(
          image: AssetImage('assets/images/team_img2.webp'),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 22, 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 110),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF0FF).withOpacity(0.78),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$doneCount/$totalCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF2A81D8),
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Done / All Friends',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double totalBonus;
  final double receivedBonus;
  final int doneCount;
  final int totalCount;

  const _SummaryCard({
    required this.totalBonus,
    required this.receivedBonus,
    required this.doneCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 125,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC64A), Color(0xFFFFE2A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFA300),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.currency_rupee,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        totalBonus.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 26,
                          color: Color(0xFFB97000),
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Total bonus',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E6B00),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 125,
              child: Column(
                children: [
                  _MiniStatCard(
                    title: 'Received bonus',
                    value: receivedBonus.toStringAsFixed(0),
                    colors: const [Color(0xFFFF7A9B), Color(0xFFFFB5C8)],
                    icon: Icons.workspace_premium,
                  ),
                  const SizedBox(height: 8),
                  _MiniStatCard(
                    title: 'Done / All Friends',
                    value: '$doneCount/$totalCount',
                    colors: const [Color(0xFF6BB6FF), Color(0xFFAED6FF)],
                    icon: Icons.emoji_events,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final List<Color> colors;
  final IconData icon;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.colors,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ShowFriendsHeader extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;
  const _ShowFriendsHeader({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Show Your Friends',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F2024),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF8F9098),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiveButton extends StatelessWidget {
  final InviteFriendState state;
  final Future<void> Function() onPressed;

  const _ReceiveButton({required this.state, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final status = state.rewardStatus;
    final isReady = status == InviteRewardStatus.ready;
    final isClaimed = status == InviteRewardStatus.claimed;
    final isPending = status == InviteRewardStatus.pending;

    final text = isClaimed ? 'Claimed' : 'Receive Rewards';
    final color = isReady
        ? Theme.of(context).primaryColor
        : const Color(0xFF1F2024);
    final fontColor = isReady ? Colors.white : const Color(0xFF1F2024);

    return HxButton(
      text: text,
      color: color,
      fontColor: fontColor,
      height: 46,
      borderRadius: 8,
      type: HxButtonType.medium,
      outlined: isPending,
      onButtonPressed: isReady ? () async => onPressed() : () {},
    );
  }
}

class _FriendList extends StatelessWidget {
  final List<ActivityRecord> items;
  const _FriendList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // SizedBox(
                //   width: 20,
                //   child: const Icon(
                //     Icons.card_giftcard,
                //     color: Color(0xFFFFA300),
                //     size: 18,
                //   ),
                // ),
                Expanded(
                  child: Text(
                    'Invite Friends',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1F2024),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 60),

                SizedBox(
                  width: 128,
                  child: Text(
                    'Status',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1F2024),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE8E9F1)),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: SizedBox(
                height: 200,
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child: Center(
                        child: Image.asset(
                          'assets/images/no_data.webp',
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Text(
                      'No friends invited yet.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8F9098),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...items.map((item) => _FriendRow(item: item)),
        ],
      ),
    );
  }
}

class _FriendRow extends StatelessWidget {
  final ActivityRecord item;
  const _FriendRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDone = item.done == 1;
    final bgImage = isDone
        ? 'assets/images/team_img3.webp'
        : 'assets/images/team_img4.webp';
    final text = isDone ? 'Done' : 'Undone';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8E9F1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // SizedBox(
          //   width: 40,
          //   child: Text(
          //     '₹${item.rewardAmt.toStringAsFixed(0)}',
          //     style: const TextStyle(
          //       fontSize: 20,
          //       color: Color(0xFF1F2024),
          //       fontWeight: FontWeight.w700,
          //     ),
          //   ),
          // ),
          Expanded(
            child: Text(
              item.username,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF71727A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 60),

          Container(
            width: 128,
            height: 34,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(bgImage),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

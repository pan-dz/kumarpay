import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/presentation/viewmodels/upi_viewmodel/freecharge_viewmodel.dart';
import 'package:kumar_pay/core/utils/enum.dart';
import 'package:kumar_pay/presentation/widgets/common_widgets.dart';
import 'package:kumar_pay/presentation/widgets/customer_service.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:kumar_pay/presentation/widgets/nav_app_bar.dart';
import 'package:kumar_pay/presentation/pages/mine_page/customer_service.dart';
import 'package:kumar_pay/presentation/pages/layout_page.dart';
import 'package:kumar_pay/presentation/widgets/popup_dialog.dart';

enum FreechargeEntrySource { buyList, buyHistory }

class FreechargePage extends ConsumerWidget {
  final String id;
  final int ctime;
  final String upiName;
  final int ctType;
  final String walletAddress;
  final FreechargeEntrySource entrySource;
  const FreechargePage({
    super.key,
    required this.id,
    required this.ctime,
    required this.upiName,
    required this.ctType,
    required this.walletAddress,
    required this.entrySource,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = FreechargeArgs(
      id: id,
      ctime: ctime,
      upiName: upiName,
      ctType: ctType,
      walletAddress: walletAddress,
    );
    final state = ref.watch(freechargeViewModelFamilyProvider(args));
    final vm = ref.read(freechargeViewModelFamilyProvider(args).notifier);
    final providerLabel = UpiProviderType.fromCtType(state.ctType).label;

    void handleExit() {
      vm.resetCurrentStep();
      if (entrySource == FreechargeEntrySource.buyHistory) {
        Navigator.of(context).pop();
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LayoutPage(initialIndex: 1)),
        (route) => false,
      );
    }

    return CustomerServiceRouteScope(
      pageId: 'freecharge',
      child: Stack(
        children: [
          WillPopScope(
            onWillPop: () async {
              handleExit();
              return false;
            },
            child: Scaffold(
              appBar: NavAppBar(
                title: 'Buy IToken details',
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF1F2024),
                    ),
                    onPressed: () => vm.onTapHistory(context),
                  ),
                ],
                onBack: handleExit,
              ),
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  _CountdownBanner(remaining: state.remainingText),
                  const SizedBox(height: 8),
                  _StepIndicator(currentStep: state.currentStep),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Please use the\n$providerLabel(${state.upiName})of your choice to pay',
                            style: const TextStyle(
                              color: Color(0xFFFF2E2E),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (state.currentStep == 0) ...[
                            ...state.infoItems.map(
                              (item) => _InfoRow(
                                label: item.label,
                                value: item.value,
                                onCopy: () => vm.onCopy(item, context),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const _NoticeBlock(),
                            const SizedBox(height: 16),
                            _CancelRow(
                              onCancel: () => vm.onCancelOrder(context),
                            ),
                          ] else if (state.currentStep == 1) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Notice! सूचना',
                                  style: TextStyle(
                                    color: const Color(0xFFFF2E2E),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '📢📢📢The Buying amount must be Same,\notherwise the transaction will not be completed.\n1. क्रय राशि समान होनी चाहिए, अन्यथा लेनदेन पूरा नहीं होगा. \n📢📢📢Once payment completed,please wait\npatiently for the transaction review.\n2. एक बार भुगतान पूरा हो जाने पर, कृपया लेनदेन समीक्षा के लिए धैर्यपूर्वक प्रतीक्षा करें. \n📢📢📢Payment must be completed on time\nafter token not receive within 30 minutes please\ncontact customer service in your exclusive VIP group.\n3.टोकन 30 मिनट के भीतर प्राप्त न होने पर भुगतान समय पर पूरा किया जाना चाहिए कृपया अपने विशिष्ट वीआईपी समूह में ग्राहक सेवा से संपर्क करें',
                              style: TextStyle(
                                color: Color(0xFF8F9098),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _CancelRow(
                              onCancel: () => vm.onCancelOrder(context),
                            ),
                          ] else if (state.currentStep == 2) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Notice! सूचना',
                                  style: TextStyle(
                                    color: const Color(0xFFFF2E2E),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '📢📢📢Please carefully check the amount you have paid. If the amount in rupees is insufficient, make sure to complete the remaining payment to the same person. If you have overpaid, unfortunately, you will need to contact the recipient directly to request a refund. We will provide the recipient\'s information to assist you. For any of the actions above, please contact customer service for\nassistance in completing your purchase. Ensure your payment is accurate to avoid any unnecessary issues!',
                              style: const TextStyle(
                                color: Color(0xFF8F9098),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _CancelRow(
                              onCancel: () => vm.onCancelOrder(context),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'View tutorial',
                                  style: TextStyle(
                                    color: Color(0xFF2A6AE9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFF2A6AE9),
                                    height: 1.17,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),

                            Center(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/img_verification.png',
                                    width: 130,
                                    height: 130,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Waiting for review',
                                    style: TextStyle(
                                      color: Color(0xFF1F2024),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 1.17,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const CustomerServicePage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Contact Customer Service',
                                      style: TextStyle(
                                        color: Color(0xFF2A6AE9),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Color(0xFF2A6AE9),
                                        height: 1.17,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  if (state.currentStep == 0)
                    _BottomPaymentInfo(
                      onGoPay: () => vm.onGoPay(context),
                      onFinish: () => vm.onFinishPayment(),
                    )
                  else if (state.currentStep == 1)
                    _BottomPaymentProve(
                      onPrevious: vm.onPrevious,
                      onConfirm: () => vm.onConfirm(context),
                    ),
                ],
              ),
            ),
          ),
          if (state.isLoading)
            const Positioned.fill(child: CommonLoadingView()),
        ],
      ),
    );
  }
}

class _CountdownBanner extends StatelessWidget {
  final String remaining;
  const _CountdownBanner({required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF5E8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    remaining,
                    style: const TextStyle(
                      color: Color(0xFFFFA300),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Please pay in time',
                    style: TextStyle(color: Color(0xFFFFA300)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              PopupDialog.show(
                context: context,
                config: PopupDialogConfig(
                  position: DialogPosition.center,
                  title: 'Tips',
                  showCloseButton: false,
                  showFooterButtons: true,
                  showDoubleButtons: true,
                  primaryButtonText: 'Ok',
                  secondaryButtonText: 'Payment tutorial',
                  buttonType: HxButtonType.small,
                  minHeight: 200,
                ),
                child: const Text(
                  'Please use the selected UPI app to complete the payment within the time limit; otherwise, the order will be canceled.',
                  style: TextStyle(
                    color: Color(0xFF8F9098),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              );
            },
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                border: Border.all(width: 1.5, color: const Color(0xFFFFA300)),
              ),
              child: const Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    color: Color(0xFFFFA300),
                    fontSize: 10,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['Payment info', 'Payment prove', 'Audit'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(labels.length, (index) {
          final isActive = index <= currentStep;
          final isCurrent = index == currentStep;
          final color = isActive ? const Color(0xFF1F2024) : Colors.grey;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    _StepDot(active: isActive, isCurrent: isCurrent),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                if (index != labels.length - 1)
                  Container(
                    width: 70,
                    height: 1,
                    color: const Color(0xFFD3D5DD),
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;
  final bool isCurrent;
  const _StepDot({required this.active, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF1F2024) : Colors.grey[300];
    final radius = isCurrent ? 8.0 : 3.0;
    return SizedBox(
      height: 20,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: color,
        child: isCurrent
            ? const Icon(Icons.check, size: 12, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8F9098),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1F2024),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.copy,
                  size: 18,
                  color: Color(0xFF8F9098),
                ),
                onPressed: onCopy,
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFFE8E9F1), height: 0.5),
      ],
    );
  }
}

class _NoticeBlock extends StatelessWidget {
  const _NoticeBlock();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notice:',
          style: TextStyle(
            color: Color(0xFFFF2E2E),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'The remittance amount must be consistent, otherwise the\ntransaction will be completed.',
          style: TextStyle(
            color: Color(0xFFFF2E2E),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Notice:',
          style: TextStyle(
            color: Color(0xFFFF2E2E),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'If you have already paid, please patiently for the transaction\nreview, ple not cancel the order',
          style: TextStyle(
            color: Color(0xFFFF2E2E),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _CancelRow extends StatelessWidget {
  final VoidCallback onCancel;
  const _CancelRow({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Unable to complete payment',
          style: TextStyle(color: Color(0xFF1F2024), fontSize: 12),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onCancel,
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF2A6AE9),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF2A6AE9),
              height: 1.17,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'my orde.',
          style: TextStyle(color: Color(0xFF1F2024), fontSize: 12),
        ),
      ],
    );
  }
}

class _BottomPaymentInfo extends StatelessWidget {
  final VoidCallback onGoPay;
  final VoidCallback onFinish;
  const _BottomPaymentInfo({required this.onGoPay, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: HxButton(
              outlined: true,
              color: const Color(0xFF1F2024),
              fontColor: const Color(0xFF1F2024),
              text: 'Go pay',
              type: HxButtonType.medium,
              onButtonPressed: onGoPay,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: HxButton(
              color: const Color(0xFF00BC48),
              fontColor: Colors.white,
              text: 'Finish payment',
              type: HxButtonType.medium,
              onButtonPressed: onFinish,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomPaymentProve extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onConfirm;
  const _BottomPaymentProve({
    required this.onPrevious,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: HxButton(
              outlined: true,
              color: const Color(0xFF1F2024),
              fontColor: const Color(0xFF1F2024),
              text: 'Previous',
              type: HxButtonType.medium,
              onButtonPressed: onPrevious,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: HxButton(
              color: const Color(0xFF00BC48),
              fontColor: Colors.white,
              text: 'Confirm payment',
              type: HxButtonType.medium,
              onButtonPressed: onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}

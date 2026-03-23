import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'package:kumar_pay/core/utils/base.dart';
import 'package:kumar_pay/presentation/widgets/popup_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/presentation/widgets/common_widgets.dart';
import 'package:kumar_pay/presentation/viewmodels/upi_viewmodel/upi_viewmodel.dart';
import 'package:kumar_pay/presentation/pages/upi_page/add_upi_page.dart';
import 'package:kumar_pay/presentation/pages/upi_page/upi_details_page.dart';

class UpiPage extends ConsumerWidget {
  const UpiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(upiViewModelProvider);

    return Stack(
      children: [
        AppPageScaffold(
          title: 'UPI',
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          automaticallyImplyLeading: false,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFE8E9F1)),
            child: Column(
              children: [
                const _UpiHeader(),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: vm.isLoading
                        ? const CommonLoadingView(showBarrier: false)
                        : Container(
                            child: vm.accounts.isEmpty
                                ? const _DefaultEmpty()
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: vm.accounts.length,
                                    itemBuilder: (context, index) {
                                      final account = vm.accounts[index];
                                      return _UpiCard(account: account);
                                    },
                                  ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DefaultEmpty extends StatelessWidget {
  const _DefaultEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/no_data.webp', width: 100, height: 100),
          const SizedBox(height: 8),
          Text(
            'No UPI partners have been linked yet\nPlease Link your UPI to proceed',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF71727A),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpiHeader extends ConsumerWidget {
  const _UpiHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            alignment: Alignment.center,
            child: const Text(
              'If you Change your upi id, please relink UPI.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFFF2E2E),
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => ref
                      .read(upiViewModelProvider.notifier)
                      .handleClickVideo(),
                  child: Image.asset('assets/images/upi_img1.webp'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddUpiPage()),
                    ),
                  },
                  child: Image.asset('assets/images/upi_img2.webp'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpiCard extends ConsumerWidget {
  final UpiAccount account;
  const _UpiCard({required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                account.provider.iconAsset,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${account.provider.label}(${maskMiddle(account.maskedNumber, prefix: 3, suffix: 4, mask: '****', preserveAfterAt: false)})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2024),
                      ),
                    ),

                    Row(
                      children: [
                        // Text(
                        //   account.pnname,
                        //   style: const TextStyle(
                        //     color: Color(0xFF8F9098),
                        //     fontWeight: FontWeight.w500,
                        //     fontSize: 12,
                        //   ),
                        // ),
                        // const SizedBox(width: 10),
                        Text(
                          maskMiddle(account.upiId),
                          style: const TextStyle(
                            color: Color(0xFF8F9098),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: account.statuses
                    .map((s) => _StatusBadge(color: s.color, label: s.label))
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 6),
              _ActionButton(
                icon: Icons.settings,
                label: 'Operate',
                onTap: () => PopupDialog.show(
                  context: context,
                  config: PopupDialogConfig(
                    position: DialogPosition.bottom,
                    title: 'Operate the linked Kyc Partner',
                    showCloseButton: false,
                    showFooterButtons: true,
                    showDoubleButtons: false,
                    primaryButtonText: 'Cancel',
                    minHeight: 200,
                  ),
                  child: _OperatePopupDialog(
                    accountId: account.id,
                    upiName: account.upiId,
                    inSell: account.inSell,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: Icons.list_alt,
                label: 'Details',
                onTap: account.upiId != ''
                    ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UpiDetailsPage(
                            upiName: account.upiId,
                            provider: account.provider,
                          ),
                        ),
                      )
                    : () => {
                        AppToast.show(
                          context,
                          message: 'UPI ID is empty, cannot view details',
                          type: AppToastType.warning,
                        ),
                      },
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Color(0xFFD3D5DD), height: 0.5),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  final String label;
  const _StatusBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1F2024),
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: Color(0xFF8F9098)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8F9098),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperatePopupDialog extends ConsumerWidget {
  final String accountId;
  final String upiName;
  final bool inSell;
  const _OperatePopupDialog({
    required this.accountId,
    required this.upiName,
    required this.inSell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const divider = Divider(color: Color(0xFFD3D5DD), height: 0.5);
    const relinkStyle = TextStyle(
      fontSize: 16,
      color: Color(0xFF00BC48),
      fontWeight: FontWeight.w700,
    );
    const startSellStyle = TextStyle(
      fontSize: 16,
      color: Color(0xFF1F2024),
      fontWeight: FontWeight.w700,
    );
    const stopSellStyle = TextStyle(
      fontSize: 16,
      color: Color(0xFF8F9098),
      fontWeight: FontWeight.w500,
    );

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          divider,
          Material(
            color: Colors.white,
            child: InkWell(
              onTap: () async {
                if (accountId.isEmpty) return;
                Navigator.of(context).pop();
                await ref
                    .read(upiViewModelProvider.notifier)
                    .updateUpiStatus(context, id: accountId, status: 5);
              },
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Center(child: Text('Relink', style: relinkStyle)),
              ),
            ),
          ),
          divider,
          Material(
            color: Colors.white,
            child: InkWell(
              onTap: () async {
                if (accountId.isEmpty) return;
                Navigator.of(context).pop();
                if (inSell) {
                  await ref
                      .read(upiViewModelProvider.notifier)
                      .stopSell(context, ctId: accountId);
                } else {
                  await ref
                      .read(upiViewModelProvider.notifier)
                      .startSell(context, ctId: accountId);
                }
              },
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Center(
                  child: Text(
                    inSell ? 'Stop Sell' : 'Start Sell',
                    style: inSell ? stopSellStyle : startSellStyle,
                  ),
                ),
              ),
            ),
          ),
          divider,
        ],
      ),
    );
  }
}

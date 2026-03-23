import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:kumar_pay/presentation/widgets/popup_dialog.dart';
import 'package:kumar_pay/presentation/widgets/nav_app_bar.dart';
import 'package:kumar_pay/presentation/widgets/common_widgets.dart';
import 'package:kumar_pay/presentation/viewmodels/upi_viewmodel/add_upi_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/customer_service.dart';
import 'package:kumar_pay/presentation/widgets/otp_verification_dialog.dart';
import 'package:kumar_pay/store/models/upi/upi_res_model.dart';
import 'package:kumar_pay/core/utils/enum.dart';

class AddUpiPage extends ConsumerStatefulWidget {
  final UpiInfoModel? prefillInfo;
  const AddUpiPage({super.key, this.prefillInfo});

  @override
  ConsumerState<AddUpiPage> createState() => _AddUpiPageState();
}

class _AddUpiPageState extends ConsumerState<AddUpiPage> {
  bool _otpDialogOpen = false;
  BuildContext? _otpDialogContext;

  @override
  void initState() {
    super.initState();
    final info = widget.prefillInfo;
    if (info != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(addUpiViewModelProvider.notifier).prefillFromUpiInfo(info);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(addUpiViewModelProvider, (prev, next) {
      final wasOpen = prev?.showCaptchaDialog ?? false;
      final shouldOpen = next.showCaptchaDialog;
      if (!wasOpen && shouldOpen && !_otpDialogOpen) {
        _otpDialogOpen = true;
        final ctType = next.selectedProvider?.ctType ?? -1;
        final otpLength = UpiProviderType.fromCtType(ctType).otpLength;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            _otpDialogContext = dialogContext;
            return Consumer(
              builder: (context, ref, _) {
                final vmState = ref.watch(addUpiViewModelProvider);
                return OtpVerificationDialog(
                  phone: vmState.upiNo ?? '',
                  length: otpLength,
                  closeDelaySeconds: 5,
                  autoStartCountdown: vmState.autoStartOtpCountdown,
                  errorText: vmState.otpErrorMessage,
                  onSendOtp: (_) async => ref
                      .read(addUpiViewModelProvider.notifier)
                      .handleResendOtp(context),
                  onVerified: (code) async {
                    final ok = await ref
                        .read(addUpiViewModelProvider.notifier)
                        .handleVerifyOtp(context, code);
                    if (ok) {
                      final dialogContext = _otpDialogContext;
                      if (dialogContext != null &&
                          Navigator.of(dialogContext).canPop()) {
                        Navigator.of(dialogContext).pop();
                      }
                    }
                  },
                );
              },
            );
          },
        ).whenComplete(() {
          _otpDialogOpen = false;
          _otpDialogContext = null;
          ref.read(addUpiViewModelProvider.notifier).hideOtpDialog();
        });
      }

      if (wasOpen && !shouldOpen && _otpDialogOpen) {
        final dialogContext = _otpDialogContext;
        if (dialogContext != null && Navigator.of(dialogContext).canPop()) {
          Navigator.of(dialogContext).pop();
        }
      }
    });

    final vmState = ref.watch(addUpiViewModelProvider);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final isBusyCooldown = (vmState.systemBusyUntilMs ?? 0) > nowMs;

    return CustomerServiceRouteScope(
      pageId: 'add_upi',
      child: Stack(
        children: [
          WillPopScope(
            onWillPop: () async {
              ref.read(addUpiViewModelProvider.notifier).resetForm();
              return true;
            },
            child: Scaffold(
              appBar: NavAppBar(
                title: 'Link New UPI',
                onBack: () {
                  ref.read(addUpiViewModelProvider.notifier).resetForm();
                  Navigator.of(context).pop();
                },
              ),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFFE8E9F1)),
                alignment: Alignment.center,
                child: Column(
                  children: [const _FormSection(), const _BottomActionArea()],
                ),
              ),
            ),
          ),
          if (vmState.isSubmitting || isBusyCooldown)
            Positioned.fill(
              child: CommonLoadingView(
                message: 'send otp...',
                barrierColor: const Color.fromARGB(192, 0, 0, 0),
              ),
            ),
        ],
      ),
    );
  }
}

class _FormSection extends ConsumerStatefulWidget {
  const _FormSection();
  @override
  ConsumerState<_FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends ConsumerState<_FormSection> {
  late final TextEditingController _nameController;
  late final TextEditingController _upiController;

  @override
  void initState() {
    super.initState();
    final vm = ref.read(addUpiViewModelProvider);
    _nameController = TextEditingController(text: vm.name ?? '');
    _upiController = TextEditingController(text: vm.upiNo ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _upiController.dispose();
    ref.read(addUpiViewModelProvider.notifier).resetForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(addUpiViewModelProvider);

    // Keep TextEditingController in sync with ViewModel when state changes.
    ref.listen(addUpiViewModelProvider, (prev, next) {
      final nextName = next.name ?? '';
      if (nextName != _nameController.text) {
        _nameController.value = TextEditingValue(
          text: nextName,
          selection: TextSelection.collapsed(offset: nextName.length),
        );
      }
      final nextUpi = next.upiNo ?? '';
      if (nextUpi != _upiController.text) {
        _upiController.value = TextEditingValue(
          text: nextUpi,
          selection: TextSelection.collapsed(offset: nextUpi.length),
        );
      }
    });
    const labelStyle = TextStyle(
      fontSize: 14,
      color: Color(0xFF1F2024),
      fontWeight: FontWeight.w500,
    );
    const valueStyle = TextStyle(
      fontSize: 16,
      color: Color(0xFF1F2024),
      fontWeight: FontWeight.w700,
    );
    const double labelWidth = 75;
    Divider divider() => const Divider(
      color: Color(0xFFD3D5DD),
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Material(
            color: Colors.white,
            child: InkWell(
              onTap: () {
                PopupDialog.show(
                  context: context,
                  config: PopupDialogConfig(
                    position: DialogPosition.bottom,
                    title: null,
                    showCloseButton: false,
                    showFooterButtons: false,
                    barrierDismissible: true,
                    minHeight: MediaQuery.of(context).size.height - 200,
                  ),
                  child: const _SelectUpiListPopupDialog(),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: labelWidth,
                      child: const Text('Partner', style: labelStyle),
                    ),
                    Expanded(
                      child: Text(
                        vm.selectedProvider?.name ?? 'Select the kyc partner',
                        style: valueStyle,
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
          divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: labelWidth,
                  child: const Text('Name', style: labelStyle),
                ),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(20),
                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
                    ],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1F2024),
                      fontWeight: FontWeight.w700,
                      height: 1.20,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8F9098),
                        fontWeight: FontWeight.w500,
                        height: 1.20,
                      ),
                    ),
                    onChanged: ref
                        .read(addUpiViewModelProvider.notifier)
                        .setName,
                  ),
                ),
              ],
            ),
          ),
          divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: labelWidth,
                  child: const Text('UPI No', style: labelStyle),
                ),
                Expanded(
                  child: TextField(
                    controller: _upiController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1F2024),
                      fontWeight: FontWeight.w700,
                      height: 1.20,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Phone No',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8F9098),
                        fontWeight: FontWeight.w500,
                        height: 1.20,
                      ),
                    ),
                    onChanged: ref
                        .read(addUpiViewModelProvider.notifier)
                        .setUpiNo,
                  ),
                ),
              ],
            ),
          ),
          if (vm.showBackupUpiSelect && vm.backupUpiOptions.isNotEmpty) ...[
            divider(),
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  PopupDialog.show(
                    context: context,
                    config: PopupDialogConfig(
                      position: DialogPosition.bottom,
                      title: 'Select Backup UPI',
                      showCloseButton: false,
                      showFooterButtons: false,
                      barrierDismissible: true,
                      minHeight: MediaQuery.of(context).size.height - 220,
                    ),
                    child: const _SelectBackupUpiPopupDialog(),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: const Text('UPI Select', style: labelStyle),
                      ),
                      Expanded(
                        child: Text(
                          vm.selectedBackupUpi ?? 'Select UPI',
                          style: valueStyle,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomActionArea extends ConsumerWidget {
  const _BottomActionArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(addUpiViewModelProvider.notifier);
    final state = ref.watch(addUpiViewModelProvider);
    final canAddUpi =
        state.selectedBackupUpi != null &&
        state.selectedBackupUpi!.trim().isNotEmpty;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final busyUntilMs = state.systemBusyUntilMs ?? 0;
    final isBusyCooldown = busyUntilMs > nowMs;
    return Padding(
      padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
      child: HxButton(
        width: double.infinity,
        height: 52,
        color: Theme.of(context).primaryColor,
        fontColor: Colors.white,
        text: 'Link Kyc',
        loading: isBusyCooldown,
        onButtonPressed: () {
          if (isBusyCooldown) return;
          if (canAddUpi) {
            vm.handleAddUpi(context);
          } else {
            vm.handleMonitorFlow(context);
          }
        },
      ),
    );
  }
}

class _SelectUpiListPopupDialog extends ConsumerWidget {
  const _SelectUpiListPopupDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(addUpiViewModelProvider);
    final providers = vm.providers;

    final titleStyle = const TextStyle(
      fontSize: 14,
      color: Color(0xFF1F2024),
      fontWeight: FontWeight.w700,
    );
    final subtitleStyle = const TextStyle(
      fontSize: 11,
      color: Color(0xFF8F9098),
      fontWeight: FontWeight.w500,
      height: 1,
    );

    final divider = const Divider(color: Color(0xFFD3D5DD), height: 0.5);

    final maxListHeight = MediaQuery.of(context).size.height - 220;

    return SizedBox(
      height: maxListHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: providers.length,
        separatorBuilder: (context, index) => divider,
        itemBuilder: (context, index) {
          final p = providers[index];
          final enabled = p.enabled;
          final providerType = UpiProviderType.fromCtType(p.ctType);
          final textColor = enabled ? null : const Color(0xFFB0B3B8);
          return InkWell(
            onTap: enabled
                ? () {
                    ref
                        .read(addUpiViewModelProvider.notifier)
                        .selectProvider(p);
                    Navigator.of(context).pop(p.name);
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: enabled ? 1.0 : 0.2,
                    child: Image.asset(
                      providerType.iconAsset,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: titleStyle.copyWith(color: textColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.desc,
                          style: subtitleStyle.copyWith(color: textColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (enabled)
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 24,
                      color: Color(0xFF8F9098),
                    )
                  else
                    const SizedBox(width: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SelectBackupUpiPopupDialog extends ConsumerWidget {
  const _SelectBackupUpiPopupDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(addUpiViewModelProvider);
    final options = vm.backupUpiOptions;

    final titleStyle = const TextStyle(
      fontSize: 14,
      color: Color(0xFF1F2024),
      fontWeight: FontWeight.w700,
    );

    final divider = const Divider(color: Color(0xFFD3D5DD), height: 0.5);

    final maxListHeight = MediaQuery.of(context).size.height - 220;

    return SizedBox(
      height: maxListHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: options.length,
        separatorBuilder: (context, index) => divider,
        itemBuilder: (context, index) {
          final item = options[index];
          return InkWell(
            onTap: () {
              ref.read(addUpiViewModelProvider.notifier).selectBackupUpi(item);
              Navigator.of(context).pop(item);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Text(item, style: titleStyle),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'package:get_storage/get_storage.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:kumar_pay/app/toast/app_toast.dart';
import 'package:kumar_pay/app/config/storage_keys.dart';
import 'package:kumar_pay/presentation/viewmodels/home_viewmodel/home_viewmodel.dart';
import 'package:kumar_pay/presentation/viewmodels/mine_viewmodel/mine_viewmodel.dart';
import 'package:kumar_pay/presentation/viewmodels/buy_viewmodel/buy_usdt_viewmodel.dart';
import 'package:kumar_pay/presentation/widgets/common_widgets.dart';
import 'package:kumar_pay/presentation/utils/save_image.dart';
import 'package:kumar_pay/presentation/widgets/hx_button.dart';
import 'package:kumar_pay/presentation/widgets/hx_inkwell_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// USDT 页的 Sliver 组件
class BuyUsdtSliver extends ConsumerStatefulWidget {
  const BuyUsdtSliver({super.key});

  @override
  ConsumerState<BuyUsdtSliver> createState() => _BuyUsdtSliverState();
}

class _BuyUsdtSliverState extends ConsumerState<BuyUsdtSliver> {
  final GlobalKey _qrKey = GlobalKey(); // 截图二维码
  bool _isRefreshing = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(buyUsdtViewModelProvider);
    final vm = ref.read(buyUsdtViewModelProvider.notifier);
    final box = GetStorage();
    final userInfo = box.read(StorageKeys.userInfo);
    String itokenBalanceText = '0';
    if (userInfo is Map) {
      try {
        final map = userInfo.cast<String, dynamic>();
        final raw = map['itoken'];
        if (raw is num) {
          itokenBalanceText = raw.toStringAsFixed(2);
        } else if (raw != null) {
          final v = num.tryParse(raw.toString());
          if (v != null) {
            itokenBalanceText = v.toStringAsFixed(2);
          }
        }
      } catch (_) {}
    }
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                '🇮🇳 I Token',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2024),
                ),
              ),
              const SizedBox(width: 6),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isRefreshing
                      ? null
                      : () async {
                          setState(() => _isRefreshing = true);
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const CommonLoadingView(),
                          );
                          try {
                            await ref
                              .read(mineViewModelProvider.notifier)
                              .refreshUserInfo(context);
                            await ref
                                .read(buyUsdtViewModelProvider.notifier)
                                .refreshUsdtRecords();
                          } finally {
                            if (mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                              setState(() => _isRefreshing = false);
                            }
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          itokenBalanceText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2024),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (_isRefreshing)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF27AE60),
                              ),
                            ),
                          )
                        else
                          const Icon(
                            Icons.refresh,
                            size: 16,
                            color: Color(0xFF27AE60),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 头部
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF27AE60),
                      child: const Text(
                        '₮',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        child: TextField(
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2024),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText:
                                '1 USDT ≈ ${ref.watch(homeViewModelProvider).usdtExchangerate} IToken',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8F9098),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: vm.setInput,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '≈  ${state.approxDisplay} ${state.approxSymbol}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2024),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 0.5, color: Color(0xFFD3D5DD)),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x19FFA300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_objects_outlined,
                        color: Color(0xFFFFA300),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Please enter the value you want buy',
                        style: TextStyle(
                          color: Color(0xFFFFA300),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                // 二维码
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: RepaintBoundary(
                      key: _qrKey,
                      child: QrImageView(
                        data: state.address,
                        version: QrVersions.auto,
                        size: 150,
                        gapless: true,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF1F2024),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF1F2024),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Center(
                  child: Text(
                    'Send Only USDT to this deposit address.',
                    style: TextStyle(
                      color: Color(0xFFFFA300),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 0.5, color: Color(0xFFD3D5DD)),

                // 钱包地址
                _InfoRow(
                  label: 'Wallet Address',
                  value: state.address,
                  trailing: SizedBox(
                    width: 32,
                    height: 32,
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(28),
                      child: HxInkWellButton(
                        child: const Icon(
                          Icons.copy,
                          size: 24,
                          color: Color(0xFF1F2024),
                        ),
                        onButtonPressed: () async {
                          Clipboard.setData(ClipboardData(text: state.address));
                          AppToast.success(context, 'Copied to clipboard');
                        },
                      ),
                    ),
                  ),
                ),

                const Divider(height: 0.5, color: Color(0xFFD3D5DD)),

                // 网络
                _InfoRow(
                  label: 'Network',
                  value: state.network,
                  trailing: const Padding(
                    padding: EdgeInsets.only(right: 3),
                    child: Icon(
                      Icons.public,
                      size: 24,
                      color: Color(0xFF1F2024),
                    ),
                  ),
                ),

                const Divider(height: 0.5, color: Color(0xFFD3D5DD)),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: HxButton(
                        height: 44,
                        color: Color(0xFF8F9098),
                        fontColor: Color(0xFF1F2024),
                        text: 'Save Image',
                        outlined: true,
                        type: HxButtonType.medium,
                        onButtonPressed: () async {
                          await _saveQrImage();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: HxButton(
                        height: 44,
                        color: Theme.of(context).primaryColor,
                        fontColor: Colors.white,
                        text: 'Copy Address',
                        type: HxButtonType.medium,
                        onButtonPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: state.address),
                          );
                          AppToast.success(context, 'Copied to clipboard');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildTitleHeader(
                  context,
                  expanded: state.showHistory,
                  onToggle: vm.toggleHistory,
                ),
                const SizedBox(height: 12),
                if (state.showHistory) ...[
                  _BuyHistoryTable(records: state.records),
                ],
              ],
            ),
          ),
        ),

        // const SizedBox(height: 24),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8F9098),
                  ),
                ),
              ],
            ),

            // const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2024),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),

        if (trailing != null) trailing!,
      ],
    );
  }
}

// 记录模型迁移至 ViewModel 层 BuyRecord

// 保存二维码图片到相册
extension _SaveQrExt on _BuyUsdtSliverState {
  Future<void> _saveQrImage() async {
    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        AppToast.error(context, 'QR not ready yet');
        return;
      }
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      if (kIsWeb) {
        final success = await saveImageBytes(
          pngBytes,
          name: 'kumarPay_usdt_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        if (!context.mounted) return;
        if (success) {
          AppToast.success(context, 'QR saved to download');
        } else {
          AppToast.error(context, 'Save failed');
        }
        return;
      }

      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        quality: 100,
        name: 'kumarPay_usdt_${DateTime.now().millisecondsSinceEpoch}',
      );

      bool success = false;
      String? errorMessage;
      if (result is Map) {
        final isSuccess = result['isSuccess'];
        final filePath = result['filePath'];
        success = isSuccess == true || isSuccess == 1 || isSuccess == 'true';
        if (!success && filePath != null) {
          success = filePath.toString().isNotEmpty;
        }
        errorMessage = result['errorMessage']?.toString();
      } else if (result is bool) {
        success = result;
      } else if (result != null) {
        success = true;
      }

      if (!context.mounted) return;
      if (success) {
        AppToast.success(context, 'QR saved to gallery');
      } else {
        AppToast.error(context, errorMessage ?? 'Save failed');
      }
    } catch (e) {
      if (!context.mounted) return;
      final message = e.toString();
      if (message.toLowerCase().contains('saved to gallery')) {
        AppToast.success(context, 'QR saved to gallery');
        return;
      }
      AppToast.error(context, 'Save failed: $message');
    }
  }
}

class _BuyHistoryTable extends StatelessWidget {
  final List<BuyRecord> records;

  const _BuyHistoryTable({required this.records});

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF8F9098),
      height: 1,
    );
    const cellStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1F2024),
      height: 1.2,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
            child: Row(
              children: const [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Wallet Address', style: headerStyle),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('Receive IToken', style: headerStyle),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Deal Date', style: headerStyle),
                  ),
                ),
              ],
            ),
          ),

          ...records.asMap().entries.map((entry) {
            final index = entry.key;
            final r = entry.value;
            final parts = r.dateTime.split(' ');
            final date = parts.isNotEmpty ? parts[0] : r.dateTime;
            final time = parts.length > 1 ? parts[1] : '';

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(r.amount, style: cellStyle),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(r.receive, style: cellStyle),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                date,
                                style: cellStyle.copyWith(fontSize: 12),
                              ),
                              if (time.isNotEmpty)
                                Text(
                                  time,
                                  style: cellStyle.copyWith(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != records.length - 1)
                  const Divider(height: 0.5, color: Color(0xFFD3D5DD)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

/* 标题 */
Widget _buildTitleHeader(
  BuildContext context, {
  required bool expanded,
  required VoidCallback onToggle,
}) {
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
              'Last 2 Usdt buy',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: onToggle,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Icon(
            expanded ? Icons.expand_less : Icons.expand_more,
            size: 24,
            color: theme.primaryColor,
          ),
        ),
      ],
    ),
  );
}

import 'dart:io' show Platform, exit;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class AppUpdateService {
  AppUpdateService._();

  static final ShorebirdUpdater _updater = ShorebirdUpdater();
  static Future<void>? _ongoingCheck;
  static bool _hasCheckedThisLaunch = false;
  static bool _patchPromptHandled = false;

  static Future<void> ensureChecked(BuildContext context) {
    if (_hasCheckedThisLaunch) return Future.value();
    if (_ongoingCheck != null) return _ongoingCheck!;

    _ongoingCheck = _checkAndPromptPatchUpdate(context);
    return _ongoingCheck!.whenComplete(() {
      _hasCheckedThisLaunch = true;
      _ongoingCheck = null;
    });
  }

  static Future<void> _checkAndPromptPatchUpdate(BuildContext context) async {
    if (!_updater.isAvailable || !context.mounted) return;

    try {
      final status = await _updater.checkForUpdate();
      if (status == UpdateStatus.outdated) {
        await _updater.update();
      }

      final currentPatch = await _updater.readCurrentPatch();
      final nextPatch = await _updater.readNextPatch();
      final hasPendingPatch =
          status == UpdateStatus.restartRequired ||
          (nextPatch != null && nextPatch.number != currentPatch?.number);

      if (!hasPendingPatch || !context.mounted || _patchPromptHandled) return;

      _patchPromptHandled = true;
      await _showPatchReadyDialog(
        context,
        currentPatch: currentPatch,
        nextPatch: nextPatch,
      );
    } catch (e) {
      debugPrint('Shorebird patch check failed: $e');
    }
  }

  static Future<String> getDisplayVersionText() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final versionName = info.version.trim().isEmpty
          ? '--'
          : info.version.trim();
      final buildNumber = info.buildNumber.trim().isEmpty
          ? '--'
          : info.buildNumber.trim();
      final patchLabel = await _getCurrentPatchLabel();
      final label = '_';

      return patchLabel == 'base'
          ? 'v$versionName$label$buildNumber'
          : 'v$versionName$label$buildNumber$label$patchLabel';
    } catch (_) {
      return 'v1.0.0';
    }
  }

  static Future<String> _getCurrentPatchLabel() async {
    if (!_updater.isAvailable) return 'base';

    try {
      final currentPatch = await _updater.readCurrentPatch();
      if (currentPatch == null) return 'base';
      return '${currentPatch.number}';
    } catch (_) {
      return 'patch?';
    }
  }

  static String _formatPatchLabel(Patch? patch) {
    if (patch == null) return 'base';
    return '${patch.number}';
  }

  static Future<void> _showPatchReadyDialog(
    BuildContext context, {
    required Patch? currentPatch,
    required Patch? nextPatch,
  }) async {
    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted) return;

    final currentLabel = _formatPatchLabel(currentPatch);
    final nextLabel = _formatPatchLabel(nextPatch);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Update Ready',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'A new patch has been detected.\n'
            'Current: $currentLabel\n'
            'New: $nextLabel\n\n'
            'A restart is required for it to take effect.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _restartAppForPatch();
              },
              child: const Text('Restart Now'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _restartAppForPatch() async {
    if (Platform.isAndroid) {
      exit(0);
    } else {
      await SystemNavigator.pop();
    }
  }
}

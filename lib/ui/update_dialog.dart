import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../services/update_service.dart';

/// "New update available" prompt. "Install now" downloads in the background and
/// then opens the system installer; "Later" silences this version only.
Future<void> showUpdateDialog(BuildContext context, UpdateService service) async {
  final l10n = AppLocalizations.of(context);
  final update = service.available;
  if (update == null) return;

  final action = await showDialog<_UpdateAction>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.system_update_alt),
      title: Text(l10n.updateAvailableTitle),
      content: Text(l10n.updateAvailableBody(update.versionName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, _UpdateAction.later),
          child: Text(l10n.updateLater),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, _UpdateAction.install),
          child: Text(l10n.updateNow),
        ),
      ],
    ),
  );

  if (action != _UpdateAction.install || !context.mounted) {
    if (action == _UpdateAction.later) await service.skip(update);
    return;
  }
  await runUpdateFlow(context, service, update);
}

/// Downloads, then installs. Progress is a snackbar, not a screen: the download
/// runs in the system DownloadManager and outlives this route.
Future<void> runUpdateFlow(
  BuildContext context,
  UpdateService service,
  AppUpdate update,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);

  if (await service.needsInstallPermission()) {
    await service.requestInstallPermission();
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.msgUpdatePermissionNeeded)));
    return;
  }

  messenger.showSnackBar(SnackBar(content: Text(l10n.updateDownloading)));
  final downloaded = await service.download(update);
  if (!context.mounted) return;

  if (!downloaded) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.msgUpdateFailed)));
    return;
  }
  messenger.showSnackBar(SnackBar(content: Text(l10n.updateInstalling)));
  final installed = await service.install(update);
  // Android restarts the app after a package replace, so there is nothing to
  // clean up here; the flow ends when the installer takes over.
  if (!installed && context.mounted) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.msgUpdateFailed)));
  }
}

enum _UpdateAction { install, later }

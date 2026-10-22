import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../services/update_service.dart';

/// "New update available" prompt. One window does the whole job: it offers the
/// update, shows the download progress in place, then hands the finished APK to
/// the system installer on its own. Nothing else is pushed on top.
///
/// The installer confirmation itself is Android's and cannot be replaced; the
/// app restarts by itself once the package is replaced.
Future<void> showUpdateDialog(BuildContext context, UpdateService service) async {
  final update = service.available;
  if (update == null) return;

  final action = await showDialog<_UpdateAction>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Consumer<UpdateService>(
      builder: (context, service, _) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          icon: const Icon(Icons.system_update_alt),
          title: Text(
            service.downloading
                ? l10n.updateDownloading
                : l10n.updateAvailableTitle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.updateAvailableBody(update.versionName)),
              if (service.downloading) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: service.progress / 100),
                ),
                const SizedBox(height: 10),
                Text(
                  '${service.progress}%',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
          actions: [
            if (service.downloading)
              // Nothing to cancel: DownloadManager has no pause and the dialog
              // must stay put while the bar moves.
              const SizedBox.shrink()
            else ...[
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, _UpdateAction.later),
                child: Text(l10n.updateLater),
              ),
              if (service.isReadyToInstall)
                FilledButton(
                  onPressed: () async {
                    await service.install(update);
                  },
                  child: Text(l10n.updateInstall),
                )
              else
                FilledButton(
                  onPressed: () async {
                    // Stay open: the Consumer above redraws the bar and the
                    // Install button as the state changes.
                    await service.download(update);
                  },
                  child: Text(l10n.updateNow),
                ),
            ],
          ],
        );
      },
    ),
  );

  if (action == _UpdateAction.later) await service.skip(update);
}

enum _UpdateAction { later }

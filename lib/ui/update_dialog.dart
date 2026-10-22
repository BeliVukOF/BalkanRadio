import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../services/update_service.dart';

/// "New update available" prompt. "Install now" starts the download; the same
/// dialog then shows the progress and finally an Install button that hands the
/// finished APK to the system installer. "Later" silences this version only.
Future<void> showUpdateDialog(BuildContext context, UpdateService service) async {
  final update = service.available;
  if (update == null) return;

  final action = await showDialog<_UpdateAction>(
    context: context,
    builder: (dialogContext) => Consumer<UpdateService>(
      builder: (context, service, _) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          icon: const Icon(Icons.system_update_alt),
          title: Text(l10n.updateAvailableTitle),
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
          actions: service.downloading
              ? null
              : service.isReadyToInstall
                  ? [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(l10n.updateLater),
                      ),
                      FilledButton(
                        onPressed: () async {
                          await service.install(update);
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, _UpdateAction.install);
                          }
                        },
                        child: Text(l10n.updateInstall),
                      ),
                    ]
                  : [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, _UpdateAction.later),
                        child: Text(l10n.updateLater),
                      ),
                      FilledButton(
                        onPressed: () async {
                          await service.download(update);
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, _UpdateAction.install);
                          }
                        },
                        child: Text(l10n.updateNow),
                      ),
                    ],
        );
      },
    ),
  );

  if (action == _UpdateAction.later) await service.skip(update);
}

enum _UpdateAction { install, later }

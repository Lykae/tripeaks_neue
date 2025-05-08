import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:tripeaks_rush/l10n/app_localizations.dart';
import 'package:tripeaks_rush/stores/data/layout.dart';
import 'package:tripeaks_rush/stores/session.dart';
import 'package:tripeaks_rush/widgets/selection_dialog.dart';
import 'package:tripeaks_rush/widgets/setting_tile.dart';

class LayoutSetting extends StatelessWidget {
  const LayoutSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<Session>(context);
    final s = AppLocalizations.of(context)!;
    return Observer(
      builder: (context) {
        return SettingTile(
          title: s.layoutControl,
          location: Location.first,
          onTap: () => _showSelection(context, session),
          subtitle: session.layout.label(s),
          showArrow: true,
        );
      },
    );
  }

  Future<void> _showSelection(BuildContext context, Session session) async {
    final s = AppLocalizations.of(context)!;
    final result = await showDialog<int>(
      context: context,
      barrierColor: Colors.transparent,
      builder:
          (context) => SelectionDialog(
            title: s.layoutControl,
            selected: session.layout.index,
            options: Peaks.values.map((e) => e.label(s)).toList(),
          ),
    );
    if (result != null && result >= 0) {
      session.layout = Peaks.values[result];
    }
  }
}

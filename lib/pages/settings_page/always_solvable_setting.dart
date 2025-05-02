import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:tripeaks_neue/l10n/app_localizations.dart';
import 'package:tripeaks_neue/stores/session.dart';
import 'package:tripeaks_neue/widgets/setting_tile.dart';

final class AlwaysSolvableSetting extends StatelessWidget {
  const AlwaysSolvableSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<Session>(context);
    final s = AppLocalizations.of(context)!;
    return Observer(
      builder: (context) {
        return SettingTile(
          title: s.alwaysSolvableControl,
          location: Location.last,
          onTap: () => session.alwaysSolvable = !session.alwaysSolvable,
          subtitle: session.alwaysSolvable ? s.alwaysSolvableOnLabel : s.alwaysSolvableOffLabel,
          trailing: Switch(
            value: session.alwaysSolvable,
            onChanged: (v) => session.alwaysSolvable = v,
            thumbIcon: const WidgetStateProperty.fromMap({
              WidgetState.selected: Icon(Icons.circle_outlined),
              WidgetState.any: Icon(Icons.circle),
            }),
          ),
          showArrow: false,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tripeaks_rush/l10n/app_localizations.dart';
import 'package:tripeaks_rush/stores/data/player_statistics.dart';
import 'package:tripeaks_rush/widgets/group_tile.dart';
import 'package:tripeaks_rush/widgets/list_tile.dart';

final class Summary extends StatelessWidget {
  const Summary(this.statistics, {super.key});

  final Statistics statistics;

  @override
  Widget build(BuildContext context) {
    final trailingStyle = Theme.of(context).textTheme.bodyMedium;
    final s = AppLocalizations.of(context)!;
    return GroupTile(
      children: <Widget>[
        MyListTile(
          title: Text(s.totalPlayedLabel),
          trailing: Text(statistics.totalGames.toString(), style: trailingStyle),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        ),
        MyListTile(
          title: Text(s.totalClearedLabel),
          trailing: Text(statistics.cleared.toString(), style: trailingStyle),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        ),
        MyListTile(
          title: Text(s.bestScoreLabel),
          trailing: Text((statistics.bestGames.firstOrNull?.score ?? 0).toString(), style: trailingStyle),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        ),
        MyListTile(
          title: Text(s.longestChainLabel),
          trailing: Text((statistics.longestChain).toString(), style: trailingStyle),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        ),
      ],
    );
  }
}

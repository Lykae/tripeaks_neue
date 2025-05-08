import 'package:flutter/material.dart';
import 'package:tripeaks_rush/l10n/app_localizations.dart';
import 'package:tripeaks_rush/oss_licenses.dart';
import 'package:tripeaks_rush/pages/info_page/license_dialog.dart';
import 'package:tripeaks_rush/widgets/constants.dart' as c;
import 'package:tripeaks_rush/widgets/external_link.dart';
import 'package:tripeaks_rush/widgets/group_tile.dart';
import 'package:tripeaks_rush/widgets/scroll_indicator.dart';

class Dependencies extends StatelessWidget {
  const Dependencies({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ScrollIndicator(
      child: DefaultTextStyle(
        style: textTheme.bodyMedium!.copyWith(height: 1.8),
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(
            c.cardPaddingHorizontal,
            0,
            c.cardPaddingHorizontal,
            c.cardPaddingVertical,
          ),
          itemCount: _extendedDependencies.length,
          itemBuilder:
              (context, index) => DependencyEntry(
                package: _extendedDependencies[index],
                isDirectDependency: _directDependencies.contains(_extendedDependencies[index].name),
              ),
          separatorBuilder: (context, index) => const GroupTileDivider(padding: EdgeInsets.zero),
        ),
      ),
    );
  }

  static final _extendedDependencies =
      allDependencies.where((it) => !it.isSdk || it.name == "flutter").toList();

  static final _directDependencies = (dependencies + devDependencies).map((it) => it.name).toSet();
}

final class DependencyEntry extends StatelessWidget {
  const DependencyEntry({super.key, required this.package, required this.isDirectDependency});

  final Package package;
  final bool isDirectDependency;

  @override
  Widget build(BuildContext context) {
    final link = package.homepage ?? package.repository;
    final s = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Text(package.name),
            Spacer(),
            DependencyStatusChip(isDirectDependency),
            if (package.license != null)
              FilledButton.tonal(onPressed: () => _showLicense(context), child: Text(s.showLicenseAction)),
          ],
        ),
        if (link != null) ExternalLink(uri: Uri.dataFromString(link)),
      ],
    );
  }

  void _showLicense(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => LicenseDialog(package: package),
    );
  }
}

class DependencyStatusChip extends StatelessWidget {
  const DependencyStatusChip(this.isDirectDependency, {super.key});

  final bool isDirectDependency;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final text = isDirectDependency ? s.directDependencyLabel : s.indirectDependencyLabel;
    return Text(text, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary));
  }
}

import 'package:tripeaks_neue/stores/data/back_options.dart';
import 'package:tripeaks_neue/stores/game.dart';
import 'package:tripeaks_neue/pages/home_page/widgets/cards.dart';
import 'package:tripeaks_neue/widgets/constants.dart' as c;
import 'package:flutter/material.dart';

class LandscapeBoard extends StatelessWidget {
  const LandscapeBoard({super.key, required this.game, required this.back, required this.scale});

  final Game game;
  final double scale;
  final BackOptions back;

  Stream<String> get rushTimerStream async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: 200));
      yield getRushTimer();
    }
  }

  Stream<String> get rushScoreStream async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: 200));
      yield getRushScore();
    }
  }

  String getRushTimer() {
    return game.rushInfo == null ? "" : "TIME: ${game.rushInfo?.rushTimer}s";
  }

  String getRushScore() {
    return game.rushInfo == null ? "" : "SCORE: ${game.score}";
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = c.cardSize + c.cellPadding;
    final quarter = cellSize / 2.0;
    final rowShift = quarter;
    final width = quarter * game.layout.width;
    final height = rowShift * game.layout.height;
    return Column(
      children: [ Column(mainAxisSize: MainAxisSize.min,
        children: [StreamBuilder<String>(
              stream: rushScoreStream,
              builder: (context, snapshot) {
                return Flexible(child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Text(snapshot.data ?? "", style: TextStyle(fontFamily: "Outfit", fontSize: 24),),
                ));
              },
            ),
            StreamBuilder<String>(
              stream: rushTimerStream,
              builder: (context, snapshot) {
                return Flexible(child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Text(snapshot.data ?? "", style: TextStyle(fontFamily: "Outfit", fontSize: 24),),
                ));
              },
            ),
            ],
      ),
      Expanded(child: Center(child: SizedBox(
      width: (width * scale).floorToDouble(),
      height: (height * scale).floorToDouble(),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              for (final tile in game.board)
                Positioned(
                  left: tile.pin.crossAxis * quarter,
                  top: tile.pin.mainAxis * rowShift,
                  child: TileCard(tile, back: back, orientation: Orientation.landscape),
                ),
            ],
          ),
        ),
      ))),
    )]);
  }
}

class PortraitBoard extends StatelessWidget {
  const PortraitBoard({super.key, required this.game, required this.back, required this.scale});

  final Game game;
  final double scale;
  final BackOptions back;

  Stream<String> get rushTimerStream async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: 200));
      yield getRushTimer();
    }
  }

  Stream<String> get rushScoreStream async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: 200));
      yield getRushScore();
    }
  }

  String getRushTimer() {
    return game.rushInfo == null ? "" : "TIME: ${game.rushInfo?.rushTimer}s";
  }

  String getRushScore() {
    return game.rushInfo == null ? "" : "SCORE: ${game.score}";
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = c.cardSize + c.cellPadding;
    final quarter = cellSize / 2.0;
    final width = quarter * game.layout.height;
    final height = quarter * game.layout.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [ Column(mainAxisSize: MainAxisSize.min,
        children: [StreamBuilder<String>(
              stream: rushScoreStream,
              builder: (context, snapshot) {
                return FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Text(snapshot.data ?? "", style: TextStyle(fontFamily: "Outfit", fontSize: 18),),
                );
              },
            ),
            StreamBuilder<String>(
              stream: rushTimerStream,
              builder: (context, snapshot) {
                return FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Text(snapshot.data ?? "", style: TextStyle(fontFamily: "Outfit", fontSize: 18),),
                );
              },
            ),
            ],), 
            Center(child: SizedBox(
      width: (width * scale).floorToDouble(),
      height: (height * scale).floorToDouble(),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              for (final tile in game.board)
                Positioned(
                  top: tile.pin.crossAxis * quarter,
                  left: tile.pin.mainAxis * quarter,
                  child: TileCard(tile, back: back, orientation: Orientation.portrait),
                ),
            ],
          ),
        ),
      ),
    ))]);
  }
}

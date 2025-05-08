import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:tripeaks_neue/stores/data/card_value.dart';
import 'package:tripeaks_neue/stores/data/layout.dart';
import 'package:tripeaks_neue/stores/data/player_statistics.dart';
import 'package:tripeaks_neue/stores/data/single_game_statistics.dart';
import 'package:tripeaks_neue/stores/game.dart';
import 'package:tripeaks_neue/util/get_io.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:tripeaks_neue/util/local_io.dart'
    // ignore: uri_does_not_exist
    if (dart.library.js_util) 'package:tripeaks_neue/util/web_io.dart';

part "session.g.dart";

// ignore: library_private_types_in_public_api
class Session extends _Session with _$Session {
  // ignore: use_super_parameters
  Session(
    Game game,
    Peaks layout, {
    bool startEmpty = false,
    bool alwaysSolvable = true,
    bool showAll = false,
    required PlayerStatistics statistics,
  }) : super(game, layout, startEmpty: startEmpty, alwaysSolvable: alwaysSolvable, showAll: showAll, statistics: statistics);

  factory Session.fresh() {
    final layout = Peaks.threePeaks;
    final startEmpty = false;
    final alwaysSolvable = true;
    final game = _Session._makeRandomGame(layout, startEmpty, alwaysSolvable);
    return Session(game, layout, startEmpty: startEmpty, alwaysSolvable: alwaysSolvable, statistics: PlayerStatistics.empty());
  }

  static Future<Session> read() async {
    final io = getIO();
    final sessionData = await io.read("session", _SessionData.fromJsonObject) ?? _SessionData.fresh();
    final game =
        await io.read("game", Game.fromJsonObject) ??
        _Session._makeRandomGame(sessionData.layout, sessionData.startEmpty, sessionData.alwaysSolvable);
    final statistics =
        await io.read("statistics", PlayerStatistics.fromJsonObject) ?? PlayerStatistics.empty();
    return Session(
      game,
      sessionData.layout,
      startEmpty: sessionData.startEmpty,
      alwaysSolvable: sessionData.alwaysSolvable,
      showAll: sessionData.showAll,
      statistics: statistics,
    );
  }

  Future<void> write() async {
    final io = getIO();
    await io.write("session", _SessionData.of(this).toJsonObject());
    await io.write("game", _game.toJsonObject());
    await io.write("statistics", _statistics.toJsonObject());
  }
}

abstract class _Session with Store {
  _Session(
    Game game,
    this.layout, {
    required PlayerStatistics statistics,
    this.startEmpty = false,
    this.alwaysSolvable = true,
    this.showAll = true,
  }) : _statistics = statistics,
       _game = game {
    whenCleared = when((_) => _game.isCleared, () {
      if (game.rushInfo == null) {
        if (game.isPlayed && !game.statisticsPushed) {
          game.statisticsPushed = true;
          _statistics = _statistics.withGame(SingleGameStatistics.of(game));
        }
      }
    });
  }

  @readonly
  Game _game;

  @readonly
  Peaks layout;

  @readonly
  bool startEmpty;

  @readonly
  bool alwaysSolvable;

  @readonly
  bool showAll;

  @readonly
  PlayerStatistics _statistics;

  ReactionDisposer? whenCleared;

  @action
  void newGame(Future<void> Function() callback) {
    final next = _makeRandomGame(layout, startEmpty, alwaysSolvable);
    for (final tile in next.board) {
      tile.hide();
    }

    if (!_game.isCleared && _game.isPlayed) {
      _game.forfeit();
      _statistics = _statistics.withGame(SingleGameStatistics.of(_game));
      whenCleared?.reaction.dispose();
    }

    if (kIsWasm || kIsWeb) {
      writeStatistics();
    }

    whenCleared = when((_) => next.isCleared, () {
      if (next.isPlayed) {
        next.statisticsPushed = true;
        _statistics = _statistics.withGame(SingleGameStatistics.of(next));
        writeStatistics();
      }
    });
    _game = next;
    _setupBoard(next, callback);
  }

  @action
  void newRushGame(Future<void> Function() callback, RushInfo? rushInfo) {
    rushInfo ??= RushInfo.fresh();
    print("bread: " + rushInfo.toString());
    final next = _makeRushGame(rushInfo);
    for (final tile in next.board) {
      tile.hide();
    }

    if (!_game.isCleared && _game.isPlayed) {
      _game.forfeit();
      _statistics = _statistics.withGame(SingleGameStatistics.of(_game));
      whenCleared?.reaction.dispose();
    }

    if (kIsWasm || kIsWeb) {
      writeStatistics();
    }

    whenCleared = when((_) => next.isCleared, () {
      final nextInfo = next.rushInfo;
      if (nextInfo != null) {
        if (nextInfo.rushTimer > 0) {
          newRushGame(callback, nextInfo);
          print("new game, current score: " + nextInfo.rushScore.toString());
        }
      }
    });
    _game = next;
    _setupBoard(next, callback);
  }

  @action
  void restart(Future<void> Function() callback) {
    final next = _game.rebuild();
    for (final tile in next.board) {
      tile.hide();
    }

    if (!_game.isCleared && _game.isPlayed && !_game.statisticsPushed) {
      _statistics = _statistics.withGame(SingleGameStatistics.of(_game));
      whenCleared?.reaction.dispose();
    }

    whenCleared = when((_) => next.isCleared, () {
      if (next.isPlayed && !next.statisticsPushed) {
        next.statisticsPushed = true;
        _statistics = _statistics.withGame(SingleGameStatistics.of(next));
        writeStatistics();
      }
    });

    _game = next;
    _setupBoard(next, callback);
  }

  Future<void> writeStatistics() async {
    await getIO().write("statistics", _statistics.toJsonObject());
    return;
  }

  static Game _makeRandomGame(Peaks layout, bool startEmpty, bool alwaysSolvable) {
    final layoutObj = layout.implementation;

    Game make() {
      final deck = getDeck()..shuffle();
      return Game.usingDeck(deck, layout: layoutObj, startsEmpty: startEmpty, alwaysSolvable: alwaysSolvable);
    }

    for (var i = 0; i < 10; i++) {
      final game = make();
      if (!game.isEnded) {
        return game;
      }
    }

    return make();
  }

  static Game _makeRushGame(RushInfo rushInfo) {
    final layoutObj = _pickRandomLayout().implementation;

    Game make() {
      final deck = getDeck()..shuffle();
      return Game.usingDeck(deck, layout: layoutObj, startsEmpty: false, alwaysSolvable: true, rushInfo: rushInfo);
    }

    for (var i = 0; i < 10; i++) {
      final game = make();
      if (!game.isEnded) {
        return game;
      }
    }

    return make();
  }

  static Peaks _pickRandomLayout() {
    final rng = Random();
    return Peaks.values[rng.nextInt(Peaks.values.length)];
  }

  void _setupBoard(Game next, Future<void> Function() callback) async {
    for (final tile in _game.board) {
      tile.show();
      await Future.delayed(_addAnimDelay);
    }
    await callback();
  }

  static const Duration _addAnimDelay = Duration(milliseconds: 8);
}

final class _SessionData {
  _SessionData({required this.layout, required this.startEmpty, required this.alwaysSolvable, required this.showAll});

  final Peaks layout;
  final bool startEmpty;
  final bool alwaysSolvable;
  final bool showAll;

  _SessionData.fresh() : this(layout: Peaks.threePeaks, startEmpty: false, alwaysSolvable: true, showAll: true);

  _SessionData.fromJsonObject(Map<String, dynamic> jsonObject)
    : layout = Peaks.values[jsonObject["layout"]],
      startEmpty = jsonObject["startEmpty"],
      alwaysSolvable = jsonObject["alwaysSolvable"],
      showAll = jsonObject["showAll"];

  _SessionData.of(Session session)
    : this(layout: session.layout, startEmpty: session.startEmpty, alwaysSolvable: session.alwaysSolvable, showAll: session.showAll);

  Map<String, dynamic> toJsonObject() => <String, dynamic>{
    //"layout": layout.index,
    //"startEmpty": startEmpty,
    //"alwaysSolvable": alwaysSolvable,
    //"showAll": showAll,
  };
}
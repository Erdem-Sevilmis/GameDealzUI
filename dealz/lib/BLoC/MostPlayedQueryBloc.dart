import 'dart:async';
import 'dart:convert';
import 'package:dealz/BLoC/BLoC.dart';
import 'package:dealz/Data/Game.dart';
import 'package:rxdart/rxdart.dart';

import 'package:http/http.dart' as http;

import '../main.dart';

class MostPlayedQueryBloc implements Bloc {
  final StreamController<List<Game>> _controller =
  new BehaviorSubject<List<Game>>();

  Stream<List<Game>> get MostPlayedGameStream => _controller.stream;

  void GetMostPlayed() async {
    var response =
    await http.get(GameDealz.URL+"/mostplayed");
    String stringResult = response.body;
    if (response.statusCode == 200) {
      var result = jsonDecode(stringResult);
      List<Game> mostPlayedGames = <Game>[];

      for (var game in result) {
        var currGame= new Game(game["title"], game["price"], game["jpg"], game["url"], null);
        mostPlayedGames.add(currGame);
      }
      _controller.add(mostPlayedGames);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}

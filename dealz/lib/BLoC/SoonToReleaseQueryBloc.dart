import 'dart:async';
import 'dart:convert';
import 'package:dealz/BLoC/BLoC.dart';
import 'package:dealz/Data/Game.dart';
import 'package:rxdart/rxdart.dart';

import 'package:http/http.dart' as http;

import '../main.dart';

class SoonToReleaseQueryBloc implements Bloc {
  final StreamController<List<Game>> _controller =
  new BehaviorSubject<List<Game>>();

  Stream<List<Game>> get SoonToReleaseGameStream => _controller.stream;

  void GetSoonToReleaseGames() async {
    var response =
    await http.get(GameDealz.URL+"/soon");
    String stringResult = response.body;
    if (response.statusCode == 200) {
      var result = jsonDecode(stringResult);
      List<Game> soonGames = <Game>[];

      for (var game in result) {
        var currGame= new Game(game["title"], game["price"], game["jpg"], game["url"], null);
        soonGames.add(currGame);
      }
      _controller.add(soonGames);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}

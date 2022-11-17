import 'dart:async';
import 'dart:convert';
import 'package:dealz/BLoC/BLoC.dart';
import 'package:dealz/Data/Game.dart';
import 'package:rxdart/rxdart.dart';

import 'package:http/http.dart' as http;

import '../main.dart';

class GameQueryBloc implements Bloc {
  final StreamController<List<Game>> _controller =
      new BehaviorSubject<List<Game>>();

  Stream<List<Game>> get gameStream => _controller.stream;

  void getGame(String title,
      {int minPrice, int maxPrice, int minYear, int maxYear}) async {
    var response = await http.get(
        GameDealz.URL+"/games?title=${title ?? ""}&minPrice=${minPrice ?? ""}&maxPrice=${maxPrice ?? ""}&minYear=${minYear ?? ""}&maxYear=${maxYear ?? ""}");
    String stringResult = response.body;

    if (response.statusCode == 200) {
      List<dynamic> result = jsonDecode(stringResult);
      List<Game> games = <Game>[];
      for (Map<String, dynamic> map in result) {
        var game = new Game(
            map["title"], map["price"]==null? 0:map["price"], map["jpg"], map["url"],int.parse(map["id"]));
        games.add(game);
      }
      _controller.add(games);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }


}

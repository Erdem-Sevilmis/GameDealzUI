import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:dealz/BLoC/BLoC.dart';
import 'package:dealz/Data/Game.dart';
import 'package:dealz/main.dart';
import 'package:rxdart/rxdart.dart';

import 'package:http/http.dart' as http;

class TopGameQueryBloc implements Bloc {
  final StreamController<List<Game>> _controller =
  new BehaviorSubject<List<Game>>();

  Stream<List<Game>> get Top25GameStream => _controller.stream;

  void GetTop25() async {
    var response =
    await http.get("${GameDealz.URL}top25");
    String stringResult = response.body;
    if (response.statusCode == 200) {
      var result = jsonDecode(stringResult);
      List<Game> top25Games = <Game>[];

      for (var game in result) {
        var currGame= new Game(game["title"], game["price"], game["jpg"], game["url"], null);
       top25Games.add(currGame);
      }
      _controller.add(top25Games);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}

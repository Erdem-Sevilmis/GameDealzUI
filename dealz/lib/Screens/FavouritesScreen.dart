import 'dart:collection';
import 'dart:convert';
import 'package:dealz/Data/Game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'GameScreen.dart';

class Favorites extends StatelessWidget {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> _getToken() async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.getString("Token"));
  }

  Future<void> removeGame(String title) async {
    var token = await _getToken();
    var headers = {
      "Authorization": "Bearer $token",
      "title": title,
    };
    http.Response result = await http
        .delete(GameDealz.URL+"/game", headers: headers);
  }

  Future<Game> getGame(String title) async {
    if (title != null) {
      var response = await http
          .get(GameDealz.URL+"/games?title=" + title);

      var result = json.decode(response.body);
      if (response.statusCode != 200) {
        return result["msg"];
      }
      for (Map<String, dynamic> map in result) {
        var game = new Game(
            map["title"],
            map["price"] == null ? 0 : map["price"],
            map["jpg"],
            map["url"],
            int.parse(map["id"]));
        return game;
      }
    }
  }

  Future<List<Game>> getAllFavourites() async {
    List<Game> favourites = <Game>[];
    var token = await _getToken();

    var headers = {
      "Authorization": "Bearer $token",
    };
    var result = await http.get(
        GameDealz.URL+"/user/getallfavourites",
        headers: headers);
    LinkedHashMap stringResult = json.decode(result.body);
    if (result.statusCode != 200 || stringResult["success"] == false) {
      return stringResult["msg"];
    }
    var favouritesNames = stringResult["favourites"];
    for (var name in favouritesNames) {
      Game game = await getGame(name);
      if (game != null) {
        favourites.add(game);
      }
    }
    return favourites;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        actions: [
          IconButton(
              onPressed: () {
                _prefs.then((value) => value.clear());
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      "Logged out.",
                      style: TextStyle(color: Colors.white),
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.black));
                Navigator.pop(context);
              },
              icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: FutureBuilder(
        future: getAllFavourites(),
        builder: (BuildContext context, AsyncSnapshot<List<Game>> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              break;
            case ConnectionState.done:
              if (snapshot.data.length == 0) {
                return Center(
                  child: Text(
                    "No favourites added.",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                );
              }
              return ListView(
                  children: snapshot.data
                      .map((game) => ListTile(
                            leading: SizedBox(
                                height: 80,
                                width: 80,
                                child: Image.network(game.jpg)),
                            title: Text(
                              game.name,
                              style: TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(
                                game.price == null
                                    ? "Na"
                                    : game.price.toString() == "0"
                                        ? "Free"
                                        : '${game.price.toString()}€',
                                style: TextStyle(fontSize: 20)),
                            trailing: IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            game.name + " has been deleted.",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        duration: const Duration(seconds: 1),
                                        backgroundColor: Colors.black));
                                removeGame(game.name).then((value) =>
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Favorites())));
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GamePage(game)));
                            },
                          ))
                      .toList());

            case ConnectionState.none:
              break;
          }
          return null;
        },
      ),
    );
  }
}

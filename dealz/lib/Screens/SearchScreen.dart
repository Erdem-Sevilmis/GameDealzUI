import 'dart:convert';

import '../Data/Game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dealz/BLoC/BlocProvider.dart';
import 'package:dealz/BLoC/GameQueryBloc.dart';

import '../main.dart';
import 'GameScreen.dart';

class Search extends SearchDelegate<Game> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () async {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    GameQueryBloc bloc = BlocProvider.of<GameQueryBloc>(context);
    bloc.getGame(query);
    return Scaffold(
      body: Form(
        child: Container(
          child: StreamBuilder<List<Game>>(
              stream: bloc.gameStream,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Game>> snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
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
                          trailing: FavoriteWidget(game.name),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        GamePage(game)));
                          },
                        ))
                            .toList());
                  case ConnectionState.done:
                    return Text('${snapshot.data} (closed)');

                  case ConnectionState.none:
                    break;
                }

                return null;
              }),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}


import '../Data/Game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dealz/Data/KeySite.dart';
import 'package:dealz/BLoC/BlocProvider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dealz/BLoC/KeySiteQueryBloc.dart';


class GamePage extends StatelessWidget {
  final Game game;

  GamePage(this.game);

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Not valid URL: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    KeySiteQueryBloc bloc = BlocProvider.of<KeySiteQueryBloc>(context);

    if (game.id == null) {
      bloc.GetInfo(game.url);
    } else {
      bloc.GetInfo(game.id);
    }

    return Scaffold(
      appBar: AppBar(title: Text(game.name)),
      body: Center(
        child: Container(
          child: StreamBuilder<List<KeySite>>(
              stream: bloc.keySiteStream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<KeySite>> snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                /*
                  Screen wird aufgerufen -> waiting
                  Daten sind ready -> active

                  screen wird geschlossen

                  Screen wird aufgerufen -> waiting (daten vom voherigen game werden dagestellt)
                  Daten sind ready -> active (daten werden übserchrieben und sind nun richtig)

                  !Der loading screen wird beim 2 fall nicht dargestellt!
                 */
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
                    return ListView(
                        children: snapshot.data
                            .map((keySite) => ListTile(
                          leading: SizedBox(
                              height: 75,
                              width: 75,
                              child: SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: Image.network(keySite.jpg))),
                          title: Text(
                            keySite.name,
                            style: TextStyle(
                                color: keySite.stock == "true"
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(keySite.price == null
                              ? "Na"
                              : keySite.price.toString() == "0"
                              ? "Free"
                              : '${keySite.price.toString()}€'),
                          onTap: () {
                            _launchInBrowser(keySite.affiliateUrl);
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
}
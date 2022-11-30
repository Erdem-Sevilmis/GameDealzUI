import 'dart:convert';
import 'Data/Game.dart';
import 'Screens/GameScreen.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/SearchScreen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'Screens/FavouritesScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:dealz/BLoC/BlocProvider.dart';
import 'package:dealz/BLoC/GameQueryBloc.dart';
import 'package:dealz/BLoC/KeySiteQueryBloc.dart';
import 'package:dealz/BLoC/TopGameQueryBloc.dart';
import 'package:dealz/BLoC/MostPlayedQueryBloc.dart';
import 'package:dealz/BLoC/SoonToReleaseQueryBloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new GameDealz());
  });
}

class GameDealz extends StatelessWidget {
  static const String URL="http://10.0.2.2:3000/api/";
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SoonToReleaseQueryBloc>(
        bloc: SoonToReleaseQueryBloc(),
        child: BlocProvider<MostPlayedQueryBloc>(
            bloc: MostPlayedQueryBloc(),
            child: BlocProvider<TopGameQueryBloc>(
                bloc: TopGameQueryBloc(),
                child: BlocProvider<KeySiteQueryBloc>(
                    bloc: KeySiteQueryBloc(),
                    child: BlocProvider<GameQueryBloc>(
                        bloc: GameQueryBloc(),
                        child: MaterialApp(
                          title: "Dealz",
                          theme: ThemeData(
                              brightness: Brightness.dark,
                              accentColor: Colors.grey,
                              colorScheme: ColorScheme.dark(
                                  primary: Colors.black,
                                  secondary: Colors.grey)),
                          home: DefaultTabController(
                            length: 3,
                            child: HomePage(),
                          ),
                        ))))));
  }
}

class FavoriteWidget extends StatefulWidget {
  String title;

  FavoriteWidget(this.title);

  @override
  _FavoriteState createState() => _FavoriteState(title);
}

class _FavoriteState extends State<FavoriteWidget> {
  bool _isFavorited = false;
  String title;

  _FavoriteState(this.title);

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> _getToken() async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.getString("Token"));
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          String mssg = await _toggleFavorite();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(mssg, style: TextStyle(color: Colors.white)),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.black));
        },
        icon: _isFavorited
            ? Icon(
                Icons.star,
                color: Colors.yellow,
              )
            : Icon(
                Icons.star_border_outlined,
                color: Colors.white,
              ));
  }

  Future<String> _toggleFavorite() async {
    var value = await _getToken();
    if (value != null) {
      var headers = {
        "Authorization": "Bearer $value",
        "title": title,
      };
      http.Response result;
      if (_isFavorited) {
        result = await http.delete(GameDealz.URL+"/game",
            headers: headers);
        setState(() {
          _isFavorited = false;
        });
        return title + " is not in favourites anymore.";
      } else {
        result = await http.post(GameDealz.URL+"/game",
            headers: headers);
        setState(() {
          _isFavorited = true;
        });
        return title + " has been added to your favourites.";
      }
      var stringResult = json.decode(result.body);
      if (result.statusCode != 201 || stringResult["success"] == false) {
        return stringResult["msg"];
      }
    }
    return "You have to be logged in.";
  }
}

class HomePage extends StatelessWidget {
  final String title = "GameDealz";

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> _getToken() async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.getString("Token"));
  }

  @override
  Widget build(BuildContext context) {
    TopGameQueryBloc blocTop25 = BlocProvider.of<TopGameQueryBloc>(context);
    MostPlayedQueryBloc blocMostPlayed =
        BlocProvider.of<MostPlayedQueryBloc>(context);
    SoonToReleaseQueryBloc blocSoonToRelease =
        BlocProvider.of<SoonToReleaseQueryBloc>(context);

    blocTop25.GetTop25();
    blocMostPlayed.GetMostPlayed();
    blocSoonToRelease.GetSoonToReleaseGames();

    var top25Grid = Center(
      child: StreamBuilder<List<Game>>(
          stream: blocTop25.Top25GameStream,
          builder: (BuildContext context, AsyncSnapshot<List<Game>> snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
                return Container(
                    child: GridView.count(
                        padding: EdgeInsets.all(10),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                      for (var game in snapshot.data)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GamePage(game)));
                          },
                          child: Container(
                            decoration: game.jpg != null
                                ? BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(game.jpg),
                                        colorFilter: new ColorFilter.mode(
                                            Colors.black.withOpacity(0.6),
                                            BlendMode.dstATop),
                                        fit: BoxFit.fill))
                                : BoxDecoration(),
                            child: Stack(
                              children: [
                                Align(
                                    alignment: Alignment.topRight,
                                    child: FavoriteWidget(game.name)),
                                Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 200),
                                    child: Container(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          game.name,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        )),
                                  ),
                                ),
                                Container(
                                    alignment: Alignment.bottomCenter,
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: Text(
                                      game.price == null
                                          ? "Na"
                                          : game.price.toString() == "0"
                                              ? "Free"
                                              : '${game.price.toString()}€',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    )),
                              ],
                            ),
                          ),
                        ),
                    ]));

              case ConnectionState.done:
                return Text('${snapshot.data} (closed)');

              case ConnectionState.none:
                break;
            }

            return null;
          }),
    );

    var mostPlayedGrid = Center(
      child: StreamBuilder<List<Game>>(
          stream: blocMostPlayed.MostPlayedGameStream,
          builder: (BuildContext context, AsyncSnapshot<List<Game>> snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
                return Container(
                    child: GridView.count(
                        padding: EdgeInsets.all(10),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                      for (var game in snapshot.data)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GamePage(game)));
                          },
                          child: Container(
                            decoration: game.jpg != null
                                ? BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(game.jpg),
                                    colorFilter: new ColorFilter.mode(
                                        Colors.black.withOpacity(0.6),
                                        BlendMode.dstATop),
                                    fit: BoxFit.fill))
                                : BoxDecoration(),
                            child: Stack(
                              children: [
                                Align(
                                    alignment: Alignment.topRight,
                                    child: FavoriteWidget(game.name)),
                                Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 200),
                                    child: Container(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          game.name,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        )),
                                  ),
                                ),
                                Container(
                                    alignment: Alignment.bottomCenter,
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: Text(
                                      game.price == null
                                          ? "Na"
                                          : game.price.toString() == "0"
                                              ? "Free"
                                              : '${game.price.toString()}€',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    )),
                              ],
                            ),
                          ),
                        ),
                    ]));
              case ConnectionState.done:
                return Text('${snapshot.data} (closed)');

              case ConnectionState.none:
                break;
            }

            return null;
          }),
    );

    var soonToReleaseGrid = Center(
      child: StreamBuilder<List<Game>>(
          stream: blocSoonToRelease.SoonToReleaseGameStream,
          builder: (BuildContext context, AsyncSnapshot<List<Game>> snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
                var starColor = Colors.white;
                return Container(
                    child: GridView.count(
                        padding: EdgeInsets.all(10),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                      for (var game in snapshot.data)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GamePage(game)));
                          },
                          child: Container(
                            decoration: game.jpg != null
                                ? BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(game.jpg),
                                    colorFilter: new ColorFilter.mode(
                                        Colors.black.withOpacity(0.6),
                                        BlendMode.dstATop),
                                    fit: BoxFit.fill))
                                : BoxDecoration(),
                            child: Stack(
                              children: [
                                Align(
                                    alignment: Alignment.topRight,
                                    child: FavoriteWidget(game.name)),
                                Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 200),
                                    child: Container(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          game.name,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        )),
                                  ),
                                ),
                                Container(
                                    alignment: Alignment.bottomCenter,
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: Text(
                                      game.price == null
                                          ? "Na"
                                          : game.price.toString() == "0"
                                              ? "Free"
                                              : '${game.price.toString()}€',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    )),
                              ],
                            ),
                          ),
                        ),
                    ]));

              case ConnectionState.done:
                return Text('${snapshot.data} (closed)');

              case ConnectionState.none:
                break;
            }

            return null;
          }),
    );

    return Scaffold(
        appBar: AppBar(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onSurface: Colors.transparent,
                          shadowColor: Colors.transparent),
                      onPressed: () {
                        _getToken().then((value) {
                          if (value == null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Favorites()));
                          }
                        });
                      },
                      child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Image.asset("Assets/Images/DealZ_Icon.png"))),
                  Center(
                    child: Text(
                      title,
                      style: TextStyle(
                          fontFamily: "PublicSecretFont",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 25),
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        showSearch(context: context, delegate: Search());
                      }),
                ]),
            bottom: TabBar(
              tabs: [
                Tab(text: "Top 25"),
                Tab(text: "Most played"),
                Tab(text: "Soon to be released")
              ],
            )),
        body: TabBarView(
          children: [top25Grid, mostPlayedGrid, soonToReleaseGrid],
        ));
  }
}

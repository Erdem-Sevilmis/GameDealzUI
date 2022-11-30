import 'dart:async';
import 'dart:convert';
import 'package:dealz/BLoC/BLoC.dart';
import 'package:dealz/Data/KeySite.dart';
import 'package:dealz/main.dart';
import 'package:rxdart/rxdart.dart';

import 'package:http/http.dart' as http;

class KeySiteQueryBloc implements Bloc {
  final StreamController<List<KeySite>> _controller =
      new BehaviorSubject<List<KeySite>>();

  Stream<List<KeySite>> get keySiteStream => _controller.stream;

  void GetInfo(dynamic idOrUrl) async {
    var response;
    if (idOrUrl is String) {
      response =
      await http.get(GameDealz.URL+"/infourl?url=$idOrUrl");
    } else if (idOrUrl is int) {
     response =
        await http.get(GameDealz.URL+"info?id=$idOrUrl");
    }
    String stringResult = response.body;
    if (response.statusCode == 200) {
      var result = jsonDecode(stringResult);
      List<KeySite> keySites = <KeySite>[];

      for (var keysite in result) {
        var currKeySite = new KeySite(keysite["price"],keysite["jpg"],keysite["merchant"],keysite["region"],keysite["platform"],keysite["affiliateUrl"], keysite["isActive"].toString(),keysite["stock"].toString());
        keySites.add(currKeySite);
      }
      _controller.add(keySites);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}

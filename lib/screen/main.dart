import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:odpt/view/main_tour.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class Main extends StatefulWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  final referenceUser = FirebaseDatabase.instance.reference().child('user');
  final referencePoi = FirebaseDatabase.instance.reference().child('poi');

  Location _location = new Location();

  var tourList1 = <Widget>[
    Column(
      children: <Widget>[
        Image.asset("images/arrow_down.png", fit: BoxFit.none),
        Text("Pull to Search",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ))
      ],
    )
  ];
  var tourList2 = <Widget>[
    Column(
      children: <Widget>[
        Image.asset("images/arrow_down.png", fit: BoxFit.none),
        Text("Pull to Search",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ))
      ],
    )
  ];
  List<String> photoList1 = [];
  List<String> photoList2 = [];

  var latitude = 35.6813067;
  var longitude = 139.7539624;

  getLocation() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      var location = await _location.getLocation;
      print(location.toString());
      print("latitude: " + location['latitude'].toString());
      print("longitude: " + location['longitude'].toString());
      latitude = location['latitude'];
      longitude = location['longitude'];
    } on Exception {}
  }

  @override
  Widget build(BuildContext context) {
    getLocation();
    signInAnonymously();

    var children = [
      ListTile(
        leading: new Icon(Icons.star),
        title: Text("Saved"),
        onTap: () {
          Navigator.of(context).pushNamed("/Saved");
        },
      ),
      ListTile(
        title: Text("What's odpt?"),
        onTap: () {
          launch("https://www.odpt.org/");
        },
      ),
    ];

    return MaterialApp(
      home: DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: new AppBar(
                  title: new Text("Bus Trip"),
                  bottom: TabBar(
                    tabs: <Tab>[
                      Tab(text: "9:00-14:00"),
                      Tab(text: "14:00-19:00"),
                    ],
                  )),
              drawer: Drawer(child: ListView(children: children)),
              body: TabBarView(
                children: <Widget>[
                  RefreshIndicator(
                      onRefresh: _onRefreshMorning,
                      child: Scrollbar(child: ListView(children: tourList1))),
                  RefreshIndicator(
                      onRefresh: _onRefreshAfternoon,
                      child: Scrollbar(child: ListView(children: tourList2))),
                ],
              ))),
    );
  }

  get(int departureTime, int arrivalTime, Completer<List> completer) async {
    var httpClient = new HttpClient();
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    // api request
//    var uri = Uri.https(
//        'www.mocky.io', '/v2/5aa3e162310000f51626e2d5', {});
//    https://bus-trip-planner.herokuapp.com/plan?lat=35.72456923&lon=139.7570725&departure_time=32400&arrival_time=44400&num_trips=5
    var uri = Uri.https('bus-trip-planner.herokuapp.com', '/plan', {
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'departure_time': departureTime.toString(),
      'arrival_time': arrivalTime.toString(),
      'num_trips': "10"
    });
    print("uri: " + uri.toString());
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(UTF8.decoder).join();
    List jsonList = JSON.decode(responseBody);

    if (completer != null) completer.complete(jsonList);
  }

  bool isFirstRunOnMorning = true;

  Future<Null> _onRefreshMorning() {
    Completer<List> completer = new Completer<List>();
    get(32400, 50400, completer);
    return completer.future.then((jsonMap) async {
      setState(() {
        var tourList = <Widget>[];
        if (jsonMap.length > 0) {
          for (var tourItem in jsonMap) {
            var currentPhotoList = <String>[];
            for (var itinerary in tourItem['itinerary']) {
              if (itinerary['place_type'] != "bus_stop") {
                referencePoi
                    .child(itinerary['place_id'])
                    .child("photo_reference")
                    .onValue
                    .listen((Event event) async {
                  var photoReference = event.snapshot.value;
                  if (photoReference != null && photoReference != "") {
                    currentPhotoList.add(photoReference);
                    if (currentPhotoList.length == 4) {
                      tourList.add(ListItem(
                          Uuid().v4(), [tourItem].toList(), currentPhotoList));
                      tourList1 = tourList;
                    }
                  }
                });
              }
            }
          }
        }
        completer = new Completer<List>();
        if (isFirstRunOnMorning) {
          isFirstRunOnMorning = false;
          _onRefreshMorning();
        }
      });
    });
  }

  bool isFirstRunOnAfternoon = true;

  Future<Null> _onRefreshAfternoon() {
    Completer<List> completer = new Completer<List>();
    get(50400, 68400, completer);
    return completer.future.then((jsonMap) async {
      setState(() {
        var tourList = <Widget>[];
        if (jsonMap.length > 0) {
          for (var tourItem in jsonMap) {
            var currentPhotoList = <String>[];
            for (var itinerary in tourItem['itinerary']) {
              if (itinerary['place_type'] != "bus_stop") {
                referencePoi
                    .child(itinerary['place_id'])
                    .child("photo_reference")
                    .onValue
                    .listen((Event event) async {
                  var photoReference = event.snapshot.value;
                  if (photoReference != null && photoReference != "") {
                    currentPhotoList.add(photoReference);
                    if (currentPhotoList.length == 4) {
                      tourList.add(ListItem(
                          Uuid().v4(), [tourItem].toList(), currentPhotoList));
                      tourList2 = tourList;
                    }
                  }
                });
              }
            }
          }
        }
        completer = new Completer<List>();
        if (isFirstRunOnAfternoon) {
          isFirstRunOnAfternoon = false;
          _onRefreshAfternoon();
        }
      });
    });
  }

  Future<String> signInAnonymously() async {
    final FirebaseUser user = await widget._auth.signInAnonymously();
    assert(user != null);
    assert(user.isAnonymous);
    assert(!user.isEmailVerified);
    assert(await user.getIdToken() != null);
    if (Platform.isIOS) {
      // Anonymous auth doesn't show up as a provider on iOS
      assert(user.providerData.isEmpty);
    } else if (Platform.isAndroid) {
      // Anonymous auth does show up as a provider on Android
      assert(user.providerData.length == 1);
      assert(user.providerData[0].providerId == 'firebase');
      assert(user.providerData[0].uid != null);
      assert(user.providerData[0].displayName == null);
      assert(user.providerData[0].photoUrl == null);
      assert(user.providerData[0].email == null);
    }

    final FirebaseUser currentUser = await widget._auth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInAnonymously succeeded: $user';
  }
}

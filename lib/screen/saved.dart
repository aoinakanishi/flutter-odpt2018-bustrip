import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:odpt/view/main_tour.dart';

class Saved extends StatefulWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference referenceUser =
      FirebaseDatabase.instance.reference().child('users');
  final DatabaseReference referencePoi =
      FirebaseDatabase.instance.reference().child('poi');

  @override
  SavedState createState() => SavedState();
}

class SavedState extends State<Saved> {
  var tourList1 = <Widget>[
    Column(
      children: <Widget>[
        Image.asset("images/arrow_down.png", fit: BoxFit.none),
        Text("Pull to Refresh",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ))
      ],
    )
  ];

  @override
  Widget build(BuildContext context) {
    widget.referenceUser.keepSynced(true);
    loadSavedData();
    return MaterialApp(
      home: Scaffold(
        appBar: new AppBar(
          title: new Text("Saved Trip"),
        ),
        body: RefreshIndicator(
            onRefresh: loadSavedData,
            child: Scrollbar(child: ListView(children: tourList1))),
      ),
    );
  }

  var runOnce = false;

  get(Completer<List> completer) async {
    if (runOnce) return;
    runOnce = true;

    List jsonList = [];
    var currentUser = await widget._auth.currentUser();
    if (currentUser == null) {
      return;
    }

    widget.referenceUser.child(currentUser.uid).onValue.forEach((event) {
      Map item = event.snapshot.value;
      if (item != null) {
        jsonList.add(item);
        if (completer != null && completer.isCompleted == false)
          completer.complete(jsonList);
      }
    });
  }

  Completer<List> completer = new Completer<List>();

  Future<Null> loadSavedData() {
    get(completer);
    return completer.future.then((jsonMap) async {
      setState(() {
        var tourList = <Widget>[];
        if (jsonMap.length > 0) {
          jsonMap[0].forEach((uuid, tourItem) {
            var currentPhotoList = <String>[];
            for (var itinerary in tourItem[0]['itinerary']) {
              // 一覧画像に表示するのはPOIのみ
              if (itinerary['place_type'] != "bus_stop") {
                widget.referencePoi
                    .child(itinerary['place_id'])
                    .child("photo_reference")
                    .onValue
                    .listen((Event event) async {
                  var photoReference = event.snapshot.value;
                  if (photoReference != null && photoReference != "") {
                    currentPhotoList.add(photoReference);
                    if (currentPhotoList.length == 4) {
                      tourList.add(ListItem(uuid, tourItem, currentPhotoList));
                      tourList1 = tourList;
                    }
                  }
                });
              }
            }
          });
          completer = new Completer<List>();
        }
      });
    });
  }
}

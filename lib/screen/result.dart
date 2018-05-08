import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:odpt/view/detail_move_type.dart';
import 'package:odpt/view/detail_rating.dart';
import 'package:odpt/view/detail_star.dart';
import 'package:url_launcher/url_launcher.dart';

class Result extends StatefulWidget {
  final DatabaseReference referenceUsers =
      FirebaseDatabase.instance.reference().child('users');
  final DatabaseReference referencePoi =
      FirebaseDatabase.instance.reference().child('poi');
  final DatabaseReference referenceRoutes =
      FirebaseDatabase.instance.reference().child('bus_routes');
  final DatabaseReference referenceStops =
      FirebaseDatabase.instance.reference().child('bus_stops');

  List json;
  String uuid;

  Result(this.uuid, this.json);

  @override
  ResultState createState() => new ResultState();
}

class ResultState extends State<Result> {
  final TextStyle style = TextStyle(
    color: Colors.white,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );

  ListView listView;

  ResultState();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    setState(() {
      var listArray = <Widget>[];
      // TODO Firebase asyncの為、順番が保証されないのをどうにかする
      for (var tourItem in widget.json) {
        for (var itinerary in tourItem['itinerary']) {
          if (itinerary['place_type'] == "bus_stop") {
            widget.referenceStops
                .child(itinerary['place_id'].replaceAll('.', '-'))
                .onValue
                .listen((Event event) {
              var item = event.snapshot.value;
              int hour1 = (itinerary['departure_time'] / 60 / 60).floor();
              int min1 = ((itinerary['departure_time'] - hour1 * 60 * 60) / 60)
                  .floor();
              var time1 = "　[" +
                  hour1.toString().padLeft(2, "0") +
                  ":" +
                  min1.toString().padLeft(2, "0") +
                  "]";

              int hour2 = (itinerary['arrival_time'] / 60 / 60).floor();
              int min2 =
                  ((itinerary['arrival_time'] - hour2 * 60 * 60) / 60).floor();
              var time2 = "　[" +
                  hour2.toString().padLeft(2, "0") +
                  ":" +
                  min2.toString().padLeft(2, "0") +
                  "]";
              if (itinerary['mode'] == 'walk') {
                // タップ時はGoogle Mapsを開く
                listArray.add(GestureDetector(
                    child: ItemMoveType("images/ic_walk.png",
                        "　" + item['dc:title'], time1, time2),
                    onTap: () {
                      launch(
                          'https://www.google.com/maps/dir/?api=1&travelmode=walking&destination=' +
                              itinerary['arrival_location'][0].toString() +
                              ',' +
                              itinerary['arrival_location'][1].toString());
                    }));
              } else if (itinerary['mode'] == 'bus') {
                listArray.add(GestureDetector(
                    child: ItemMoveType("images/ic_bus.png",
                        "　" + item['dc:title'], time1, time2),
                    onTap: () {
                      launch(item['odpt:busLocationURL'][0]);
                    }));
              }
              listView = ListView(children: listArray);
            });
          } else {
            widget.referencePoi
                .child(itinerary['place_id'])
                .onValue
                .listen((Event event) {
              var item = event.snapshot.value;
//            print("item: " + item.toString());
//            print("busstop_id: " + item['busstop_id']);
//            print("website: " + item['website']);
//            print("rating: " + item['rating']);
//            print("review_count: " + item['review_count']);
//            print("intl_phone_nr: " + item['intl_phone_nr']);
//            print("lat: " + item['lat']);
//            print("lon: " + item['lon']);
//            print("full_busstop_id: " + item['full_busstop_id']);
//            print("photo_reference: " + item['photo_reference']);
//            print("price_level: " + item['price_level']);
//            print("name: " + item['name']);
//            print("opening_hours: " + item['opening_hours']);
//            print("place_id: " + item['place_id']);

              if (item['photo_reference'] != "") {
                double rating = double.parse(item['rating']);
                listArray.add(GestureDetector(
                    child: Stack(
                      fit: StackFit.passthrough,
                      children: <Widget>[
                        Center(
                            child: FadeInImage(
                          placeholder: AssetImage('images/placeholder.png'),
                          image: NetworkImage(
                              'https://maps.googleapis.com/maps/api/place/photo?key=AIzaSyCMK6Vxt-xXvc79aY-7kSchYgmfCyDNsNc&maxheight=320&photoreference=' +
                                  item['photo_reference']),
                          fadeOutDuration: new Duration(milliseconds: 300),
                          fadeOutCurve: Curves.decelerate,
                          height: 192.0,
                          width: size.width,
                          fit: BoxFit.cover,
                        )),
                        Container(
                          decoration: BoxDecoration(color: Colors.transparent),
                          height: 192.0,
                          width: size.width,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(item['name'], style: style),
                              RatingItem(rating),
                            ],
                          )),
                        )
                      ],
                    ),
                    onTap: () {
                      if (item['website'] != '')
                        launch(item['website']);
                      else
                        launch(
                            'https://www.google.com/maps/dir/?api=1&travelmode=walking&destination=' +
                                itinerary['arrival_location'][0].toString() +
                                ',' +
                                itinerary['arrival_location'][1].toString());
                    }));
              }
              listView = ListView(children: listArray);
            });
          }
        }
      }
    });
    return new Scaffold(
        appBar: AppBar(
          title: Text("Itinerary"),
        ),
        body: Container(
            decoration: BoxDecoration(color: Colors.white), child: listView),
        floatingActionButton: FloatingActionButton(
            elevation: 3.0,
            child: StarItem(false, widget.uuid, widget.json),
            backgroundColor: Colors.white,
            onPressed: () {}));
  }
}

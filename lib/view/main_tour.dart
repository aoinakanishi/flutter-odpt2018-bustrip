import 'package:flutter/material.dart';
import 'package:odpt/screen/result.dart';

class ListItem extends StatefulWidget {
  final List<String> photoList;
  final List json;
  final String uuid;

  const ListItem(this.uuid, this.json, this.photoList);

  @override
  ListItemState createState() {
    return ListItemState();
  }
}

class ListItemState extends State<ListItem> {
  ListItemState();

  @override
  Widget build(BuildContext context) {
    var column = <Widget>[];
    var size = MediaQuery.of(context).size;
    var margin = 4;
    var photoWidth = size.width / 2 - margin;
    var photoHeight = 150.0;
    var length = 4;
    if (widget.photoList.length <= length) {
      length = widget.photoList.length;
    }
    if (widget.photoList.isNotEmpty) {
      for (var i = 0; i < length; i++) {
        print("i: " + i.toString());
        column.add(Expanded(
            flex: 0,
            child: Center(
                child: FadeInImage(
              placeholder: AssetImage('images/placeholder.png'),
              image: NetworkImage(
                  'https://maps.googleapis.com/maps/api/place/photo?key=REPLACE_WITH_YOUR_APIKEY&maxheight=320&photoreference=' +
                      widget.photoList[i].toString()),
              fadeOutDuration: new Duration(milliseconds: 300),
              fadeOutCurve: Curves.decelerate,
              height: photoHeight,
              width: photoWidth,
              fit: BoxFit.cover,
            ))));
      }
    }
    var column1 = <Widget>[];
    if (length > 0) column1.add(column[0]);
    if (length > 1) column1.add(column[1]);

    var column2 = <Widget>[];
    if (length > 2) column2.add(column[2]);
    if (length > 3) column2.add(column[3]);

    return GestureDetector(
        child: new Card(
          child: Row(
            children: <Widget>[
              Column(
                children: column1,
              ),
              Column(
                children: column2,
              ),
            ],
          ),
          elevation: 3.0,
        ),
        onTap: () {
          Navigator.push(
              context,
              new MaterialPageRoute<Null>(
                  settings: const RouteSettings(name: "/Sub/Result"),
                  builder: (BuildContext context) =>
                      Result(widget.uuid, widget.json)));
        });
  }
}

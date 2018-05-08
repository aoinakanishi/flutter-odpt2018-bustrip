import 'package:flutter/material.dart';

class ItemMoveType extends StatelessWidget {
  final String icon;
  final String text;
  final String time1;
  final String time2;
  final TextStyle style = TextStyle(
    color: Colors.black,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );

  ItemMoveType(this.icon, this.text, this.time1, this.time2);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Colors.white10),
        child: Row(
          children: <Widget>[
            Image.asset(this.icon, fit: BoxFit.cover),
            Column(
              children: <Widget>[
                Text(time1),
                Text("　|"),
                Text(time2),
              ],
            ),
            Text(text, style: style),
          ],
        ));
  }
}

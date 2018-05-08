import 'package:flutter/material.dart';

class RatingItem extends StatefulWidget {
  var rating;

  RatingItem(this.rating);

  @override
  RatingItemState createState() => RatingItemState();
}

class RatingItemState extends State<RatingItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
            widget.rating >= 1
                ? "images/ic_star_full.png"
                : widget.rating >= 0.1
                    ? "images/ic_star_half.png"
                    : "images/ic_star_none.png",
            fit: BoxFit.cover),
        Image.asset(
            widget.rating >= 2
                ? "images/ic_star_full.png"
                : widget.rating >= 1.1
                    ? "images/ic_star_half.png"
                    : "images/ic_star_none.png",
            fit: BoxFit.cover),
        Image.asset(
            widget.rating >= 3
                ? "images/ic_star_full.png"
                : widget.rating >= 2.1
                    ? "images/ic_star_half.png"
                    : "images/ic_star_none.png",
            fit: BoxFit.cover),
        Image.asset(
            widget.rating >= 4
                ? "images/ic_star_full.png"
                : widget.rating >= 3.1
                    ? "images/ic_star_half.png"
                    : "images/ic_star_none.png",
            fit: BoxFit.cover),
        Image.asset(
            widget.rating >= 5
                ? "images/ic_star_full.png"
                : widget.rating >= 4.1
                    ? "images/ic_star_half.png"
                    : "images/ic_star_none.png",
            fit: BoxFit.cover),
      ],
    );
  }
}

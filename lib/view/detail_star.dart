import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class StarItem extends StatefulWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference reference_users =
      FirebaseDatabase.instance.reference().child('users');

  bool defaultState;

  StarItemState starItemStatus;

  String uuid;

  List json;

  StarItem(this.defaultState, this.uuid, this.json);

  @override
  StarItemState createState() {
    starItemStatus = StarItemState(defaultState);
    return starItemStatus;
  }
}

class StarItemState extends State<StarItem> {
  bool _isActive = false;

  StarItemState(this._isActive);

  @override
  Widget build(BuildContext context) {
    checkIfSaved();
    return GestureDetector(
        child: new Image.asset(
            _isActive ? "images/ic_star_yellow.png" : "images/ic_star_gray.png",
            fit: BoxFit.cover),
        onTap: () {
          setState(() {
            _isActive = !_isActive;
            if (_isActive) {
              save();
            } else {
              remove();
            }
          });
        });
  }

  void checkIfSaved() async {
    final FirebaseUser currentUser = await widget._auth.currentUser();
    var savedValue =
        widget.reference_users.child(currentUser.uid).child(widget.uuid);
    savedValue.onValue.listen((Event event) {
      var item = event.snapshot.value;
      if (item != null) {
        _isActive = true;
      }
    });
  }

  void save() async {
    final FirebaseUser currentUser = await widget._auth.currentUser();
    widget.reference_users
        .child(currentUser.uid)
        .child(widget.uuid)
        .set(widget.json);
  }

  void remove() async {
    final FirebaseUser currentUser = await widget._auth.currentUser();
    widget.reference_users.child(currentUser.uid).child(widget.uuid).remove();
  }
}

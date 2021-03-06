import 'package:flutter/material.dart';

enum ConfirmAction { CANCEL, ACCEPT }

void showError(BuildContext context, dynamic ex) {
  showMessage(context, ex.toString());
}

void showMessage(BuildContext context, String text) {
  var alert = new AlertDialog(content: new Text(text), actions: <Widget>[
    new TextButton(
        child: const Text("Ok"),
        onPressed: () {
          Navigator.pop(context);
        })
  ]);
  showDialog(context: context, builder: (BuildContext context) => alert);
}

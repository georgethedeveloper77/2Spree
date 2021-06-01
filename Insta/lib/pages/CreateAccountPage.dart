import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spree/widgets/HeaderWidget.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String profileName;

  submitUsername() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      SnackBar snackBar = SnackBar(
        content: Text('Welcome 2Spree $profileName'),
        backgroundColor: Colors.lightGreenAccent,
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(milliseconds: 500), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          print("Can't pop");
        }
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, strTitle: "Settings", disableBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColorDark.withOpacity(0.5),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 26.0),
                  child: Center(
                    child: Text("Set up a username",
                        style:
                            TextStyle(fontSize: 26.0, fontFamily: "Signatra")),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: TextFormField(
                        style: TextStyle(color: Colors.white),
                        validator: (val) {
                          if (val.trim().length < 5 || val.isEmpty) {
                            return "username is too short";
                          } else if (val.trim().length > 15) {
                            return "username is too long";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => profileName = val,
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            border: OutlineInputBorder(),
                            labelText: "username",
                            labelStyle: TextStyle(
                              fontSize: 16.0,
                            ),
                            hintText: "Username must be at least 5 characters",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submitUsername,
                  child: Container(
                    height: 55.0,
                    width: 360.0,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Center(
                      child: Text(
                        "Proceed",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

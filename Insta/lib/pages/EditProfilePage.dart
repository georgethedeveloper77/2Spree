import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:spree/models/user.dart';
import 'package:spree/pages/HomePage.dart';
import 'package:spree/widgets/ProgressWidget.dart';

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;

  EditProfilePage({this.currentOnlineUserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileNameTextEditingController =
      TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User user;
  bool _bioValid = true;
  bool _profileNameValid = true;
  String url = "";
  File imageFileAvatar;

  void initState() {
    super.initState();

    getAndDisplayUserInformation();
  }

  getAndDisplayUserInformation() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot =
        await usersReference.document(widget.currentOnlineUserId).get();
    user = User.fromDocument(documentSnapshot);

    profileNameTextEditingController.text = user.profileName;
    bioTextEditingController.text = user.bio;

    setState(() {
      loading = false;
    });
  }

  updateUserData() {
    setState(() {
      profileNameTextEditingController.text.trim().length < 3 ||
              profileNameTextEditingController.text.isEmpty
          ? _profileNameValid = false
          : _profileNameValid = true;
      bioTextEditingController.text.trim().length > 110
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_bioValid && _profileNameValid) {
      usersReference.document(widget.currentOnlineUserId).updateData({
        "profileName": profileNameTextEditingController.text,
        "bio": bioTextEditingController.text
      });

      SnackBar snackBar = SnackBar(
          content: Text("Profile has been updated"),
          backgroundColor: Colors.greenAccent);
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Edit Profile",
          style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.done, color: Colors.white, size: 30.0),
              onPressed: () => Navigator.pop(context))
        ],
      ),
      backgroundColor: Colors.white10,
      body: loading
          ? LoadingType1()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 7.0),
                        child: CircleAvatar(
                          radius: 90.0,
                          backgroundImage: CachedNetworkImageProvider(user.url),
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              size: 100.0,
                              color: Colors.blueGrey.withOpacity(0.5),
                            ),
                            onPressed: () => googleImage(context),
                            padding: EdgeInsets.all(0.0),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.grey,
                            iconSize: 200.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            createProfileNameTextFormField(),
                            createBioTextFormField()
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 29.0, right: 50.0, left: 50.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            color: Colors.green,
                            onPressed: updateUserData,
                            child: Text(
                              "Update",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 29.0, right: 50.0, left: 50.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            color: Colors.red,
                            onPressed: logoutUser,
                            child: Text(
                              "Logout",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.0),
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

  logoutUser() async {
    await gSignIn.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  Column createProfileNameTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Profile Name",
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.white),
          controller: profileNameTextEditingController,
          decoration: InputDecoration(
              hintText: "Write profile name here...",
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              hintStyle: TextStyle(color: Colors.grey),
              errorText:
                  _profileNameValid ? null : "Profile name is too short"),
        )
      ],
    );
  }

  Column createBioTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Bio",
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.white),
          controller: bioTextEditingController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          maxLength: 110,
          decoration: InputDecoration(
              hintText: "Write your bio here...",
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _bioValid ? null : "Bio is too long"),
        )
      ],
    );
  }

  googleImage(mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Change your google account image!!..",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Signatra")),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                    "👷👉Google Account Settings => Manage Account => Home => Click on image",
                    style: TextStyle(color: Colors.green, fontSize: 18.0)),
                onPressed: () => print("pressed"),
              ),
              SimpleDialogOption(
                child: Text(
                    "😥 this issue may be 'll be sorted on next update 😥",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 10.0)),
                onPressed: () => print("pressed"),
              ),
              SimpleDialogOption(
                child: Text("Cancel",
                    style: TextStyle(color: Colors.red, fontSize: 18.0)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }
}

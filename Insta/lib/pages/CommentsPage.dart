import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spree/pages/HomePage.dart';
import 'package:spree/widgets/HeaderWidget.dart';
import 'package:spree/widgets/ProgressWidget.dart';
import 'package:timeago/timeago.dart' as tAgo;

import 'HomePage.dart';

class CommentsPage extends StatefulWidget {
  final String postId, postOwnerId, postImageUrl;

  CommentsPage({this.postId, this.postOwnerId, this.postImageUrl});

  @override
  CommentsPageState createState() => CommentsPageState(
      postId: this.postId,
      postOwnerId: this.postOwnerId,
      postImageUrl: this.postImageUrl);
}

class CommentsPageState extends State<CommentsPage> {
  final String postId, postOwnerId, postImageUrl;
  TextEditingController commentTextEditingController = TextEditingController();

  CommentsPageState({this.postId, this.postOwnerId, this.postImageUrl});

  retrieveComments() {
    return StreamBuilder(
      stream: commentsReference
          .document(postId)
          .collection("comments")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return LoadingType1();
        }

        List<Comment> comments = [];
        dataSnapshot.data.documents.forEach((document) {
          comments.add(Comment.fromDocument(document));
        });

        return ListView(
          children: comments,
        );
      },
    );
  }

  saveComment() {
    commentsReference.document(postId).collection("comments").add({
      "profileName": currentUser.profileName,
      "userId": currentUser.id,
      "comment": commentTextEditingController.text,
      "url": currentUser.url,
      "timestamp": DateTime.now(),
    });

    bool isNotPostOwner = currentUser.id != postOwnerId;

    if (isNotPostOwner) {
      activityFeedReference.document(postOwnerId).collection("feedItems").add({
        "type": "comment",
        "commentData": commentTextEditingController.text,
        "postId": postId,
        "userId": currentUser.id,
        "username": currentUser.username, // added this
        "profileName": currentUser.profileName,
        "userProfileImg": currentUser.url,
        "url": postImageUrl,
        "timestamp": DateTime.now(),
      });
    }
    commentTextEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Screams"),
      body: Column(
        children: <Widget>[
          Expanded(
            child: retrieveComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentTextEditingController,
              decoration: InputDecoration(
                  labelText: "Write your Screams here...",
                  labelStyle:
                      TextStyle(color: Colors.white, fontFamily: "Signatra"),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white))),
              style: TextStyle(color: Colors.white),
            ),
            trailing: OutlineButton(
              onPressed: saveComment,
              borderSide: BorderSide.none,
              child: Icon(
                Icons.add_comment,
                color: Colors.green,
                size: 28.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String profileName, userId, url, comment;
  final Timestamp timestamp;

  Comment(
      {this.profileName, this.userId, this.url, this.comment, this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot) {
    return Comment(
      profileName: documentSnapshot["profileName"],
      userId: documentSnapshot["userId"],
      comment: documentSnapshot["comment"],
      url: documentSnapshot["url"],
      timestamp: documentSnapshot["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(profileName + ":   " + comment,
                  style: TextStyle(fontSize: 18.0, color: Colors.black)),
              leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(url)),
              subtitle: Text(tAgo.format(timestamp.toDate()),
                  style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }
}

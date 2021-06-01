import 'package:flutter/material.dart';
import 'package:spree/pages/HomePage.dart';
import 'package:spree/widgets/HeaderWidget.dart';
import 'package:spree/widgets/PostWidget.dart';
import 'package:spree/widgets/ProgressWidget.dart';

class PostScreenPage extends StatelessWidget {
  final String userId, postId;

  PostScreenPage({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsReference
          .document(userId)
          .collection("usersPosts")
          .document(postId)
          .get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return LoadingType1();
        }
        Post post = Post.fromDocument(dataSnapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, strTitle: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:insta_clone/data_models/like.dart';
import 'package:insta_clone/data_models/post.dart';
import 'package:insta_clone/data_models/user.dart';
import 'package:insta_clone/generated/l10n.dart';
import 'package:insta_clone/style.dart';
import 'package:insta_clone/utils/constants.dart';
import 'package:insta_clone/view/comments/screens/comments_screen.dart';
import 'package:insta_clone/view/who_cares_me/screens/who_cares_me_screen.dart';
import 'package:insta_clone/view_models/feed_view_model.dart';
import 'package:provider/src/provider.dart';

class FeedPostLikesPart extends StatelessWidget {
  final Post post;
  final User postUser;
  FeedPostLikesPart({required this.post, required this.postUser});

  @override
  Widget build(BuildContext context) {
    final feedViewModel = context.read<FeedViewModel>();

    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: FutureBuilder(
        future: feedViewModel.getLikeResult(post.postId),
        builder: (context, AsyncSnapshot<LikeResult> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final likeResult = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    likeResult.isLikedToThisPost
                    ? IconButton(
                      onPressed: () => _unLikeIt(context),
                      icon: FaIcon(FontAwesomeIcons.solidHeart),
                      )
                    : IconButton(
                      onPressed: () => _likeIt(context),
                      icon: FaIcon(FontAwesomeIcons.heart),
                    ),
                    IconButton(
                      onPressed: () =>
                          _openCommentsScreen(context, post, postUser),
                      icon: FaIcon(FontAwesomeIcons.comment),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _checkLikesUsers(context),
                  child: Text(
                    likeResult.likes.length.toString() + " " + S.of(context).likes,
                    style: numberOfLikesTextStyle,
                  ),
                ),
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  _openCommentsScreen(BuildContext context, Post post, User postUser) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommentsScreen(post: post, postUser: postUser,)),
    );
  }

  _likeIt(BuildContext context) async {
    final feedViewModel = context.read<FeedViewModel>();
    await feedViewModel.likeIt(post);
  }

  _unLikeIt(BuildContext context) async {
    final feedViewModel = context.read<FeedViewModel>();
    await feedViewModel.unLikeIt(post);
  }

  _checkLikesUsers(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => WhoCaresMeScreen(
          mode: WhoCaresMeMode.LIKE,
          id: post.postId,
        )
    ));
  }
}

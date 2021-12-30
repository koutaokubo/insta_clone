import 'package:flutter/material.dart';
import 'package:insta_clone/data_models/post.dart';
import 'package:insta_clone/generated/l10n.dart';
import 'package:insta_clone/style.dart';
import 'package:insta_clone/view/common/circle_photo.dart';
import 'package:insta_clone/view_models/comments_view_model.dart';
import 'package:provider/src/provider.dart';

class CommentInputPart extends StatefulWidget {
  final Post post;
  CommentInputPart({required this.post});

  @override
  _CommentInputPartState createState() => _CommentInputPartState();
}

class _CommentInputPartState extends State<CommentInputPart> {
  final _commentInputController = TextEditingController();
  bool isCommentPostEnabled = false;

  @override
  void initState() {
    _commentInputController.addListener(onCommentChanged);
    super.initState();
  }

  @override
  void dispose() {
    _commentInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final commentsViewModel = context.watch<CommentsViewModel>();
    final commenter = commentsViewModel.currentUser;

    return Card(
      color: cardColor,
      child: ListTile(
        leading: CirclePhoto(
            photoUrl: commenter.photoUrl,
            isImageFromFile: false,
        ),
        title: TextField(
          maxLines: null,
          controller: _commentInputController,
          style: commentInputTextStyle,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: S.of(context).addComment,
          ),
        ),
        trailing: TextButton(
          onPressed: isCommentPostEnabled
          ? () => _postComment(context, widget.post)
          : null,
          child: Text(
            S.of(context).post,
            style: TextStyle(
                color: isCommentPostEnabled ? Colors.blue : Colors.grey),
          ),
        ),
      ),
    );
  }

  void onCommentChanged() {
    final commentsViewModel = context.read<CommentsViewModel>();
    commentsViewModel.comment = _commentInputController.text;

    setState(() {
      if (_commentInputController.text.length > 0) {
        isCommentPostEnabled = true;
      } else {
        isCommentPostEnabled = false;
      }
    });
  }

  _postComment(BuildContext context, Post post) async {
    final commentsViewModel = context.read<CommentsViewModel>();
    await commentsViewModel.postComment(post);
    _commentInputController.clear();
  }

}

import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone/style.dart';
import 'package:insta_clone/utils/functions.dart';
import 'package:insta_clone/view/common/circle_photo.dart';
import 'package:insta_clone/view/post/components/comment_rich_text.dart';

class CommentDisplayPart extends StatelessWidget {
  final String postUserPhotoUrl;
  final String name;
  final String text;
  final DateTime postDateTime;
  final GestureLongPressCallback? onLongPressed;
  
  CommentDisplayPart({
    required this.postUserPhotoUrl,
    required this.name,
    required this.text,
    required this.postDateTime,
    this.onLongPressed
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        splashColor: Colors.grey,
        onLongPress: onLongPressed,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CirclePhoto(photoUrl: postUserPhotoUrl, isImageFromFile: false),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommentRichText(name: name, text: text),
                  Text(
                    createTimeAgoString(postDateTime),
                    style: timeAgoTextStyle,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

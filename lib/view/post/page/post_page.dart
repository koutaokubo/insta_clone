import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:insta_clone/generated/l10n.dart';
import 'package:insta_clone/utils/constants.dart';
import 'package:insta_clone/view/common/components/button_with_icon.dart';
import 'package:insta_clone/view/post/screens/post_upload_screen.dart';

class PostPage extends StatelessWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 90),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ButtonWithIcon(
                iconData: FontAwesomeIcons.images,
                label: S.of(context).gallery,
                onPressed: () => _openUploadScreen(
                  UploadType.GALLERY,context
                ),
              ),
              SizedBox(height: 24),
              ButtonWithIcon(
                iconData: FontAwesomeIcons.camera,
                label: S.of(context).camera,
                onPressed: () => _openUploadScreen(
                  UploadType.CAMERA, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _openUploadScreen(UploadType uploadType, BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => PostUploadScreen(
          uploadType: uploadType
        ),
    ));
  }
}

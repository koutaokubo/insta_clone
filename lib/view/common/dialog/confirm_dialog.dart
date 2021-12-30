import 'package:flutter/material.dart';
import 'package:insta_clone/generated/l10n.dart';

showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  required ValueChanged onConfirmed,
}){
  showDialog(context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog(
          title: title,
          content: content,
          onConfirmed: onConfirmed,
      ),
  );
}

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final ValueChanged<bool> onConfirmed;
  ConfirmDialog({
    required this.title,
    required this.content,
    required this.onConfirmed
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
            onPressed: (){
              Navigator.pop(context);
              onConfirmed(true);
            },
            child: Text(S.of(context).yes),
        ),
        TextButton(
          onPressed: (){
            Navigator.pop(context);
            onConfirmed(false);
          },
          child: Text(S.of(context).no),
        )
      ],
    );
  }
}

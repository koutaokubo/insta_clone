import 'package:flutter/material.dart';
import 'package:insta_clone/data_models/user.dart';
import 'package:insta_clone/models/repositories/post_repository.dart';
import 'package:insta_clone/models/repositories/user_repository.dart';
import 'package:insta_clone/utils/constants.dart';
import 'package:insta_clone/view/who_cares_me/screens/who_cares_me_screen.dart';

class WhoCaresMeViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  WhoCaresMeViewModel({required this.userRepository});

  List<User> caresMeUsers = [];

  User get currentUser => UserRepository.currentUser!;

  WhoCaresMeMode whoCaresMeMode = WhoCaresMeMode.LIKE;

  Future<void> getCaresMeUsers(String id, WhoCaresMeMode mode) async {
    whoCaresMeMode = mode;
    caresMeUsers = await userRepository.getCaresMeUsers(id, mode);
    notifyListeners();
  }

  void rebuildAfterPop(String popProfileUserId) {
    getCaresMeUsers(popProfileUserId, whoCaresMeMode);
  }
}
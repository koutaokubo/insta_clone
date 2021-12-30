import 'package:flutter/material.dart';
import 'package:insta_clone/data_models/user.dart';
import 'package:insta_clone/models/repositories/post_repository.dart';
import 'package:insta_clone/models/repositories/user_repository.dart';

class SearchViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  SearchViewModel({required this.userRepository});

  List<User> soughtUser = [];

  Future<void> searchUser(String query) async {
    soughtUser = await userRepository.searchUsers(query);
    notifyListeners();
  }
}
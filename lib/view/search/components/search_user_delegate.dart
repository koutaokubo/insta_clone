import 'package:flutter/material.dart';
import 'package:insta_clone/data_models/user.dart';
import 'package:insta_clone/view/post/components/user_card.dart';
import 'package:insta_clone/view_models/search_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';

class SearchUserDelegate extends SearchDelegate<User?> {

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      brightness: Brightness.dark
    );
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: Icon(Icons.arrow_back),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(
        onPressed: () {
          query = "";
        },
        icon: Icon(Icons.clear),
    )];
  }

  @override
  Widget buildResults(BuildContext context) {
    final searchViewModel = context.read<SearchViewModel>();
    searchViewModel.searchUser(query);
    return _buildResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final searchViewModel = context.read<SearchViewModel>();
    searchViewModel.searchUser(query);
    return _buildResults(context);
  }

  //ユーザー検索処理
  Widget _buildResults(BuildContext context) {
    return Consumer<SearchViewModel>(
        builder: (context, model, child) =>
            ListView.builder(
                itemCount: model.soughtUser.length,
                itemBuilder: (context, int index) {
                  final user = model.soughtUser[index];
                  return UserCard(
                    photoUrl: user.photoUrl,
                    title: user.inAppUserName,
                    subTitle: user.bio,
                    onTap: () {
                      close(context, user);
                    },
                  );
                },
            ),
    );
  }

}

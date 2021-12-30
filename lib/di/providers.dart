import 'package:flutter/material.dart';
import 'package:insta_clone/models/db/database_manager.dart';
import 'package:insta_clone/models/location/location_manager.dart';
import 'package:insta_clone/models/repositories/post_repository.dart';
import 'package:insta_clone/models/repositories/user_repository.dart';
import 'package:insta_clone/view_models/comments_view_model.dart';
import 'package:insta_clone/view_models/feed_view_model.dart';
import 'package:insta_clone/view_models/login_view_model.dart';
import 'package:insta_clone/view_models/post_view_model.dart';
import 'package:insta_clone/view_models/profile_view_model.dart';
import 'package:insta_clone/view_models/search_view_model.dart';
import 'package:insta_clone/view_models/who_cares_me_view_model.dart';
import 'package:provider/single_child_widget.dart';
import 'package:provider/provider.dart';
List<SingleChildWidget> globalProviders = [
  ...independentModels,
  ...dependentModels,
  ...viewModels,
];

List<SingleChildWidget> independentModels = [
  Provider<DatabaseManager>(
    create: (_) => DatabaseManager(),
  ),
  Provider<LocationManager>(
      create: (_) => LocationManager(),
  )
];

List<SingleChildWidget> dependentModels = [
  ProxyProvider<DatabaseManager, UserRepository>(
      update: (_, dbManager, repo) => UserRepository(dbManager: dbManager),
  ),
  ProxyProvider2<DatabaseManager, LocationManager, PostRepository>(
    update: (_, dbManager, locationManager, repo) => PostRepository(
    dbManager: dbManager,
    locationManager: locationManager,
    ),
  ),
];

List<SingleChildWidget> viewModels = [
  ChangeNotifierProvider<LoginViewModel>(
      create: (context) => LoginViewModel(
          userRepository: context.read<UserRepository>()
      ),
  ),
  ChangeNotifierProvider<PostViewModel>(
      create: (context) => PostViewModel(
          userRepository: context.read<UserRepository>(),
          postRepository: context.read<PostRepository>(),
      ),
  ),
  ChangeNotifierProvider<FeedViewModel>(
    create: (context) => FeedViewModel(
      userRepository: context.read<UserRepository>(),
      postRepository: context.read<PostRepository>(),
    ),
  ),
  ChangeNotifierProvider<CommentsViewModel>(
    create: (context) => CommentsViewModel(
      userRepository: context.read<UserRepository>(),
      postRepository: context.read<PostRepository>(),
    ),
  ),
  ChangeNotifierProvider<ProfileViewModel>(
    create: (context) => ProfileViewModel(
      userRepository: context.read<UserRepository>(),
      postRepository: context.read<PostRepository>(),
    ),
  ),
  ChangeNotifierProvider<SearchViewModel>(
    create: (context) => SearchViewModel(
      userRepository: context.read<UserRepository>(),
    ),
  ),
  ChangeNotifierProvider<WhoCaresMeViewModel>(
    create: (context) => WhoCaresMeViewModel(
      userRepository: context.read<UserRepository>(),
    ),
  )

];
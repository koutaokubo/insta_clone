import 'dart:io';

import 'package:flutter/material.dart';
import 'package:insta_clone/data_models/location.dart';
import 'package:insta_clone/models/repositories/post_repository.dart';
import 'package:insta_clone/models/repositories/user_repository.dart';
import 'package:insta_clone/utils/constants.dart';

class PostViewModel extends ChangeNotifier {
  final PostRepository postRepository;
  final UserRepository userRepository;

  File? imageFile;

  Location? location;
  String locationString = "";

  String caption = "";

  PostViewModel({
    required this.userRepository,
    required this.postRepository});

  bool isProcessing = false;
  bool isImagePicked = false;

  Future<void> pickImage(UploadType uploadType) async {
    isImagePicked = false;
    isProcessing = true;
    notifyListeners();

    imageFile = await postRepository.pickImage(uploadType);
    print("pickedImage: ${imageFile?.path}");

    //位置情報
    location = await postRepository.getCurrentLocation();
    locationString = (location != null) ? _toLocationString(location!) : "";

    if (imageFile != null) isImagePicked = true;
    isProcessing = false;
    notifyListeners();
  }

  _toLocationString(Location location) {
    return location.country + " " + location.state + " " + location.city;
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    location = await postRepository.updateLocation(latitude,longitude);
    locationString = (location != null) ? _toLocationString(location!) : "";
    notifyListeners();
  }

  Future<void> post() async {

    if(imageFile ==null) return;

    isProcessing = true;
    notifyListeners();

    await postRepository.post(
      UserRepository.currentUser!,
      imageFile!,
      caption,
      location,
      locationString,
    );

    isProcessing = false;
    isImagePicked = false;
    notifyListeners();
  }

  void cancelPost() {
    isProcessing = false;
    isImagePicked = false;
    notifyListeners();
  }

}
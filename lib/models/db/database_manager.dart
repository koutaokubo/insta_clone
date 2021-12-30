import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:insta_clone/data_models/comments.dart';
import 'package:insta_clone/data_models/like.dart';
import 'package:insta_clone/data_models/post.dart';
import 'package:insta_clone/data_models/user.dart';
import 'package:insta_clone/models/repositories/user_repository.dart';

class DatabaseManager {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> searchUserInDb(auth.User firebaseUser) async {
    final query = await _db.collection("users")
        .where("userId", isEqualTo: firebaseUser.uid)
        .get();
    if (query.docs.length > 0) {
      return true;
    }
    return false;
  }

  Future<void> insertUser(User user) async {
    await _db.collection("users").doc(user.userId).set(user.toMap());
  }

  Future<User> getUserInfoFromDbById(String userId) async {
    final query = await _db.collection("users")
        .where("userId", isEqualTo: userId)
        .get();
    return User.fromMap(query.docs[0].data());
  }

  Future<String> uploadImageToStorage(File imageFile, String storageId) async {
    final storageRef = FirebaseStorage.instance.ref().child(storageId);
    final uploadTask = storageRef.putFile(imageFile);
    return uploadTask.then((TaskSnapshot snapshot) => snapshot.ref.getDownloadURL());
  }

  Future<void> insertPost(Post post) async {
    await _db.collection("posts").doc(post.postId).set(post.toMap());
  }

  Future<List<Post>> getPostsMineAndFollowings(String userId) async {
    final query = await _db.collection("posts").get();
    if (query.docs.length == 0) return [];

    var userIds = await getFollowingUserIds(userId);
    userIds.add(userId);

    final quotient = userIds.length ~/ 10;
    final remainder = userIds.length % 10;
    final numberOfChunks = (remainder == 0) ? quotient : quotient + 1;

    var userIdChunks = <List<String>>[];

    if (quotient == 0) {
      userIdChunks.add(userIds);
    } else if (quotient == 1){
      userIdChunks.add(userIds.sublist(0,10));
      userIdChunks.add(userIds.sublist(10,10 * remainder));
    } else {
      for (int i = 0; i < numberOfChunks -1;  i++) {
        userIdChunks.add(userIds.sublist(i * 10, i * 10 + 10));
      }
      userIdChunks.add(userIds.sublist(
          (numberOfChunks - 1) * 10, (numberOfChunks - 1) * 10 + remainder));
    }
    var results = <Post>[];
    await Future.forEach(userIdChunks, (List<String> userIds) async {
      final tempPosts = await getPostOfChunkedUser(userIds);
      tempPosts.forEach((post) {
        results.add(post);
      });
    });
    return results;
  }

  Future<List<Post>> getPostsByUser(String userId) async {
    final query = await _db.collection("posts").get();
    if (query.docs.length == 0) return [];

    var results = <Post>[];
    await _db
        .collection("posts")
        .where("userId", isEqualTo: userId)
        .orderBy("postDateTime", descending: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        results.add(Post.fromMap(element.data()));
      });
    });
    return results;
  }

  Future<List<String>> getFollowingUserIds(String userId) async {
    final query = await _db.collection("users").doc(userId).collection("followings").get();
    if (query.docs.length == 0) return [];
    var userIds = <String>[];
    query.docs.forEach((id) {
      userIds.add(id.data()["userId"]);
    });
    return userIds;
  }

  Future<List<String>> getFollowerUserIds(String userId) async {
    final query = await _db.collection("users").doc(userId).collection("followers").get();
    if (query.docs.length == 0) return [];
    var userIds = <String>[];
    query.docs.forEach((id) {
      userIds.add(id.data()["userId"]);
    });
    return userIds;
  }

  Future<List<Post>> getPostOfChunkedUser(List<String> userIds) async {
    var results = <Post>[];
    await _db.collection("posts")
        .where("userId", whereIn: userIds)
        .orderBy("postDateTime",descending: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        results.add(Post.fromMap(element.data()));
      });
    });
    return results;
  }

  Future<void> updatePost(Post updatePost) async{
    final reference = _db.collection("posts").doc(updatePost.postId);
    await reference.update(updatePost.toMap());
  }

  Future<void> postComment(Comment comment) async {
    await _db.collection("comments").doc(comment.commentId).set(comment.toMap());
  }

  Future<List<Comment>> getComments(String postId) async {
    final query = await _db.collection("comments").get();
    if (query.docs.length == 0) return [];
    var results = <Comment>[];
    await _db
        .collection("comments")
        .where("postId", isEqualTo: postId)
        .orderBy("commentDateTime")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        results.add(Comment.fromMap(element.data()));
      });
    });
    return results;
  }

  Future<void> deleteComment(String deleteCommentId) async {
    final reference = _db.collection("comments").doc(deleteCommentId);
    await reference.delete();
  }

  Future<void> likeIt(Like like) async {
    await _db.collection("likes").doc(like.likeId).set(like.toMap());
  }

  Future<List<Like>> getLikes(String postId) async {
    final query = await _db.collection("likes").get();
    if (query.docs.length == 0) return [];
    var results = <Like>[];
    await _db
        .collection("likes")
        .where("postId", isEqualTo: postId)
        .orderBy("likeDateTime")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        results.add(Like.fromMap(element.data()));
      });
    });
    return results;
  }

  Future<void> unLikeIt(Post post, User currentUser) async {
    final likeRef = await _db
        .collection("likes")
        .where("postId", isEqualTo: post.postId)
        .where("likeUserId", isEqualTo: currentUser.userId)
        .get();
    likeRef.docs.forEach((element) async {
      final ref = _db.collection("likes").doc(element.id);
      await ref.delete();
    });
  }

  Future<void> deletePost(String postId, String imageStoragePath) async {
    //Post
    final postRef = _db.collection("posts").doc(postId);
    await postRef.delete();

    //Comment
    final commentRef = await _db.collection("comments").where("postId", isEqualTo: postId).get();
    commentRef.docs.forEach((element) async {
      final ref = _db.collection("comments").doc(element.id);
      await ref.delete();
    });

    //Likes
    final likeRef = await _db.collection("likes").where("postId", isEqualTo: postId).get();
    likeRef.docs.forEach((element) async {
      final ref = _db.collection("likes").doc(element.id);
      await ref.delete();
    });

    //Storageから画像を削除
    final storageRef = FirebaseStorage.instance.ref().child(imageStoragePath);
    storageRef.delete();
  }

  Future<void> updateProfile(User updateUser) async {
    final reference = _db.collection("users").doc(updateUser.userId);
    await reference.update(updateUser.toMap());
  }

  Future<List<User>> searchUsers(String queryString) async {
    final query = await _db.collection("users").orderBy("inAppUserName")
        .startAt([queryString])
        .endAt([queryString + "\uf8ff"])
        .get();
    
    if (query.docs.length == 0) return [];
    
    var soughtUsers = <User>[];
    query.docs.forEach((element) { 
      final selectedUser = User.fromMap(element.data());
      if (selectedUser.userId != UserRepository.currentUser?.userId) {
        soughtUsers.add(selectedUser);
      }
    });
    return soughtUsers;
  }

  Future<void> follow(User profileUser, User currentUser) async {
    //CurrentUserにとってのfollowings
    await _db.collection("users").doc(currentUser.userId)
        .collection("followings").doc(profileUser.userId)
        .set({"userId": profileUser.userId});

    //profileUserにとってのfollowers
    await _db.collection("users").doc(profileUser.userId)
        .collection("followers").doc(currentUser.userId)
        .set({"userId": currentUser.userId});
  }

  Future<void> unFollow(User profileUser, User currentUser) async {
    //CurrentUserにとってのfollowingsからの削除
    await _db.collection("users").doc(currentUser.userId)
        .collection("followings").doc(profileUser.userId).delete();
    //profileUserにとってのfollowersからの削除
    await _db.collection("users").doc(profileUser.userId)
        .collection("followers").doc(currentUser.userId).delete();
  }

  Future<bool> checkIsFollowing(User profileUser, User currentUser) async {
    final query = await _db.collection("users").doc(currentUser.userId).collection("followings").get();
    if (query.docs.length == 0) return false;
    final checkQuery = await _db.collection("users").doc(currentUser.userId).collection("followings")
    .where("userId", isEqualTo: profileUser.userId).get();
    if (checkQuery.docs.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<User>> getLikesUsers(String postId) async {
    final query = await _db.collection("likes").where("postId", isEqualTo: postId).get();
    if (query.docs.length == 0) return [];
    var userIds =<String>[];
    query.docs.forEach((id) {
      userIds.add(id.data()["likeUserId"]);
    });
    var likeUsers = <User>[];
    await Future.forEach(userIds, (String userId) async {
      final user = await getUserInfoFromDbById(userId);
      likeUsers.add(user);
    });
    return likeUsers;
  }

  Future<List<User>> getFollowerUsers(String profileUserId) async {
    final followerUserIds = await getFollowerUserIds(profileUserId);
    var followerUsers = <User>[];
    await Future.forEach(followerUserIds, (String followerUserId) async {
      final user = await getUserInfoFromDbById(followerUserId);
      followerUsers.add(user);
    });
    return followerUsers;
  }

  Future<List<User>> getFollowingUsers(String profileUserId) async {
    final followingUserIds = await getFollowingUserIds(profileUserId);
    var followingUsers = <User>[];
    await Future.forEach(followingUserIds, (String followingUserId) async {
      final user = await getUserInfoFromDbById(followingUserId);
      followingUsers.add(user);
    });
    return followingUsers;
  }

}
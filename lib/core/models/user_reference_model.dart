import 'package:flutter/cupertino.dart';
import 'package:yaalu/core/models/avatar_reference_model.dart';
import 'package:yaalu/core/models/user_model.dart';
import 'package:yaalu/core/services/firestore_database_service.dart';

class UserReferenceModel extends AvatarReferenceModel {
  UserReferenceModel({
    @required this.fireDB,
    this.username = '',
    this.gender = '',
    this.dob = '',
    this.avatar,
    this.likes = 0,
  }) : super(avatar);

  final FirestoreDatabaseService fireDB;
  String username;
  String gender;
  String dob;
  int likes;
  String avatar;

  bool isLoading = false;
  bool submitted = false;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'gender': gender,
      'dob': dob,
      'avatar': avatar,
      'likes': likes,
    };
  }

  void updateUsername(String username) => updateWith(username: username);
  void updateDob(String dob) => updateWith(dob: dob);
  void updateGender(String gender) => updateWith(gender: gender);

  Future<bool> updateAvatar(String avatar) async {
    try {
      await this.fireDB.saveAvatar(AvatarReferenceModel(avatar));
      updateWith(avatar: avatar);
      return true;
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  Future<UserModel> getUser() async {
    final UserModel user = await this.fireDB.getUser();

    updateWith(
      username: user?.username,
      avatar: user?.avatar,
      dob: user?.dob,
      gender: user?.gender,
      likes: user?.likes,
    );

    return user;
  }

  void updateLikes() => this.likes++;

  void updateWith({
    String username,
    String dob,
    String gender,
    String avatar,
    int likes,
    bool isLoading,
    bool submitted,
  }) {
    this.username = username ?? this.username;
    this.dob = dob ?? this.dob;
    this.gender = gender ?? this.gender;
    this.avatar = avatar ?? this.avatar;
    this.likes = likes ?? this.likes;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    notifyListeners();
  }
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:string_validators/string_validators.dart';
import 'package:yaalu/core/constants/strings.dart';
import 'package:yaalu/core/enums/genders.dart';
import 'package:yaalu/core/enums/viewstate.dart';
import 'package:yaalu/core/models/avatar_reference_model.dart';
import 'package:yaalu/core/models/user_model.dart';
import 'package:yaalu/core/services/firebase_storage_service.dart';
import 'package:yaalu/core/services/firestore_database_service.dart';

enum UserModelType { complete, update }

class UserModelValidators {
  final TextInputFormatter usernameInputFormatter = ValidatorInputFormatter(
      editingValidator: UsernameEditingRegexValidator());

  final StringValidator usernameSubmitValidator =
      UsernameSubmitRegexValidator();
}

class UserReferenceModel extends AvatarReferenceModel with UserModelValidators {
  UserReferenceModel({
    @required this.fireDB,
    @required this.storage,
    this.username = '',
    this.gender = Gender.Male,
    this.dob = '',
    this.avatar,
    this.likes = 0,
    this.formType = UserModelType.complete,
    this.submitted = false,
  }) : super(avatar);

  final FirestoreDatabaseService fireDB;
  final FirebaseStorageService storage;
  String username;
  String gender;
  String dob;
  int likes;
  String avatar;
  bool submitted = false;
  UserModelType formType;

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

  void updateAvatar(File file) async {
    final avatar = await storage.uploadAvatar(file: file);
    updateWith(avatar: avatar);
  }

  void updateModelType(UserModelType type) {
    updateWith(formType: type);
  }

  Future<UserModel> getUser() async {
    if (username != null) {
      setState(ViewState.Busy);

      final UserModel user = await this.fireDB.getUser();

      updateWith(
        username: user?.username,
        avatar: user?.avatar,
        dob: user?.dob,
        gender: user?.gender,
        likes: user?.likes,
        formType: user?.username == "" || user?.username == null
            ? UserModelType.complete
            : UserModelType.update,
      );
      setState(ViewState.Idle);
      return user;
    }
    return null;
  }

  Future<void> saveUser() async {
    setState(ViewState.Busy);

    final user = UserModel(
        avatar: avatar,
        dob: dob,
        gender: gender,
        likes: likes,
        username: username);

    final result = await this.fireDB.saveUser(user);

    setState(ViewState.Idle);
    return result;
  }

  void updateLikes() => this.likes++;

  void updateWith({
    String username,
    String dob,
    String gender,
    String avatar,
    int likes,
    UserModelType formType,
  }) {
    this.username = username ?? this.username;
    this.dob = dob ?? this.dob;
    this.gender = gender ?? this.gender;
    this.avatar = avatar ?? this.avatar;
    this.likes = likes ?? this.likes;
    this.formType = formType ?? this.formType;
    notifyListeners();
  }

  bool get canSubmitUsername {
    return usernameSubmitValidator.isValid(username);
  }

  bool get canSubmitDob {
    return dob != '' || dob != null;
  }

  bool get canSubmit {
    final bool canSubmitFields = canSubmitUsername && canSubmitDob;
    return canSubmitFields && state != ViewState.Busy;
  }

  String get usernameErrorText {
    final bool showErrorText = submitted && !canSubmitUsername;
    final String errorText = username.isEmpty
        ? Strings.invalidUserNameEmpty
        : Strings.invalidUserNameErrorText;
    return showErrorText ? errorText : null;
  }
}

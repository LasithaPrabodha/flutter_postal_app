import 'package:firestore_service/firestore_service.dart';
import 'package:meta/meta.dart';
import 'package:yaalu/core/models/avatar_reference_model.dart';
import 'package:yaalu/core/models/user_model.dart';
import 'package:yaalu/core/services/firestore_path.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabaseService {
  FirestoreDatabaseService({@required this.uid})
      : assert(uid != null, 'Cannot create FirestoreDatabase with null uid');
  final String uid;

  final _service = FirestoreService.instance;

  // Save user on register
  Future<void> saveUser(UserModel user) => _service.setData(
        path: FirestorePath.user(uid),
        data: user.toMap(),
        merge: true,
      );

  // Save user on register
  Future<void> saveUsername(String username) => _service.setData(
        path: FirestorePath.usernames(username),
        data: {"uid": uid},
      );

  // Save user on register
  Future<void> saveAvatar(AvatarReferenceModel avatar) => _service.setData(
        path: FirestorePath.user(uid),
        data: avatar.toMap(),
        merge: true,
      );

  // Streams the current user
  Stream<UserModel> userStream() => _service.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => UserModel.fromMap(data),
      );

  // Reads the current user
  Future<UserModel> getUser() => _service.getData(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => UserModel.fromMap(data),
      );

  // Reads the current user
  Future<bool> isUsernameAvail(String username) => _service.getData(
        path: FirestorePath.usernames(username),
        builder: (data, documentId) => data == null,
      );
}

import 'package:yaalu/core/models/base_model.dart';

class AvatarReferenceModel extends BaseModel {
  AvatarReferenceModel(this.avatar);
  final String avatar;

  factory AvatarReferenceModel.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String avatar = data['avatar'];
    if (avatar == null) {
      return null;
    }
    return AvatarReferenceModel(avatar);
  }

  Map<String, dynamic> toMap() {
    return {
      'avatar': avatar,
    };
  }
}

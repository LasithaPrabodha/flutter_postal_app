class UserModel {
  UserModel({
    this.username = '',
    this.gender = '',
    this.dob = '',
    this.avatar = '',
    this.likes = 0,
  });

  String username;
  String gender;
  String dob;
  int likes;
  String avatar;

  factory UserModel.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    return UserModel(
      avatar: data['avatar'],
      dob: data['dob'],
      gender: data['gender'],
      likes: data['likes'],
      username: data['username'],
    );
  }
}

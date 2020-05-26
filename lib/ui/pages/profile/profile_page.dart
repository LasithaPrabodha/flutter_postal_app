import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:firebase_auth_service/firebase_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:yaalu/ui/common_widgets/avatar.dart';
import 'package:yaalu/core/constants/keys.dart';
import 'package:yaalu/core/constants/strings.dart';
import 'package:yaalu/core/models/user_reference_model.dart';
import 'package:yaalu/core/services/firebase_storage_service.dart';
import 'package:yaalu/core/services/firestore_database_service.dart';
import 'package:yaalu/core/services/image_picker_service.dart';
import 'package:yaalu/ui/common_widgets/base_widget.dart';

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final FirestoreDatabaseService fireDB =
//         Provider.of<FirestoreDatabaseService>(context, listen: false);

//     return FutureBuilder(
//       future: fireDB.getUser(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           final UserModel user = snapshot.data;

//           return ChangeNotifierProvider<UserReferenceModel>(
//             create: (_) => UserReferenceModel(
//               fireDB: fireDB,
//               avatar: user?.avatar,
//               dob: user?.dob,
//               gender: user?.gender,
//               likes: user?.likes,
//               username: user?.username,
//             ),
//             child: Consumer<UserReferenceModel>(
//               builder: (_, model, __) => ProfilePageContents(model: model),
//             ),
//           );
//         }

//         return const Scaffold(
//           body: Center(
//             child: CircularProgressIndicator(),
//           ),
//         );
//       },
//     );
//   }
// }

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key key}) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    try {
      final FirebaseAuthService auth =
          Provider.of<FirebaseAuthService>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      unawaited(showExceptionAlertDialog(
        context: context,
        title: Strings.logoutFailed,
        exception: e,
      ));
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool didRequestSignOut = await showAlertDialog(
          context: context,
          title: Strings.logout,
          content: Strings.logoutAreYouSure,
          cancelActionText: Strings.cancel,
          defaultActionText: Strings.logout,
        ) ??
        false;
    if (didRequestSignOut == true) {
      await _signOut(context);
    }
  }

  Future<void> _chooseAvatar(
      BuildContext context, UserReferenceModel model) async {
    try {
      // 1. Get image from picker
      final imagePicker =
          Provider.of<ImagePickerService>(context, listen: false);
      final file = await imagePicker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        // 2. Upload to storage
        final storage =
            Provider.of<FirebaseStorageService>(context, listen: false);
        final avatar = await storage.uploadAvatar(file: file);
        // 3. Save url to Firestore
        model.updateAvatar(avatar);
        // 4. (optional) delete local file as no longer needed
        await file.delete();
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _buildUserInfo(BuildContext context, UserReferenceModel model) {
    return Column(
      children: [
        Avatar(
          photoUrl: model.avatar,
          radius: 50,
          borderColor: Colors.black54,
          borderWidth: 2.0,
          onPressed: () => _chooseAvatar(context, model),
        ),
        const SizedBox(height: 8),
        if (model.username != null)
          Text(
            model.username,
            style: TextStyle(color: Colors.white),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fireDB =
        Provider.of<FirestoreDatabaseService>(context, listen: false);

    return BaseWidget<UserReferenceModel>(
      model: UserReferenceModel(fireDB: fireDB),
      onModelReady: (model) => model.getUser(),
      builder: (_, model, __) => Scaffold(
        appBar: AppBar(
          title: Text(Strings.profile),
          actions: <Widget>[
            FlatButton(
              key: Key(Keys.logout),
              child: Text(
                Strings.logout,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
              onPressed: () => _confirmSignOut(context),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(130.0),
            child: _buildUserInfo(context, model),
          ),
        ),
      ),
    );
  }
}

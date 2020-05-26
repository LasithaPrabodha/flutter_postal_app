import 'dart:math';

import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:firebase_auth_service/firebase_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:yaalu/core/constants/keys.dart';
import 'package:yaalu/core/constants/strings.dart';
import 'package:yaalu/core/enums/viewstate.dart';
import 'package:yaalu/core/models/user_reference_model.dart';
import 'package:yaalu/core/services/firebase_storage_service.dart';
import 'package:yaalu/core/services/firestore_database_service.dart';
import 'package:yaalu/core/services/image_picker_service.dart';
import 'package:yaalu/ui/common_widgets/avatar.dart';
import 'package:yaalu/ui/common_widgets/base_widget.dart';
import 'package:yaalu/ui/common_widgets/loading_scafold.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _signOut() async {
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

  Future<void> _confirmSignOut() async {
    final bool didRequestSignOut = await showAlertDialog(
          context: context,
          title: Strings.logout,
          content: Strings.logoutAreYouSure,
          cancelActionText: Strings.cancel,
          defaultActionText: Strings.logout,
        ) ??
        false;
    if (didRequestSignOut == true) {
      await _signOut();
    }
  }

  Future<void> _chooseAvatar(UserReferenceModel model) async {
    try {
      final imagePicker =
          Provider.of<ImagePickerService>(context, listen: false);
      final file = await imagePicker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        model.updateAvatar(file);
        // (optional) delete local file as no longer needed
        await file.delete();
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _buildUserInfo(UserReferenceModel model) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              width: 50,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: Axis.vertical,
                children: <Widget>[
                  Text(
                    model.likes.toString(),
                    style: TextStyle(fontSize: 30),
                  ),
                  Text("stamps")
                ],
              ),
            ),
            Avatar(
              photoUrl: model.avatar,
              radius: 50,
              borderColor: Colors.black54,
              borderWidth: 2.0,
              onPressed: () => _chooseAvatar(model),
            ),
            SizedBox(
              width: 50,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: Axis.vertical,
                children: <Widget>[
                  Text(
                    model.likes.toString(),
                    style: TextStyle(fontSize: 30),
                  ),
                  Text("likes")
                ],
              ),
            )
          ],
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

  Widget _buildContent(UserReferenceModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[Text("Gender"), Text(model.gender)],
          ),
        ),
        Container(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[Text("Birthday"), Text(model.dob)],
          ),
        ),
        Container(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[Text("Username"), Text(model.username)],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fireDB =
        Provider.of<FirestoreDatabaseService>(context, listen: false);
    final storage = Provider.of<FirebaseStorageService>(context, listen: false);

    return BaseWidget<UserReferenceModel>(
      model: UserReferenceModel(fireDB: fireDB, storage: storage),
      onModelReady: (model) => model.getUser(),
      builder: (_, model, __) => model.state == ViewState.Busy
          ? LoadingScafold()
          : Scaffold(
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
                    onPressed: () => _confirmSignOut(),
                  )
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(130.0),
                  child: _buildUserInfo(model),
                ),
              ),
              body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: SingleChildScrollView(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Container(
                      width: min(constraints.maxWidth, 600),
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildContent(model),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
    );
  }
}

import 'dart:math';

import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:firebase_auth_service/firebase_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:yaalu/core/enums/genders.dart';
import 'package:yaalu/core/enums/viewstate.dart';
import 'package:yaalu/ui/common_widgets/avatar.dart';
import 'package:yaalu/core/constants/keys.dart';
import 'package:yaalu/core/constants/strings.dart';
import 'package:yaalu/core/models/user_reference_model.dart';
import 'package:yaalu/core/services/firebase_storage_service.dart';
import 'package:yaalu/core/services/firestore_database_service.dart';
import 'package:yaalu/core/services/image_picker_service.dart';
import 'package:yaalu/ui/common_widgets/base_widget.dart';
import 'package:yaalu/ui/common_widgets/loading_scafold.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

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
      await _signOut(context);
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
        Avatar(
          photoUrl: model.avatar,
          radius: 50,
          borderColor: Colors.black54,
          borderWidth: 2.0,
          onPressed: () => _chooseAvatar(model),
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

  Widget _buildButton(
      {UserReferenceModel model, String gender, BoxDecoration decoration}) {
    return Expanded(
      child: InkWell(
        onTap: () => model.updateGender(gender),
        child: Container(
          alignment: Alignment.center,
          decoration: model.gender == gender ? decoration : null,
          child: Text(
            gender,
            style: TextStyle(
              color: model.gender == gender ? Colors.blueGrey : Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Future<DateTime> selectDate(UserReferenceModel model) async {
    return await showDatePicker(
      context: context,
      initialDate: model.dob != '' ? DateTime.parse(model.dob) : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
  }

  Widget _buildContent(UserReferenceModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text("Gender"),
        SizedBox(height: 12),
        Container(
          height: 30,
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: Row(
            children: <Widget>[
              _buildButton(
                model: model,
                gender: Gender.Male,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    topLeft: Radius.circular(4),
                  ),
                ),
              ),
              _buildButton(
                model: model,
                gender: Gender.Female,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
              ),
              _buildButton(
                model: model,
                gender: Gender.NonBi,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text("Birthday"),
        SizedBox(height: 12),
        Container(
          height: 30,
          child: InkWell(
            onTap: () async {
              final DateTime picked = await selectDate(model);
              if (picked != null) {
                model.updateDob(DateFormat('yyyy-MM-dd').format(picked));
              }
            },
            child: Text(model.dob != '' ? model.dob : "YYYY - MM - DD"),
          ),
        ),
        SizedBox(height: 18),
        Text("Username"),
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            errorText: model.usernameErrorText,
            enabled: model.state == ViewState.Idle,
          ),
          obscureText: false,
          autocorrect: false,
          keyboardAppearance: Brightness.light,
          onChanged: model.updateUsername,
          inputFormatters: <TextInputFormatter>[
            model.usernameInputFormatter,
          ],
        ),
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
                  model.formType == UserModelType.complete
                      ? FlatButton(
                          key: Key(Keys.save),
                          child: Text(
                            Strings.save,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () => model.saveUser(),
                        )
                      : FlatButton(
                          key: Key(Keys.logout),
                          child: Text(
                            Strings.logout,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () => _confirmSignOut(),
                        ),
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

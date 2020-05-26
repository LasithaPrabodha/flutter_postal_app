import 'package:auth_widget_builder/auth_widget_builder.dart';
import 'package:email_password_sign_in_ui/email_password_sign_in_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth_service/firebase_auth_service.dart';
import 'package:yaalu/ui/pages/home_page.dart';
import 'package:yaalu/ui/router.dart';
import 'package:yaalu/core/services/firebase_storage_service.dart';
import 'package:yaalu/core/services/firestore_database_service.dart';
import 'package:yaalu/core/services/image_picker_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MultiProvider for top-level services that don't depend on any runtime values (e.g. uid)
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        Provider<ImagePickerService>(
          create: (_) => ImagePickerService(),
        ),
      ],
      child: AuthWidgetBuilder(
        userProvidersBuilder: (_, user) => [
          Provider<User>.value(value: user),
          Provider<FirestoreDatabaseService>(
            create: (_) => FirestoreDatabaseService(uid: user.uid),
          ),
          Provider<FirebaseStorageService>(
            create: (_) => FirebaseStorageService(uid: user.uid),
          ),
        ],
        builder: (_, userSnapshot) {
          print('[auth state change]');
          return MaterialApp(
            theme: ThemeData(primarySwatch: Colors.blueGrey),
            debugShowCheckedModeBanner: false,
            home: AuthWidget(
              userSnapshot: userSnapshot,
              nonSignedInBuilder: (_) => EmailPasswordSignInPage(
                btnColor: Colors.blueGrey,
              ),
              signedInBuilder: (_) => HomeBuilder(),
            ),
            onGenerateRoute: Router.onGenerateRoute,
          );
        },
      ),
    );
  }
}

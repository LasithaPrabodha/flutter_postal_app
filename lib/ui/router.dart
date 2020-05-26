import 'package:flutter/material.dart';
import 'package:yaalu/ui/pages/profile/profile_page.dart';
import 'package:yaalu/ui/pages/settings/settings_page.dart';

class Routes {
  static const signInScreen = '/email-password-sign-in-page';
  static const profilePage = '/profile-page';
  static const settingsPage = '/settings-page';
}

class Router {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // final args = settings.arguments;

    switch (settings.name) {
      // case Routes.signInScreen:
      //   return MaterialPageRoute<dynamic>(
      //     builder: (_) => EmailPasswordSignInPage(onSignedIn: args),
      //     settings: settings,
      //     fullscreenDialog: true,
      //   );
      case Routes.profilePage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => ProfilePage(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.settingsPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => SettingsPage(),
          settings: settings,
          fullscreenDialog: true,
        );

      default:
        // TODO: Throw
        return null;
    }
  }
}

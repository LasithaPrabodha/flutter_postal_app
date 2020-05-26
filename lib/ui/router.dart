import 'package:flutter/material.dart';
import 'package:yaalu/ui/pages/letters/letters_page.dart';
import 'package:yaalu/ui/pages/profile/profile_page.dart';
import 'package:yaalu/ui/pages/settings/settings_page.dart';

class Routes {
  static const profilePage = '/profile-page';
  static const settingsPage = '/settings-page';
  static const lettersPage = '/letters-page';
}

class Router {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
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
      case Routes.lettersPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => LettersPage(),
          settings: settings,
          fullscreenDialog: true,
        );

      default:
        // TODO: Throw
        return null;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:yaalu/core/constants/strings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(Strings.settingsPage)),
      appBar: AppBar(
        title: Text(Strings.settings),
      ),
    );
  }
}

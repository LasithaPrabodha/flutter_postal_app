import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaalu/ui/common_widgets/loading_scafold.dart';
import 'package:yaalu/ui/common_widgets/photo_hero.dart';
import 'package:yaalu/core/models/user_model.dart';
import 'package:yaalu/ui/pages/profile/complete_profile_page.dart';
import 'package:yaalu/ui/router.dart';
import 'package:yaalu/core/services/firestore_database_service.dart';

class HomeBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fireDB =
        Provider.of<FirestoreDatabaseService>(context, listen: false);
    return StreamBuilder<UserModel>(
        stream: fireDB.userStream(),
        builder: (context, snapshot) {
          print('[stream user]');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScafold();
          }
          final UserModel userDetails = snapshot.data;

          if (userDetails?.username == null) {
            return CompleteProfilePage();
          }

          return HomePage();
        });
  }
}

class HomePage extends StatelessWidget {
  Widget _buildMailIcon() {
    return Stack(
      children: <Widget>[
        PhotoHero(
          photo: 'assets/images/message.png',
          width: 72,
        ),
        Positioned(
          top: 0.0,
          right: 0.0,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            constraints: BoxConstraints(
              minWidth: 12,
              minHeight: 12,
            ),
            child: Text(
              "10",
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }

  void _showWriteLetter(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: EdgeInsets.all(18),
          height: 320,
          child: Column(
            children: [
              // Row(
              //   children: <Widget>[Text("To:"), Text("Gender"), Text("Age")],
              // ),
              TextField(
                maxLines: 11,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Your message goes here',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                  FlatButton(
                    color: Colors.amberAccent,
                    onPressed: () {},
                    child: Text("Send"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.menu),
            color: Colors.white,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      color: Colors.blueGrey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.blueGrey,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.settingsPage);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.account_circle,
                    color: Colors.blueGrey,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.profilePage);
                  },
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: FlatButton(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.all(20),
                    child: _buildMailIcon(),
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.lettersPage);
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amberAccent,
        child: const Icon(
          Icons.edit,
          color: Colors.blueGrey,
        ),
        onPressed: () {
          _showWriteLetter(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}

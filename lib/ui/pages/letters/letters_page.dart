import 'package:flutter/material.dart';
import 'package:yaalu/core/constants/strings.dart';
import 'package:yaalu/ui/pages/letters/archive/archive_page.dart';
import 'package:yaalu/ui/pages/letters/bookmarks/bookmark_page.dart';
import 'package:yaalu/ui/pages/letters/inbox/inbox_page.dart';

class LettersPage extends StatelessWidget {
  const LettersPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.letters),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inbox)),
              Tab(icon: Icon(Icons.archive)),
              Tab(icon: Icon(Icons.bookmark)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            InboxPage(),
            BookmarkPage(),
            ArchivePage(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
          },
          child: Icon(
            Icons.create,
            color: Colors.blueGrey,
          ),
          backgroundColor: Colors.amberAccent,
        ),
      ),
    );
  }
}

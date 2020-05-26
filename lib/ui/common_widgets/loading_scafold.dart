import 'package:flutter/material.dart';

class LoadingScafold extends StatelessWidget {
  const LoadingScafold({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

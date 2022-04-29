import 'package:flutter/material.dart';

class PageAbout extends StatelessWidget {
  const PageAbout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ABOUT')),
      body: Text('ABOUT'),
    );
  }
}

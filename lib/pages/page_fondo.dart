import 'package:flutter/material.dart';

import '../models/fondo.dart';

class PageFondo extends StatelessWidget {
  final Fondo fondo;
  const PageFondo({Key? key, required this.fondo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FONDO')),
      body: Center(
        child: Text('FONDO'),
      ),
    );
  }
}

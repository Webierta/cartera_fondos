import 'package:flutter/material.dart';

import '../routes.dart';

class Loading {
  final BuildContext context;
  const Loading(this.context);

  void openDialog({required String title, String? subtitle}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            backgroundColor: const Color(0xDD000000), // Colors.black87,
            content: LoadingIndicator(title: title, subtitle: subtitle),
          ),
        );
      },
    );
  }

  void closeDialog() => Navigator.of(context).pop();
  //void closeDialog() => Navigator.of(context).pushNamed(RouteGenerator.fondoPage);
}

class LoadingIndicator extends StatelessWidget {
  final String title;
  final String? subtitle;
  const LoadingIndicator({Key? key, required this.title, this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xDD000000),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _getLoadingIndicator(),
              _getHeading(title),
              if (subtitle != null) _getText(subtitle!),
            ]));
  }

  Padding _getLoadingIndicator() {
    return const Padding(
      child: SizedBox(
        child: CircularProgressIndicator(
          strokeWidth: 10,
          backgroundColor: Color(0xFF9E9E9E),
        ),
        width: 32,
        height: 32,
      ),
      padding: EdgeInsets.only(bottom: 16),
    );
  }

  Widget _getHeading(String titulo) {
    return Padding(
        child: Text(
          titulo,
          style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
          textAlign: TextAlign.center,
        ),
        padding: const EdgeInsets.only(bottom: 4));
  }

  Text _getText(String subtitulo) {
    return Text(
      subtitulo,
      style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
      textAlign: TextAlign.center,
    );
  }
}

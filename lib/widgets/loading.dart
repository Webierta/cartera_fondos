import 'package:flutter/material.dart';

class Loading {
  final BuildContext context;
  const Loading(this.context);

  void openDialog({required String title, String? subtitle}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BaseDialog(title: title, subtitle: subtitle);
      },
    );
  }

  void closeDialog() => Navigator.of(context).pop();
}

class DialogScreen extends StatefulWidget {
  final BuildContext context;
  final String title;
  final String? subtitle;
  const DialogScreen({Key? key, required this.context, required this.title, this.subtitle})
      : super(key: key);

  @override
  _DialogScreenState createState() => _DialogScreenState();
}

class _DialogScreenState extends State<DialogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return const AlertDialog();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(title: widget.title, subtitle: widget.subtitle);
  }
}

class BaseDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  const BaseDialog({Key? key, required this.title, this.subtitle = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        contentPadding: const EdgeInsets.only(top: 10.0),
        backgroundColor: const Color(0xEF000000),
        content: LoadingIndicator(title: title, subtitle: subtitle),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final String title;
  final String? subtitle;
  const LoadingIndicator({Key? key, required this.title, this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _getHeading(title),
          _getLoadingIndicator(),
          if (subtitle != null) _getText(subtitle!),
        ],
      ),
    );
  }

  Padding _getLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: LinearProgressIndicator(),
    );
  }

  Text _getHeading(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(color: Color(0xFF2196F3), fontSize: 16),
      textAlign: TextAlign.center,
    );
  }

  Text _getText(String subtitulo) {
    return Text(
      subtitulo,
      style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12),
      textAlign: TextAlign.center,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoadingProgress extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  const LoadingProgress({Key? key, required this.titulo, this.subtitulo = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF0D47A1),
      // systemNavigationBarColor / statusBarIconBrightness / systemNavigationBarDividerColor
    ));

    return Loading(titulo: titulo, subtitulo: subtitulo);
  }
}

class Loading extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  const Loading({Key? key, required this.titulo, this.subtitulo = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              const Spacer(flex: 1),
              Column(
                children: [
                  Text(titulo, style: const TextStyle(color: Color(0xFF2196F3), fontSize: 18)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.width * 0.2,
                    child: const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 20),
                  Text(subtitulo, style: const TextStyle(color: Color(0xFF2196F3), fontSize: 14)),
                ],
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

/*class LoadingDialog {
  final BuildContext context;
  const LoadingDialog(this.context);

  void openDialog({required String titulo, String subtitulo = ''}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Loading(titulo: titulo, subtitulo: subtitulo);
      },
    );
  }

  void closeDialog() => Navigator.of(context).pop();
}*/

/*
class LoadingIndicatorDialog {
  static final LoadingIndicatorDialog _singleton = LoadingIndicatorDialog._internal();
  late BuildContext _context;
  bool isDisplayed = false;

  factory LoadingIndicatorDialog() {
    return _singleton;
  }

  LoadingIndicatorDialog._internal();

  show(BuildContext context, {String text = 'Loading...'}) {
    if (isDisplayed) {
      return;
    }
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          _context = context;
          isDisplayed = true;
          return Center(child: Text(text));
          //return Loading(titulo: text);
          */ /*return WillPopScope(
            onWillPop: () async => false,
            child: SimpleDialog(
              backgroundColor: Colors.white,
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                        child: CircularProgressIndicator(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(text),
                      )
                    ],
                  ),
                )
              ],
            ),
          );*/ /*
        });
  }

  dismiss() {
    if (isDisplayed) {
      Navigator.of(_context).pop();
      isDisplayed = false;
    }
  }
}
*/

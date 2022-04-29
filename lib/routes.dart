import 'package:flutter/material.dart';

import 'models/cartera.dart';
import 'models/fondo.dart';
import 'pages/page_about.dart';
import 'pages/page_cartera.dart';
import 'pages/page_fondo.dart';
import 'pages/page_home.dart';
import 'pages/page_info.dart';
import 'pages/page_input_fondo.dart';

class RouteGenerator {
  static const String homePage = '/';
  static const String carteraPage = '/cartera';
  static const String fondoPage = '/fondo';
  static const String inputFondo = '/inputFondo';
  static const String infoPage = '/info';
  static const String aboutPage = '/about';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case homePage:
        return MaterialPageRoute(builder: (context) => const PageHome());
      case carteraPage:
        return MaterialPageRoute(builder: (context) => PageCartera(cartera: args as Cartera));
      case fondoPage:
        return MaterialPageRoute(builder: (context) => PageFondo(fondo: args as Fondo));
      case inputFondo:
        return MaterialPageRoute(builder: (context) => PageInputFondo());
      case infoPage:
        return MaterialPageRoute(builder: (context) => const PageInfo());
      case aboutPage:
        return MaterialPageRoute(builder: (context) => const PageAbout());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ERROR'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Página no encontrada!'),
        ),
      );
    });
  }
}
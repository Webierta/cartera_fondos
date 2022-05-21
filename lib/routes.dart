import 'package:flutter/material.dart';

//import 'models/cartera.dart';
//import 'models/fondo.dart';
import 'pages/page_about.dart';
import 'pages/page_cartera.dart';
import 'pages/page_fondo.dart';
import 'pages/page_home.dart';
import 'pages/page_info.dart';
import 'pages/page_input_fondo.dart';
import 'pages/page_input_range.dart';
import 'pages/page_mercado.dart';
import 'pages/page_search_fondo.dart';

class RouteGenerator {
  static const String homePage = '/';
  static const String carteraPage = '/cartera';
  static const String fondoPage = '/fondo';
  static const String searchFondo = '/searchFondo';
  static const String inputFondo = '/inputFondo';
  static const String inputRange = '/inputRange';
  static const String mercadoPage = '/mercado';
  static const String infoPage = '/info';
  static const String aboutPage = '/about';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    //final args = settings.arguments as bool?;

    switch (settings.name) {
      case homePage:
        //return MaterialPageRoute(builder: (context) => const PageHome());
        //return SlideRoute(page: const PageHome(), isBack: args);
        return AnimatedRoute(const PageHome());
      case carteraPage:
        //return MaterialPageRoute(builder: (context) => PageCartera(cartera: args as Cartera));
        //return MaterialPageRoute(builder: (context) => const PageCartera());
        //ScreenArguments argument = args as ScreenArguments;
        //final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
        //return SlideRoute(page: const PageCartera(), isBack: args != null ? args as bool : null);
        return AnimatedRoute(const PageCartera());

      case fondoPage:
        //ScreenArguments argument = args as ScreenArguments;
        //final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
        //return PageFondo(cartera: args.cartera, fondo: args.fondo);
        //return MaterialPageRoute(builder: (BuildContext context) => const PageFondo());
        return AnimatedRoute(const PageFondo());
      /*return MaterialPageRoute(
            builder: (context) => PageFondo(
                  cartera: args as Cartera,
                  fondo: args as Fondo,
                ));*/
      case searchFondo:
        //return MaterialPageRoute(builder: (context) => const PageSearchFondo());
        return AnimatedRoute(const PageSearchFondo());
      case inputFondo:
        //return MaterialPageRoute(builder: (context) => PageInputFondo(cartera: args as Cartera));
        //return MaterialPageRoute(builder: (context) => const PageInputFondo());
        return AnimatedRoute(const PageInputFondo());
      case inputRange:
        //return MaterialPageRoute(builder: (context) => PageInputRange(fondo: args as Fondo));
        //return MaterialPageRoute(builder: (context) => const PageInputRange());
        return AnimatedRoute(const PageInputRange());
      case mercadoPage:
        //return MaterialPageRoute(builder: (context) => const PageMercado());
        return AnimatedRoute(const PageMercado());
      case infoPage:
        //return MaterialPageRoute(builder: (context) => const PageInfo());
        return AnimatedRoute(const PageInfo());
      case aboutPage:
        //return MaterialPageRoute(builder: (context) => const PageAbout());
        return AnimatedRoute(const PageAbout());
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

/*class ScreenArguments {
  */ /*final Cartera cartera;
  final Fondo fondo;
  ScreenArguments(this.cartera, this.fondo);*/ /*
  final bool toRight;
  ScreenArguments(this.toRight);
}*/

class AnimatedRoute extends PageRouteBuilder {
  final Widget page;
  //bool? isBack;
  //final RouteSettings settings;
  //SlideRoute({required this.page, this.isBack})
  AnimatedRoute(this.page)
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return page;
          },
          /*transitionsBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation, Widget child) {
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.fastOutSlowIn,
                ),
              ),
              child: child,
            );
          },*/

          transitionsBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> anotherAnimation, Widget child) {
            animation = CurvedAnimation(
              curve: Curves.linear,
              parent: animation,
            );
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          /*transitionsBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation, Widget child) {
            return SlideTransition(
              position: Tween<Offset>(
                */ /*begin: const Offset(1, 0),
                end: Offset.zero,*/ /*
                begin: isBack == true ? const Offset(-1, 0) : const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  curve: isBack == true
                      ? const Interval(0, 0.5, curve: Curves.easeOutCubic)
                      : const Interval(0.5, 1, curve: Curves.easeOutCubic),
                  parent: animation,
                ),
              ),
              child: child,
            );
          },*/
          //transitionDuration: const Duration(milliseconds: 2000),
        );
}

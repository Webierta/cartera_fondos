import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

//import 'models/cartera.dart';
import 'models/carfoin_provider.dart';
import 'routes.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  //runApp(const MyApp());
  runApp(
    MultiProvider(
      providers: [
        //ChangeNotifierProvider(create: (_) => Carteras()),
        ChangeNotifierProvider(create: (_) => CarfoinProvider()),
        //ChangeNotifierProvider<Cartera>(create: (_) => Cartera(name: 'Provider')),
        /*ProxyProvider0(
          update: (_, __) => Cartera(name: name),
          child: const MyApp(),
        )*/
      ],
      child: const MyApp(),
    ),
    /*ProxyProvider0(
      update: (_, __) => Cartera(name: name),
      child: const MyApp(),
    ),*/
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES')],
      debugShowCheckedModeBanner: false,
      title: 'Cartera Fondos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      //home: const PageHome(),
    );
  }
}

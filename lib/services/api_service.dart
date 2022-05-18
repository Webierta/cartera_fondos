/*https://www.morningstar.es/es/funds/SecuritySearchResults.aspx?type=ALL&search=ebn
https://www.finect.com/fondos-inversion/ES0152743003-Ing_direct_fn_dinamico_fi
https://markets.ft.com/data/funds/uk
https://funds.ddns.net/l.php
http://www.cnmv.es/Portal/ANCV/ConsultaISIN.aspx
https://www.bolsamadrid.es/esp/aspx/Mercados/Fondos.aspx#
https://es.investing.com/funds/
https://www.bde.es/webbde/es/estadis/fi/ifs_es.html*/

// String version = dotenv.get('VERSION', fallback: 'Default');

/*val client = OkHttpClient()
val request = Request.Builder()
    .url("https://funds.p.rapidapi.com/v1/fund/LU0690375182")
    .get()
    .addHeader("X-RapidAPI-Host", "funds.p.rapidapi.com")
    .addHeader("X-RapidAPI-Key", $version)
    .build()
val response = client.newCall(request).execute()

CODE 200:
{
"name":"Fundsmith Equity Fund Sicav T EUR Acc"
"market":"EUR"
"price":53.96
"humanDate":"2022-04-29"
"epochSecs":1651190400
}
*/

/*
val client = OkHttpClient()

val request = Request.Builder()
    .url("https://funds.p.rapidapi.com/v1/historicalPrices/LU0690375182?to=2020-12-31&from=2015-01-25")
    .get()
    .addHeader("X-RapidAPI-Host", "funds.p.rapidapi.com")
    .addHeader("X-RapidAPI-Key", $version)
    .build()

val response = client.newCall(request).execute()
CODE 200:
[
0:{
  "humanDate":"2015-01-26"
  "epochSecs":1422230400
  "price":22.02
}
1:{
  "humanDate":"2015-01-27"
  "epochSecs":1422316800
  "price":21.98
}
...
]

*/

// TODO: CHECK INTERNET

import 'dart:async';
//import 'dart:convert';
//import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/data_api.dart';
import '../models/data_api_range.dart';

class ApiService {
  //static const String urlFondo = 'https://funds.p.rapidapi.com/v1/fund/';

  static String version = dotenv.get('VERSION', fallback: 'Default');

  Future<DataApi?> getDataApi(String isin) async {
    const String urlFondo = 'https://funds.p.rapidapi.com/v1/fund/';
    var url = urlFondo + isin;
    //String version = dotenv.get('VERSION', fallback: 'Default');
    Map<String, String> headers = {
      "x-rapidapi-host": "funds.p.rapidapi.com",
      "x-rapidapi-key": version,
    };

    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      //.timeout(const Duration(seconds: 10));
      print(response.statusCode);
      if (response.body.contains('Access denied')) {
        // status = Status.accessDenied;
        //TODO: status Code == 200 pero sin resultados
      } else if (response.statusCode == 200) {
        //return DataApi.fromJson(jsonDecode(response.body));
        return dataApiFromJson(response.body);
      }
    } catch (e) {
      print(e.toString());
    }
    /*on TimeoutException {
      //status = Status.tiempoExcedido;
      //return null;
    } on SocketException {
      //status = Status.noInternet;
      // SocketException == sin internet
    } on Error {
      //status = Status.error;
    }*/
    return null;
  }

  //static String urlHistorico = 'https://funds.p.rapidapi.com/v1/historicalPrices/LU0690375182?to=2020-12-31&from=2015-01-25';
  Future<List<DataApiRange>?>? getDataApiRange(String isin, String to, String from) async {
    //static String urlHistorico = 'https://funds.p.rapidapi.com/v1/historicalPrices/LU0690375182?to=2020-12-31&from=2015-01-25';
    // https://funds.p.rapidapi.com/v1/historicalPrices/LU0690375182?to=2020-12-31&from=2015-01-25
    String urlRange = 'https://funds.p.rapidapi.com/v1/historicalPrices/';
    //LU0690375182?to=2020-12-31&from=2015-01-25
    //var url = urlRange + isin + '?to=2021-12-31&from=2021-12-01'; // '?to=' + to + '&from=' + from';
    var url = urlRange + isin + '?to=' + to + '&from=' + from;
    //String version = dotenv.get('VERSION', fallback: 'Default');
    Map<String, String> headers = {
      "x-rapidapi-host": "funds.p.rapidapi.com",
      "x-rapidapi-key": version,
    };

    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      //.timeout(const Duration(seconds: 10));
      print(response.statusCode);
      if (response.body.contains('Access denied')) {
        // status = Status.accessDenied;
      } else if (response.statusCode == 200) {
        //return DataApi.fromJson(jsonDecode(response.body));
        return dataApiRangeFromJson(response.body);
      }
    } catch (e) {
      print(e.toString());
    }
    /*on TimeoutException {
      //status = Status.tiempoExcedido;
      //return null;
    } on SocketException {
      //status = Status.noInternet;
    } on Error {
      //status = Status.error;
    }*/
    return null;
  }
}

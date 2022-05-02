// https://quicktype.io/
// To parse this JSON data, do
// final dataApi = dataApiFromJson(jsonString);

import 'dart:convert';

DataApi dataApiFromJson(String str) => DataApi.fromJson(json.decode(str));

String dataApiToJson(DataApi data) => json.encode(data.toJson());

class DataApi {
  String name;
  String market;
  double price;
  DateTime humanDate;
  int epochSecs;

  DataApi({
    required this.name,
    required this.market,
    required this.price,
    required this.humanDate,
    required this.epochSecs,
  });

  factory DataApi.fromJson(Map<String, dynamic> json) => DataApi(
        name: json["name"],
        market: json["market"],
        price: json["price"].toDouble(),
        humanDate: DateTime.parse(json["humanDate"]),
        epochSecs: json["epochSecs"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "market": market,
        "price": price,
        "humanDate":
            "${humanDate.year.toString().padLeft(4, '0')}-${humanDate.month.toString().padLeft(2, '0')}-${humanDate.day.toString().padLeft(2, '0')}",
        "epochSecs": epochSecs,
      };
}

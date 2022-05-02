// To parse this JSON data, do//
// final dataApiRange = dataApiRangeFromJson(jsonString);

import 'dart:convert';

List<DataApiRange> dataApiRangeFromJson(String str) =>
    List<DataApiRange>.from(json.decode(str).map((x) => DataApiRange.fromJson(x)));

String dataApiRangeToJson(List<DataApiRange> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataApiRange {
  DateTime humanDate;
  int epochSecs;
  double price;

  DataApiRange({
    required this.humanDate,
    required this.epochSecs,
    required this.price,
  });

  factory DataApiRange.fromJson(Map<String, dynamic> json) => DataApiRange(
        humanDate: DateTime.parse(json["humanDate"]),
        epochSecs: json["epochSecs"],
        price: json["price"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "humanDate":
            "${humanDate.year.toString().padLeft(4, '0')}-${humanDate.month.toString().padLeft(2, '0')}-${humanDate.day.toString().padLeft(2, '0')}",
        "epochSecs": epochSecs,
        "price": price,
      };
}

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:csv/csv.dart';

void downloadCsvWeb(List<List<String>> data) {
  final csv = const ListToCsvConverter().convert(data);
  final bytes = utf8.encode(csv);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "users.csv")
    ..click();
  html.Url.revokeObjectUrl(url);
}

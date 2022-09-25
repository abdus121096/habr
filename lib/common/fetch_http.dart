import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

fetchHttpHabs(url) {
  var client = http.Client();
  Uri.parse ('https://habr.com/ru/rss/hubs/all/');
  return client.get(url);
}

parseDescription(description){
  description = parse(description);
  var txtDescription = parse(description.body.text).documentElement?.text;
  return txtDescription;
}

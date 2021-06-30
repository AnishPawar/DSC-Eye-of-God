import 'package:html/parser.dart';

class HtmlTags {
  static void removeTag({htmlString, callback}) {
    var document = parse(htmlString);
    String parsedString = parse(document.body.text).documentElement.text;
    callback(parsedString);
  }
}

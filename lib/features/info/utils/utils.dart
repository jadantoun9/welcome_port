import 'package:html/parser.dart';

String decodeHtmlEntities(String htmlString) {
  final text = htmlString.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
    final int characterCode = int.parse(match.group(1)!);
    return String.fromCharCode(characterCode);
  });

  return text
      .replaceAll('&quot;', '"')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');
}

String getStringFromHtml(String htmlString) {
  final document = parse(htmlString);
  final String parsedString =
      parse(document.body?.text).documentElement?.text ?? '';

  return parsedString;
}

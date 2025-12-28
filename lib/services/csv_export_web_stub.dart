// Stub file for non-web platforms
// This file is only used when dart:html is not available

Future<String> saveCsvFileWeb(List<List<String>> csvData) async {
  throw UnsupportedError('Web export is only available on web platform');
}


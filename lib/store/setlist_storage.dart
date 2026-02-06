import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SetlistStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/setlist_data.json');
  }

  Future<File> saveSetlist(String jsonContent) async {
    final file = await _localFile;
    return file.writeAsString(jsonContent);
  }

  Future<String> readSetlist() async {
    try {
      final file = await _localFile;
      return await file.readAsString();
    } catch (e) {
      return "";
    }
  }
}
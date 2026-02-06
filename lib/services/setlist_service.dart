
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/song.dart';

class SetlistService {
  static List<Song>? _cachedSetlist;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/setlist_data.json');
  }

  Future<void> saveSetlist(List<Song> data) async {
    _cachedSetlist = data;
    final file = await _localFile;
    final listToSave = data.map((song) => song.toJson()).toList();
    await file.writeAsString(json.encode(listToSave));
  }

  Future<List<Song>> readSetlist() async {
    if (_cachedSetlist != null) return _cachedSetlist!;
    try {
      final file = await _localFile;
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final decodedList = json.decode(contents) as List;
      _cachedSetlist =
          decodedList.map((jsonData) => Song.fromJson(jsonData)).toList();
      return _cachedSetlist!;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveScenesToSong(String songTitle, Map<String, dynamic> scenes) async {
    List<Song> list = await readSetlist();
    int index = list.indexWhere((s) => s.title == songTitle);

    if (index != -1) {
      list[index].scenes = scenes.map((key, value) => MapEntry(key, value.fromMap(value)));
      await saveSetlist(list);
    }
  }

  void clearCache() => _cachedSetlist = null;
}

import 'dart:convert';

import 'package:midi_pedal_manager/models/pedal_preset.dart';

class Song {
  String title;
  Map<String, PedalPreset> scenes;

  Song({required this.title, required this.scenes});

  factory Song.fromJson(Map<String, dynamic> json) {
    var scenesMap = json['scenes'] as Map<String, dynamic>? ?? {};
    return Song(
      title: json['title'] ?? 'Sem Título',
      scenes: {
        "A": PedalPreset.fromMap(scenesMap['A'] ?? {}),
        "B": PedalPreset.fromMap(scenesMap['B'] ?? {}),
        "C": PedalPreset.fromMap(scenesMap['C'] ?? {}),
      },
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'scenes': scenes.map((k, v) => MapEntry(k, v.toMap())),
  };

  factory Song.empty(String title) => Song(
    title: title,
    scenes: {
      "A": PedalPreset(name: "Clean"),
      "B": PedalPreset(name: "Crunch"),
      "C": PedalPreset(name: "Solo"),
    },
  );
}

class Setlist {
  String name;
  List<Song> songs;

  Setlist({required this.name, required this.songs});

  // Converte o objeto para uma String JSON
  String toRawJson() => json.encode({
    'name': name,
    'songs': songs.map((s) => s.toJson()).toList(),
  });
}
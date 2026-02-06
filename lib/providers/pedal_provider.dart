import 'package:flutter/material.dart';
import '../models/pedal_preset.dart';
import '../models/song.dart';
import '../services/bluetooth_service.dart';
import '../services/midi_encoder.dart';
import '../services/setlist_service.dart';

class PedalProvider with ChangeNotifier {
  final SetlistService _setlistService = SetlistService();

  Song? _currentSong;
  String _activeSceneKey = "A";
  PedalPreset? _editingPreset; // Buffer de edição

  PedalPreset? get editingPreset => _editingPreset;

  String get activeSceneKey => _activeSceneKey;

  Song? get currentSong => _currentSong;

  void loadSong(Song song) {
    _currentSong = song;
    _activeSceneKey = "A";
    _cloneSceneToEditingBuffer(_activeSceneKey);
    notifyListeners();
  }

  void switchScene(String key) {
    if (_currentSong == null || _activeSceneKey == key) return;
    _activeSceneKey = key;
    _cloneSceneToEditingBuffer(key);
    notifyListeners();
  }

  void _cloneSceneToEditingBuffer(String key) {
    if (_currentSong == null) return;
    final scenePreset = _currentSong!.scenes[key];
    if (scenePreset != null) {
      _editingPreset = PedalPreset.fromMap(scenePreset.toMap());
    }
  }

  void updateEditingParameter(String param, double value) {
    if (_editingPreset == null) return;
    final presetMap = _editingPreset!.toMap();
    presetMap[param] = value;
    _editingPreset = PedalPreset.fromMap(presetMap);
    notifyListeners();
  }

  Future<void> saveChanges() async {
    if (_currentSong == null || _editingPreset == null) return;

    // 1. Cria um novo mapa de cenas com a cena alterada (imutabilidade)
    final newScenes = Map<String, PedalPreset>.from(_currentSong!.scenes);
    newScenes[_activeSceneKey] = _editingPreset!;

    // 2. Cria uma NOVA instância da música com as cenas atualizadas
    final updatedSong = Song(title: _currentSong!.title, scenes: newScenes);

    // 3. Lê a lista, substitui a música antiga pela nova e salva
    final setlist = await _setlistService.readSetlist();
    final index = setlist.indexWhere((s) => s.title == updatedSong.title);

    if (index != -1) {
      setlist[index] = updatedSong;
      await _setlistService.saveSetlist(setlist);
    }

    // 4. ATUALIZA o estado do provider para a nova instância da música
    _currentSong = updatedSong;

    // 5. Clona a cena recém-salva para resetar o estado 'isDirty'
    _cloneSceneToEditingBuffer(_activeSceneKey);

    notifyListeners();
  }

  void sendMidiPreset() {
    if (_editingPreset == null) return;

    // Garante que o mapa seja <String, double> como o encoder espera
    final Map<String, double> doubleParams = _editingPreset!.toMap().map(
            (key, value) =>
            MapEntry(key, (value is num) ? value.toDouble() : 0.0));

    final bytes = MidiEncoder.encodeFullSysex(doubleParams);
    BluetoothService().sendMidiCommand(bytes);
  }

  void discardChanges() {
    if (_currentSong == null) return;
    _cloneSceneToEditingBuffer(_activeSceneKey);
    notifyListeners();
  }
}

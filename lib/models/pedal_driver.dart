abstract class PedalDriver {
  String get name;
  // Retorna o comando de volume para este pedal específico
  List<int> getVolumeCommand(int volume);
  // Retorna o comando de troca de preset (A, B, C...)
  List<int> getPresetCommand(int presetIndex);
}

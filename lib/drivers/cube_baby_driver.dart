import '../models/pedal_driver.dart';

class CubeBabyDriver implements PedalDriver {
  @override
  String get name => "M-Vave Cube Baby";

  @override
  List<int> getVolumeCommand(int volume) {
    // Aqui vai aquela lógica de 21 bytes que validamos no Python
    return [0xF0, 0x00, 0x32, 0x09, 0x49, 0xF7];
  }

  @override
  List<int> getPresetCommand(int index) {
    // Aqui vai o comando de Save/Load que mapeamos
    return [];
  }
}

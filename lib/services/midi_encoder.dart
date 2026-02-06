import 'dart:typed_data';

class MidiEncoder {
  // O Cube Baby costuma usar 0xB0 para Control Change no Canal 1
  static const int statusCC = 0xB0;

  // Mapeamento de endereços CC (Exemplo baseado em pedais MIDI padrão)
  // Você deve substituir pelos valores exatos que validou no Python
  static const int ccGain = 0x14; // CC 20
  static const int ccVol  = 0x07; // CC 7
  static const int ccRev  = 0x5B; // CC 91

  /// Converte o valor de 0.0-1.0 para o range MIDI 0-127
  static int _toMidiValue(double value) {
    return (value * 127).clamp(0, 127).toInt();
  }

  /// Gera um pacote de 3 bytes para Control Change
  static Uint8List encodeCC(int controller, double value) {
    return Uint8List.fromList([
      statusCC,
      controller,
      _toMidiValue(value),
    ]);
  }

  /// Se o seu pedal usa SysEx (os pacotes longos de ~21 bytes que você viu no Python)
  static Uint8List encodeFullSysex(Map<String, double> params) {
    List<int> message = [0xF0, 0x00, 0x21];

    message.add(_toMidiValue(params['gain'] ?? 0.5));
    message.add(_toMidiValue(params['vol'] ?? 0.5));
    message.add(_toMidiValue(params['rev'] ?? 0.5));

    message.add(0xF7);
    return Uint8List.fromList(message);
  }
}
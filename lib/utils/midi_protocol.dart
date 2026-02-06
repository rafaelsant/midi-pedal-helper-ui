class MidiProtocol {
  // O comando de 21 bytes que você validou no Python
  static List<int> createVolumeCommand(int volume) {
    // Volume deve ser de 0 a 127 (0x7F)
    int vol = volume.clamp(0, 127);

    // Baseado no seu log: 00 -> Checksum 68, Suffix 01
    // Baseado no seu log: 7F -> Checksum 6A, Suffix 03

    // Cálculo do Checksum e Sufixo (Ajustado pela nossa descoberta de overflow)
    int checksum;
    int suffix;

    if (vol < 0x3F) {
      // Exemplo de lógica de transbordo simplificada
      checksum = (0x68 + (vol * 2)) % 128; // Estimativa baseada nos logs
      suffix = 0x01;
    } else {
      checksum = (0x6A + (vol * 2)) % 128;
      suffix = 0x03;
    }

    return [
      0xF0,
      0x00,
      0x32,
      0x09,
      0x49,
      0x00,
      0x00,
      0x40,
      0x02,
      0x05,
      0x00,
      0x00,
      0x00,
      0x18,
      0x00,
      0x00,
      0x00,
      vol,
      checksum,
      suffix,
      0xF7,
    ];
  }
}

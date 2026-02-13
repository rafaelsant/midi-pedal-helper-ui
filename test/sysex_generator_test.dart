import 'package:flutter_test/flutter_test.dart';
import 'package:midi_pedal_manager/models/pedal_profile.dart';
import 'package:midi_pedal_manager/utils/sysex_generator.dart';

void main() {
  group('SysexGenerator Tests', () {
    // Define a simplified parameter with an anchor for Scene A
    final param = PedalParameter(
      id: 'time', 
      name: 'Time',
      baseAddress: 0x06, 
      min: 0, 
      max: 127,
      checksumStrategy: 'scene_offset_0x20',
      anchors: {
        // Scene A Time Max Anchor from user doc: 28 01
        // F0 00 32 09 49 00 00 40 02 [06] 00 00 00 18 00 00 00 [1F] 28 01 F7
        127: [0xF0, 0x00, 0x32, 0x09, 0x49, 0x00, 0x00, 0x40, 0x02, 0x06, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, 0x1F, 0x28, 0x01, 0xF7]
      },
    );

    test('Generates Scene A command (no change)', () {
      final cmd = SysexGenerator.generate(param, 0, 127, 16);
      expect(cmd[18], 0x28);
      expect(cmd[19], 0x01);
    });

    test('Generates Scene B command (Offset -0x20)', () {
      // 0x128 (296) - 0x20 (32) = 264 (0x108) -> 08 02?
      // Wait, 0x0128 is 1*128 + 28(40) = 168.
      // 168 - 32 = 136.
      // 136 = 1x128 + 8. -> 08 01.
      final cmd = SysexGenerator.generate(param, 1, 127, 16);
      expect(cmd[18], 0x08);
      expect(cmd[19], 0x01);
    });

    test('Generates Scene C command (Offset -0x40, with borrow)', () {
      // Scene C should be Scene A - 0x40 (64).
      // 168 - 64 = 104.
      // 104 = 0x68.
      // MSB should be 0.
      // Expected: 68 00.
      final cmd = SysexGenerator.generate(param, 2, 127, 16);
      expect(cmd[18], 0x68);
      expect(cmd[19], 0x00);
    });
    
    test('Updates Address byte correctly', () {
      // Scene A Address: 0x06
      // Scene B Address: 0x06 + 0x10 = 0x16
      // Scene C Address: 0x06 + 0x20 = 0x26
      
      final cmdA = SysexGenerator.generate(param, 0, 127, 16);
      expect(cmdA[9], 0x06);
      
      final cmdB = SysexGenerator.generate(param, 1, 127, 16);
      expect(cmdB[9], 0x16);
      
      final cmdC = SysexGenerator.generate(param, 2, 127, 16);
      expect(cmdC[9], 0x26);
    });
  });
}

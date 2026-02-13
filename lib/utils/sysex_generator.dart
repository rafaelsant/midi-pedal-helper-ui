import '../models/pedal_profile.dart';

class SysexGenerator {
  /// Generates the SysEx command for a given parameter, scene, and value.
  /// Uses the "Anchor Point" strategy:
  /// 1. Finds a known command (anchor) for the value (or close to it).
  /// 2. Adjusts the checksum based on the Scene Index.
  ///    Formula: Checksum_SceneN = Checksum_SceneA - (SceneIndex * 0x20)
  static List<int> generate(
      PedalParameter param, int sceneIndex, int value, int sceneOffset) {
    
    // 1. Find Anchor for Value (Scene A Reference)
    // currently we require an exact match for the value in the anchor map
    // or we default to the closest?
    // For now, let's try to find exact match.
    // If not found, we really should throw or implement the Value interpolation logic too
    // But per instructions we start with defined anchors.
    
    List<int>? anchorCmd = param.anchors[value];
    
    if (anchorCmd == null) {
        // Fallback: If we don't have the anchor, we try to derive it?
        // Risky without the specific value formula. 
        // Let's print a warning and return empty for now, or throw.
        throw Exception("No anchor defined for value $value on parameter ${param.id}");
    }

    // 2. Clone the command so we don't modify the anchor
    List<int> cmd = List.from(anchorCmd);

    // 3. Apply Scene Offset to Address (Byte 9, 0-indexed)
    // Structure: F0 00 32 09 49 [00 00 40 02] [ADDR] ...
    // Indices:   0  1  2  3  4   5  6  7  8    9
    // Wait, let's check the doc for the exact structure.
    // Doc: F0 00 32 09 49 00 00 40 02 [ADDR(9)] ...
    // Yes, Byte 9 is Address.
    
    // Base Address is already in the Anchor for Scene A.
    // We need to ADD (SceneIndex * Offset) to the address?
    // Doc says: Scene A Base 0x00, B 0x10, C 0x20.
    // Address = Base + (Scene * 0x10).
    // The Anchor IS Scene A (Scene 0).
    // So we add (SceneIndex * sceneOffset) to Byte 9.
    
    int currentAddr = cmd[9];
    int newAddr = currentAddr + (sceneIndex * sceneOffset);
    cmd[9] = newAddr;
    
    // 4. Apply Scene Offset to Checksum (Bytes 18, 19? or just 18?)
    // Doc: 
    // Byte 18: Checksum A (LSB)
    // Byte 19: Checksum B (MSB)
    // Formula: Checksum_LSB(Scene_N) = Checksum_LSB(Scene_A) - (Scene_Index * 0x20)
    
    // Although the user calls it LSB, let's verify if it needs borrow from MSB.
    // "Checksum LSB decreases by 0x20". 
    // If LSB underflows, we might need to adjust MSB?
    // The user example didn't show underflow cases (e.g. 0x10 - 0x20).
    // But usually these checksums are 7-bit or 14-bit integers.
    // Let's treat (MSB << 7) | LSB as a 14-bit number? 
    // Or just (MSB << 8) | LSB if they used full bytes (but MIDI is 7-bit).
    // The user terminology "LSB/MSB" usually implies 7-bit in MIDI.
    
    // However, the formula specifically says "Checksum_LSB decreases by 0x20".
    // It doesn't mention MSB changing.
    // Let's look at the user provided data:
    // Scene A: ... 00 68 01 F7 (LSB=68, MSB=01)
    // Scene B: ... 00 48 01 F7 (LSB=48, MSB=01) -> 68 - 20 = 48. Correct.
    // Scene C: ... 00 28 01 F7 (LSB=28, MSB=01) -> 48 - 20 = 28. Correct.
    
    // What if LSB is < 0x20? 
    // Only Example: Scene C Max Vol: ... 7F 2A 03 F7.
    // If we go to Scene D (hypothetical), 2A - 20 = 0A.
    // If we go further?
    // The user only has 3 scenes. And 0x20 * 2 = 0x40.
    // Lowest observed LSB is ~0x10 (Time min C: 1F 68 00 -> Wait. Scene C Time Min is 26... 1F 68 00.
    // Let's check Time Min.
    // Sc A: 66 01.
    // Sc B: 46 01.
    // Sc C: 26 01.
    // Works.
    
    // Wait, check "Time Max":
    // Sc A: 28 01.
    // Sc B: 08 01.
    // Sc C: 68 00. (User doc says "68 00 F7").
    // 0x08 - 0x20 = -0x18.
    // In 7-bit land (0-127):
    // 0x08 (8) - 0x20 (32) = -24.
    // 128 - 24 = 104 = 0x68.
    // And MSB dropped from 01 to 00.
    // So YES, it IS a 14-bit subtraction (or with borrow).
    
    // Implementation:
    // Value = (MSB << 7) | LSB.
    // NewValue = Value - (SceneIndex * 0x20).
    // NewLSB = NewValue & 0x7F.
    // NewMSB = (NewValue >> 7) & 0x7F.
    
    int lsb = cmd[byteIndexChecksumLSB]; // Index 18 usually
    int msb = cmd[byteIndexChecksumMSB]; // Index 19 usually
    
    // Identify indices based on length?
    // User says "Fixed Header... 21 bytes total".
    // Index 18 is Checksum A (LSB).
    // Index 19 is Checksum B (MSB).
    // Index 20 is F7.
    
    int checksumVal = (msb << 7) | lsb;
    int decrement = sceneIndex * 0x20;
    int newChecksumVal = checksumVal - decrement;
    
    cmd[18] = newChecksumVal & 0x7F;
    cmd[19] = (newChecksumVal >> 7) & 0x7F;
    
    return cmd;
  }
  
  static const int byteIndexChecksumLSB = 18;
  static const int byteIndexChecksumMSB = 19;
}

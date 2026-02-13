import '../models/pedal_driver.dart';
import '../models/pedal_profile.dart';
import '../utils/sysex_generator.dart';

class CubeBabyDriver implements PedalDriver {
  final PedalProfile profile;

  CubeBabyDriver(this.profile);

  @override
  String get name => "${profile.brand} ${profile.model}";

  List<int> getCommand(String paramId, int sceneIndex, int value) {
    var param = profile.parameters.firstWhere(
      (p) => p.id == paramId,
      orElse: () => throw Exception("Parameter $paramId not found in profile"),
    );

    return SysexGenerator.generate(
      param, 
      sceneIndex, 
      value, 
      profile.sceneOffset
    );
  }

  @override
  List<int> getVolumeCommand(int volume) {
    // Assuming 'volume' is mapped to 'volume' id in profile
    // And assumes Scene A (0) for default volume control?
    // Or do we need to know the current scene?
    // The previous interface was simple `getVolumeCommand(int volume)`.
    // We might need to update the interface or assume Scene A for now.
    return getCommand('volume', 0, volume);
  }

  @override
  List<int> getPresetCommand(int index) {
      // TODO: Implement Preset Change
      return [];
  }
}

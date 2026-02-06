import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:midi_pedal_manager/screen/setlist_screen.dart';
import 'package:provider/provider.dart';
import '../providers/pedal_provider.dart';
import '../services/bluetooth_service.dart';
import '../widgets/pedal_knob.dart';
import '../widgets/tap_tempo_button.dart';

class CubeBabyControlScreen extends StatelessWidget {
  const CubeBabyControlScreen({super.key});

  void _handleSave(BuildContext context) {
    final provider = context.read<PedalProvider>();
    provider.saveChanges();

    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Cena salva com sucesso!"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleReset(BuildContext context) {
    context.read<PedalProvider>().discardChanges();
    HapticFeedback.vibrate();
  }

  String _getAmpName(double value) {
    int slot = (value * 8).round().clamp(0, 8);
    const amps = [
      "Clean Fender", "Blues Marshall", "Crunch Vox", "Lead Mesa",
      "Metal Diezel", "Hi-Gain ENGL", "Modern", "Boutique", "Jazz",
    ];
    return amps[slot];
  }

  String _getModName(double value) {
    if (value < 0.33) return "CHORUS";
    if (value < 0.66) return "PHASER";
    return "TREMOLO";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PedalProvider>(
      builder: (context, provider, child) {
        final editingPreset = provider.editingPreset;

        if (editingPreset == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("CUBE BABY CONTROL")),
            body: const Center(child: Text("Carregue uma música do setlist.")),
          );
        }

        final originalScene = provider.currentSong?.scenes[provider.activeSceneKey];
        final bool isDirty = originalScene?.toMap().toString() != editingPreset.toMap().toString();

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: AppBar(
            title: Text(provider.currentSong?.title ?? "CUBE BABY CONTROL"),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: isDirty ? Colors.white : Colors.grey),
                onPressed: isDirty ? () => _handleReset(context) : null,
              ),
              IconButton(
                icon: Icon(Icons.save, color: isDirty ? Colors.orange : Colors.grey),
                onPressed: isDirty ? () => _handleSave(context) : null,
              ),
              IconButton(
                icon: const Icon(Icons.queue_music, color: Colors.orange),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SetlistScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.bluetooth_searching),
                onPressed: () => BluetoothService().startScanAndConnect(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ["A", "B", "C"].map((label) => _buildPresetButton(context, label, provider, isDirty)).toList(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: Colors.white10),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 0.8,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        PedalKnob(key: ValueKey('vol_${provider.activeSceneKey}'), label: "VOLUME", value: editingPreset.vol, onChanged: (v) => provider.updateEditingParameter("vol", v)),
                        PedalKnob(key: ValueKey('type_${provider.activeSceneKey}'), label: "AMP TYPE", value: editingPreset.type, displayValue: _getAmpName(editingPreset.type), onChanged: (v) => provider.updateEditingParameter("type", v)),
                        PedalKnob(key: ValueKey('gain_${provider.activeSceneKey}'), label: "GAIN", value: editingPreset.gain, onChanged: (v) => provider.updateEditingParameter("gain", v)),
                        PedalKnob(key: ValueKey('tone_${provider.activeSceneKey}'), label: "TONE", value: editingPreset.tone, onChanged: (v) => provider.updateEditingParameter("tone", v)),
                        PedalKnob(key: ValueKey('mod_${provider.activeSceneKey}'), label: "MOD", value: editingPreset.mod, displayValue: _getModName(editingPreset.mod), onChanged: (v) => provider.updateEditingParameter("mod", v)),
                        PedalKnob(key: ValueKey('rev_${provider.activeSceneKey}'), label: "REVERB", value: editingPreset.rev, onChanged: (v) => provider.updateEditingParameter("rev", v)),
                        PedalKnob(key: ValueKey('fb_${provider.activeSceneKey}'), label: "DELAY FB", value: editingPreset.fb, onChanged: (v) => provider.updateEditingParameter("fb", v)),
                        PedalKnob(key: ValueKey('time_${provider.activeSceneKey}'), label: "DELAY TIME", value: editingPreset.time, onChanged: (v) => provider.updateEditingParameter("time", v)),
                        PedalKnob(key: ValueKey('ir_${provider.activeSceneKey}'), label: "IR CAB", value: editingPreset.ir, onChanged: (v) => provider.updateEditingParameter("ir", v)),
                      ],
                    ),
                  ),
                ),
                const Divider(color: Colors.white10, height: 40),
                const TapTempoButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPresetButton(BuildContext context, String label, PedalProvider provider, bool isDirty) {
    bool isActive = provider.activeSceneKey == label;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.orange : const Color(0xFF2C2C2C),
        foregroundColor: isActive ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        if (isActive) return;

        if (isDirty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Alterações descartadas ao mudar de cena."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        provider.switchScene(label);
      },
      child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/pedal_model.dart';
import '../models/pedal_models.dart';

class PedalProvider extends ChangeNotifier {
  // --- MANTÉM O CONTRATO ATUAL ---
  PedalModel? _selectedPedal;
  PedalModel? get selectedPedal => _selectedPedal;

  void selectPedal(PedalModel pedal) {
    _selectedPedal = pedal;
    // Quando um pedal é selecionado, inicializamos as cenas para ele
    _initializeScenesForPedal(pedal);
    notifyListeners();
  }

  // --- NOVAS FUNCIONALIDADES (SEM QUEBRAR O ANTIGO) ---

  List<PedalScene> _currentScenes = [];
  int _activeSceneIndex = 0;

  List<PedalScene> get currentScenes => _currentScenes;
  int get activeSceneIndex => _activeSceneIndex;

  PedalScene? get activeScene =>
      _currentScenes.isNotEmpty ? _currentScenes[_activeSceneIndex] : null;

  void _initializeScenesForPedal(PedalModel pedal) {
    // Aqui garantimos que, ao selecionar qualquer pedal,
    // ele já comece com as 3 cenas padrão.
    _currentScenes = [
      PedalScene(id: 'A', customName: 'Cena A', parameters: _loadParamsFor(pedal)),
      PedalScene(id: 'B', customName: 'Cena B', parameters: _loadParamsFor(pedal)),
      PedalScene(id: 'C', customName: 'Cena C', parameters: _loadParamsFor(pedal)),
    ];
  }

  void setActiveScene(int index) {
    _activeSceneIndex = index;
    notifyListeners();
  }

  void updateParameter(int paramIndex, int newValue) {
    if (activeScene != null && activeScene!.parameters.length > paramIndex) {
      activeScene!.parameters[paramIndex].currentValue = newValue;
      notifyListeners();
      // O envio MIDI virá aqui
    }
  }

  // Mock temporário para não quebrar a inicialização
  List<PedalParameter> _loadParamsFor(PedalModel pedal) {
    // No futuro, isso lerá o JSON baseado no pedal.model
    return [
      PedalParameter(name: 'Gain', type: 'CC', controlNumber: 10, currentValue: 50),
      PedalParameter(name: 'Level', type: 'CC', controlNumber: 12, currentValue: 70),
    ];
  }
}
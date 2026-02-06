class PedalPreset {
  String name;
  double vol, ir, rev, mix, fb, time, tone, gain, type, mod;

  PedalPreset({
    required this.name,
    this.vol = 0.5, this.ir = 0.5, this.rev = 0.5,
    this.mix = 0.5, this.fb = 0.5, this.time = 0.5,
    this.tone = 0.5, this.gain = 0.5, this.type = 0.1,
    this.mod = 0.1,
  });

  // Converte o objeto para um Map (para salvar no JSON)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'vol': vol,
      'ir': ir,
      'rev': rev,
      'mix': mix,
      'fb': fb,
      'time': time,
      'tone': tone,
      'gain': gain,
      'type': type,
      'mod': mod,
    };
  }

  // Cria um objeto a partir de um Map (para ler do JSON)
  factory PedalPreset.fromMap(Map<String, dynamic> map) {
    return PedalPreset(
      name: map['name'] ?? "New Scene",
      vol: (map['vol'] ?? 0.5).toDouble(),
      ir: (map['ir'] ?? 0.5).toDouble(),
      rev: (map['rev'] ?? 0.5).toDouble(),
      mix: (map['mix'] ?? 0.5).toDouble(),
      fb: (map['fb'] ?? 0.5).toDouble(),
      time: (map['time'] ?? 0.5).toDouble(),
      tone: (map['tone'] ?? 0.5).toDouble(),
      gain: (map['gain'] ?? 0.5).toDouble(),
      type: (map['type'] ?? 0.1).toDouble(),
      mod: (map['mod'] ?? 0.1).toDouble(),
    );
  }

  void updateParam(String param, double value) {
    switch (param) {
      case 'vol': vol = value; break;
      case 'gain': gain = value; break;
      case 'rev': rev = value; break;
      case 'type': type = value; break;
      case 'tone': tone = value; break;
      case 'mod': mod = value; break;
      case 'fb': fb = value; break;
      case 'time': time = value; break;
      case 'ir': ir = value; break;
    }
  }
}

class CuvaveControl {
  final PedalPreset sceneA;
  final PedalPreset sceneB;
  final PedalPreset sceneC;

  CuvaveControl({
    required this.sceneA,
    required this.sceneB,
    required this.sceneC,
  });

  // Converte de JSON para o Model
  factory CuvaveControl.fromJson(Map<String, dynamic> json) {
    return CuvaveControl(
      sceneA: PedalPreset.fromMap(json['A'] ?? {}),
      sceneB: PedalPreset.fromMap(json['B'] ?? {}),
      sceneC: PedalPreset.fromMap(json['C'] ?? {}),
    );
  }

  // Converte do Model para JSON
  Map<String, dynamic> toJson() {
    return {
      'A': sceneA.toMap(),
      'B': sceneB.toMap(),
      'C': sceneC.toMap(),
    };
  }

  // Atalho para pegar a cena pela chave
  PedalPreset getScene(String key) {
    switch (key.trim().toUpperCase()) {
      case 'B': return sceneB;
      case 'C': return sceneC;
      default: return sceneA;
    }
  }
}
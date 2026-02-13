import 'dart:convert';

class PedalProfile {
  final String brand;
  final String model;
  final List<String> scenes; // ["A", "B", "C"]
  final int sceneOffset; // 16 (0x10)
  final Map<String, List<int>> handshake; // "hello", "confirm"
  final List<PedalParameter> parameters;

  PedalProfile({
    required this.brand,
    required this.model,
    required this.scenes,
    required this.sceneOffset,
    required this.handshake,
    required this.parameters,
  });

  factory PedalProfile.fromJson(Map<String, dynamic> json) {
    var handshakeMap = <String, List<int>>{};
    if (json['handshake'] != null) {
      json['handshake'].forEach((k, v) {
        handshakeMap[k] = (v as String)
            .split(' ')
            .map((e) => int.parse(e, radix: 16))
            .toList();
      });
    }

    var params = <PedalParameter>[];
    if (json['parameters'] != null) {
      params = (json['parameters'] as List)
          .map((e) => PedalParameter.fromJson(e))
          .toList();
    }

    return PedalProfile(
      brand: json['brand'],
      model: json['model'],
      scenes: List<String>.from(json['scenes'] ?? ["A", "B", "C"]),
      sceneOffset: json['scene_offset'] ?? 16,
      handshake: handshakeMap,
      parameters: params,
    );
  }
}

class PedalParameter {
  final String id;
  final String name;
  final int baseAddress;
  final int min;
  final int max;
  final String checksumStrategy;
  final Map<int, List<int>> anchors; // Value -> Anchor Command Bytes

  PedalParameter({
    required this.id,
    required this.name,
    required this.baseAddress,
    required this.min,
    required this.max,
    required this.checksumStrategy,
    required this.anchors,
  });

  factory PedalParameter.fromJson(Map<String, dynamic> json) {
    var anchorMap = <int, List<int>>{};
    if (json['anchors'] != null) {
      json['anchors'].forEach((k, v) {
        // Key is string in JSON, parse to int
        int val = int.parse(k);
        anchorMap[val] = (v as String)
            .split(' ')
            .map((e) => int.parse(e, radix: 16))
            .toList();
      });
    }

    return PedalParameter(
      id: json['id'],
      name: json['name'],
      baseAddress: json['base_address'],
      min: json['min'],
      max: json['max'],
      checksumStrategy: json['checksum_strategy'] ?? "scene_offset_0x20",
      anchors: anchorMap,
    );
  }
}

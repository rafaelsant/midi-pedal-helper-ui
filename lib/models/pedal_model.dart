import 'package:flutter/material.dart';

/// Define as características fixas do Pedal (Catálogo)
class PedalModel {
  final String brand;
  final String model;
  final String imagePath;
  final Color accentColor;

  PedalModel({
    required this.brand,
    required this.model,
    required this.imagePath,
    required this.accentColor,
  });
}

/// Define um parâmetro individual (ex: Gain, Reverb Level)
class PedalParameter {
  final String name;
  final String type; // CC ou SYSEX
  final int controlNumber;
  int currentValue;

  PedalParameter({
    required this.name,
    required this.type,
    required this.controlNumber,
    this.currentValue = 0,
  });

  // Método para criar uma cópia real do objeto e não apenas uma referência
  PedalParameter copy() => PedalParameter(
    name: name,
    type: type,
    controlNumber: controlNumber,
    currentValue: currentValue,
  );
}

/// Define uma Cena (A, B ou C) com nome editável
class PedalScene {
  final String id; // A, B, ou C
  String customName;
  List<PedalParameter> parameters;

  PedalScene({
    required this.id,
    required this.customName,
    required this.parameters,
  });

  // Deep copy da cena para manipulação em "draft"
  PedalScene copy() => PedalScene(
    id: id,
    customName: customName,
    parameters: parameters.map((p) => p.copy()).toList(),
  );
}
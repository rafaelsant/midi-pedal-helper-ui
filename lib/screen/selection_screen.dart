import 'package:flutter/material.dart';
import 'package:midi_pedal_manager/screen/cube_baby_control_screen.dart';
import '../models/pedal_model.dart';

class PedalSelectionScreen extends StatelessWidget {
  final List<PedalModel> pedals = [
    PedalModel(
      brand: "M-VAVE",
      model: "Cube Baby",
      imagePath: "assets/cube_baby.png", // Adicione as imagens depois
      accentColor: Colors.orangeAccent,
    ),
    PedalModel(
      brand: "VALETON",
      model: "GP200 LT",
      imagePath: "assets/gp200.png",
      accentColor: Colors.redAccent,
    ),
    PedalModel(
      brand: "CUSTOM",
      model: "Generic MIDI",
      imagePath: "assets/midi_generic.png",
      accentColor: Colors.blueAccent,
    ),
  ];

  PedalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fundo quase preto
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'MEU RIG MIDI',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Selecione o seu equipamento:",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: pedals.length,
              itemBuilder: (context, index) {
                final pedal = pedals[index];
                return _buildPedalCard(context, pedal);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPedalCard(BuildContext context, PedalModel pedal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: pedal.accentColor.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // Detalhe de cor lateral
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 5,
              decoration: BoxDecoration(
                color: pedal.accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pedal.brand,
                      style: TextStyle(
                        color: pedal.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      pedal.model,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.settings_input_component,
                  size: 50,
                  color: Colors.white.withOpacity(0.1),
                ),
              ],
            ),
          ),
          // Botão Invisível para seleção
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CubeBabyControlScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

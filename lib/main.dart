import 'package:flutter/material.dart';
import 'package:midi_pedal_manager/providers/pedal_provider.dart';
import 'package:midi_pedal_manager/screen/selection_screen.dart';
import 'package:provider/provider.dart'; // Importe sua tela aqui

void main() {

  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PedalProvider()),
          ],
      child:  MidiPedalManager()
      )
  );
}

class MidiPedalManager extends StatelessWidget {
  const MidiPedalManager({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove a faixa de debug
      title: 'MIDI Pedal Manager',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: PedalSelectionScreen(), // Chama a sua classe criada no arquivo
    );
  }
}

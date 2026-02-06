import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class TapTempoButton extends StatefulWidget {
  const TapTempoButton({super.key});

  @override
  State<TapTempoButton> createState() => _TapTempoButtonState();
}

class _TapTempoButtonState extends State<TapTempoButton> {
  bool _isPressed = false;
  // INICIALIZAÇÃO CRÍTICA: Nunca deixe apenas "List<DateTime> _taps;"
  final List<DateTime> _taps = [];

  // O controller também deve ser final e inicializado
  final TextEditingController _bpmController = TextEditingController(text: "0");

  @override
  void dispose() {
    _bpmController.dispose(); // Boa prática: liberar memória
    super.dispose();
  }

  void _updateBPM(double bpm) {
    if (!mounted) return;
    setState(() {
      _bpmController.text = bpm.toStringAsFixed(0);
    });
  }

  void _handleTap() {
    _handleVisualEffect();
    final now = DateTime.now();

    // Lógica para resetar se o intervalo for muito longo (> 2s)
    if (_taps.isNotEmpty) {
      if (now.difference(_taps.last).inMilliseconds > 2000) {
        _taps.clear();
      }
    }

    _taps.add(now);

    if (_taps.length > 4) {
      _taps.removeAt(0);
    }

    if (_taps.length >= 2) {
      double totalMs = 0;
      for (int i = 0; i < _taps.length - 1; i++) {
        totalMs += _taps[i + 1].difference(_taps[i]).inMilliseconds;
      }
      double averageMs = totalMs / (_taps.length - 1);
      _updateBPM(60000 / averageMs);
    }
  }

  void _handleVisualEffect() {
    HapticFeedback.mediumImpact();
    setState(() => _isPressed = true);
    Timer(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E1E1E),
              border: Border.all(color: Colors.orange, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(_isPressed ? 0.6 : 0.1),
                  blurRadius: _isPressed ? 20 : 5,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "TAP",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 100,
          child: TextField(
            controller: _bpmController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, color: Colors.orangeAccent),
            decoration: const InputDecoration(
              labelText: "BPM",
              labelStyle: TextStyle(color: Colors.orange),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange),
              ),
            ),
            onChanged: (value) {
              double? typedBpm = double.tryParse(value);
              if (typedBpm != null && typedBpm > 0) {
                // Aqui poderíamos recalcular o MS para enviar ao pedal futuramente
              }
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class PedalKnob extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final String? displayValue;

  const PedalKnob({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.displayValue,
  });

  @override
  State<PedalKnob> createState() => _PedalKnobState();
}

class _PedalKnobState extends State<PedalKnob> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    // Inicializa o estado interno com o valor recebido.
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(PedalKnob oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se o valor vindo do pai (provider) mudar (ex: troca de cena),
    // e for diferente do nosso valor atual, atualizamos o estado interno.
    if (widget.value != _currentValue) {
      setState(() {
        _currentValue = widget.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label.toUpperCase(),
            style: TextStyle(fontSize: 10, color: Colors.orange.withOpacity(0.7), fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFF2A2A2A), Color(0xFF121212)],
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: Offset(0, 2))
                ]
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: (_currentValue * 4.2) - 2.1, // Usa o estado interno
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 3, height: 12,
                      margin: EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [BoxShadow(color: Colors.orangeAccent, blurRadius: 5)]
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
          ),
          child: Slider(
            value: _currentValue, // Usa o estado interno
            onChanged: (newValue) {
              // Atualiza o estado interno para feedback visual imediato.
              setState(() {
                _currentValue = newValue;
              });
              // Notifica o pai (provider) sobre a mudança.
              widget.onChanged(newValue);
            },
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white10)
          ),
          child: Text(
            widget.displayValue ?? "${(_currentValue * 100).toInt()}", // Usa o estado interno
            style: TextStyle(fontSize: 9, color: Colors.orangeAccent, fontFamily: 'monospace'),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

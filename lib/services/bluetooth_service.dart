import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb; // Usando prefixo
import 'dart:async';

class BluetoothService {
  // Singleton para garantir que só exista uma instância controlando o bluetooth
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  fb.BluetoothDevice? targetDevice;
  fb.BluetoothCharacteristic? writeCharacteristic;

  Future<void> startScanAndConnect() async {
    // Verifica se o Bluetooth está ligado antes de escanear
    if (await fb.FlutterBluePlus.adapterState.first != fb.BluetoothAdapterState.on) {
      print("Bluetooth desligado!");
      return;
    }

    await fb.FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    fb.FlutterBluePlus.scanResults.listen((results) async {
      for (fb.ScanResult r in results) {
        // Procure pelo nome que você definirá no código do seu ESP32
        if (r.device.platformName == "ESP32_MIDI_HUB" || r.device.remoteId.str == "SEU_MAC_ADDRESS_SE_SOUBER") {
          targetDevice = r.device;
          await fb.FlutterBluePlus.stopScan();

          try {
            await targetDevice!.connect();
            _discoverServices();
          } catch (e) {
            print("Erro ao conectar: $e");
          }
          break;
        }
      }
    });
  }

  void _discoverServices() async {
    if (targetDevice == null) return;

    // Aqui usamos o prefixo para o Dart saber que é o serviço da biblioteca
    List<fb.BluetoothService> services = await targetDevice!.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        // Procuramos uma característica que aceite escrita (Write)
        if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
          writeCharacteristic = characteristic;
          print("Canal de comunicação MIDI estabelecido!");
        }
      }
    }
  }

  Future<void> sendMidiCommand(List<int> bytes) async {
    if (writeCharacteristic != null) {
      try {
        await writeCharacteristic!.write(bytes, withoutResponse: true);
      } catch (e) {
        print("Erro ao enviar comando: $e");
      }
    } else {
      print("Não conectado ao ESP32");
    }
  }
}
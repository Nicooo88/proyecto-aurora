import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;

class BTService {
  static ble.BluetoothDevice? _device;
  static ble.BluetoothCharacteristic? _characteristic;
  static bool _conectado = false;

  static bool get conectado => _conectado;

  static Function(Map<String, dynamic>)? onDatosRecibidos;
  static Function(bool)? onConexionCambiada;

  static const String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String CHAR_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  static Future<List<ble.ScanResult>> buscarDispositivos() async {
    List<ble.ScanResult> resultados = [];

    await ble.FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    await for (List<ble.ScanResult> results in ble.FlutterBluePlus.scanResults) {
      resultados = results
          .where((r) => r.device.platformName.isNotEmpty)
          .toList();
    }

    return resultados;
  }

  static Future<bool> conectar(ble.BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _device = device;

      List<ble.BluetoothService> services = await device.discoverServices();

      for (ble.BluetoothService service in services) {
        if (service.uuid.toString() == SERVICE_UUID) {
          for (ble.BluetoothCharacteristic char in service.characteristics) {
            if (char.uuid.toString() == CHAR_UUID) {
              _characteristic = char;
              await char.setNotifyValue(true);
              char.onValueReceived.listen((value) {
                try {
                  final json = jsonDecode(utf8.decode(value));
                  onDatosRecibidos?.call(json);
                } catch (e) {
                  print('Error parseando BLE: $e');
                }
              });
            }
          }
        }
      }

      _conectado = true;
      onConexionCambiada?.call(true);

      device.connectionState.listen((state) {
        if (state == ble.BluetoothConnectionState.disconnected) {
          _conectado = false;
          onConexionCambiada?.call(false);
        }
      });

      return true;
    } catch (e) {
      print('Error conectando BLE: $e');
      _conectado = false;
      return false;
    }
  }

  static Future<void> enviarAccion(String accion, {int? angulo}) async {
    if (!_conectado || _characteristic == null) return;
    try {
      final Map<String, dynamic> datos = {'accion': accion};
      if (angulo != null) datos['angulo'] = angulo;
      final bytes = utf8.encode(jsonEncode(datos));
      await _characteristic!.write(bytes);
    } catch (e) {
      print('Error enviando BLE: $e');
    }
  }

  static Future<void> desconectar() async {
    await _device?.disconnect();
    _conectado = false;
    onConexionCambiada?.call(false);
  }
}
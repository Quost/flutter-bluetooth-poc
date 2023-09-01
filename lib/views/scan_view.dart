import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  ScanViewState createState() => ScanViewState();
}

class ScanViewState extends State<ScanView> {
  final int _minRSSI = -100;
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  Future<void> _startScanning() async {
    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          results = results.where((result) {
            final macAddress = result.device.remoteId.toString();
            return macAddress.startsWith('38:31:AC');
          }).toList();

          results.sort((a, b) => b.rssi.compareTo(a.rssi));
          _scanResults = results;
        });
      }
    });

    if (mounted) {
      setState(() {
        _isScanning = true;
      });
    }

    await FlutterBluePlus.startScan(
      scanMode: ScanMode.lowPower,
    );
  }

  Future<void> _connectAndPairToDevice(BluetoothDevice device) async {
    try {
      device.connect(autoConnect: false);
    } catch (e) {
      // Lida com erros de conexão ou emparelhamento aqui.
      if (kDebugMode) {
        print('Erro ao conectar/emparelhar com o dispositivo: $e');
      }
    }
  }

  @override
  void dispose() {
    _isScanning = false;
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // "Scanning for devices" with a loading icon
        title: const Text('Scanning for devices'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircularProgressIndicator(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              _isScanning = false;
              FlutterBluePlus.stopScan();
              Navigator.of(context).pop(); // Volte para a tela anterior.
            },
            child: const Text('Stop Scanning'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _scanResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_scanResults[index].device.localName.isEmpty
                      ? "<Unknown device's name>"
                      : _scanResults[index].device.localName),
                  subtitle:
                      Text(_scanResults[index].device.remoteId.toString()),
                  trailing: Icon(_getRSSIIcon(_scanResults[index].rssi)),
                  onTap: () {
                    _connectAndPairToDevice(_scanResults[index].device);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

_getRSSIIcon(int rssi) {
  if (rssi >= -50) {
    return Icons.signal_wifi_4_bar;
  } else if (rssi >= -60) {
    return Icons.network_wifi_3_bar;
  } else if (rssi >= -70) {
    return Icons.network_wifi_2_bar;
  } else if (rssi >= -80) {
    return Icons.network_wifi_1_bar;
  } else {
    return Icons.signal_wifi_0_bar;
  }
}

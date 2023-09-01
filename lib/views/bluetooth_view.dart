import 'package:bluetooth_poc/views/scan_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothView extends StatefulWidget {
  const BluetoothView({super.key});

  @override
  BluetoothViewState createState() => BluetoothViewState();
}

class BluetoothViewState extends State<BluetoothView> {
  List<BluetoothDevice> _pairedDevices = [];

  @override
  void initState() {
    super.initState();
    _getPairedDevices();
  }

  Future<void> _getPairedDevices() async {
    List<BluetoothDevice> pairedDevices =
        await FlutterBluePlus.connectedSystemDevices;
    if (mounted) {
      setState(() {
        _pairedDevices = pairedDevices;
      });
    }
  }

  Future<void> _disconnectDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      await device.removeBond();
      // Atualize a lista de dispositivos após desconectar.
      _getPairedDevices();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao desconectar o dispositivo: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth PoC App'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: _getPairedDevices,
            child: const Text('Refresh Paired Devices'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _pairedDevices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_pairedDevices[index].localName),
                  subtitle: Text(_pairedDevices[index].remoteId.toString()),
                  onTap: () {
                    // Implemente a lógica para conectar ao dispositivo aqui.
                  },
                  trailing: ElevatedButton(
                    onPressed: () {
                      _disconnectDevice(_pairedDevices[index]);
                    },
                    child: const Text('Desemparear'),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ScanView(),
              ));
            },
            child: const Text('Start Scanning'),
          ),
        ],
      ),
    );
  }
}

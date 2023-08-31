import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// quero fazer um aplicativo que use bluetooth.
/// Pode ser via package flutter_blue_plus.
/// Quero em uma tela inicial mostrar os dispositivos pareados, e ter um botao de scan.
/// A lista de devices pareados terá a opção de enviar um comando, ou desparear.
/// Ao clicar no botão de scan, abre uma nova tela e mostra os nearby devices.
/// Ao clicar em um nearby device, emparelha com o mesmo.

class BluetoothView extends StatefulWidget {
  const BluetoothView({super.key});

  @override
  BluetoothViewState createState() => BluetoothViewState();
}

class BluetoothViewState extends State<BluetoothView> {
  final StreamController<List<ScanResult>> _devicesStreamController =
      StreamController<List<ScanResult>>();

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.setLogLevel(LogLevel.debug, color: true);
  }

  Future<void> _enableBluetooth() async {
    // check adapter availability
    if (await FlutterBluePlus.isAvailable == false) {
      if (kDebugMode) {
        print("Bluetooth not supported by this device");
      }
      return;
    }

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    // wait bluetooth to be on & print states
    await FlutterBluePlus.adapterState
        .map((s) {
          if (kDebugMode) {
            print(s);
          }
          return s;
        })
        .where((s) => s == BluetoothAdapterState.on)
        .first;
  }

  void _startScan({int scanTimeInSeconds = 4}) {
    FlutterBluePlus.startScan(timeout: Duration(seconds: scanTimeInSeconds));
  }

  Future<void> _stopScan({int? delayTimeInMs}) async {
    if (delayTimeInMs != null) {
      await Future.delayed(Duration(milliseconds: delayTimeInMs));
    }
    await FlutterBluePlus.stopScan();
  }

  Future<void> _scanForDevices() async {
    // Setup listener for scan results
    FlutterBluePlus.scanResults.listen((results) {
      _devicesStreamController.add(results);
    });

    _startScan();
    _setPeriodicTimer(
      counter: 1,
      durationInSeconds: 10,
      periodicFunction: _stopScan,
    );
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    // listen for disconnection
    device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        // typically, start a periodic timer that tries to periodically reconnect.
        // Note: you must always re-discover services after disconnection!
      }
    });

    // Connect to the device
    await device.connect();

    // Disconnect from device
    await device.disconnect();
  }

  Future<void> _setPeriodicTimer(
      {required int counter,
      required int durationInSeconds,
      required Function() periodicFunction}) async {
    Timer.periodic(Duration(seconds: durationInSeconds), (timer) async {
      periodicFunction();
    });
  }

  @override
  Widget build(BuildContext context) {
    /// quero fazer um aplicativo que use bluetooth.
    /// Pode ser via package flutter_blue_plus.
    /// Quero em uma tela inicial mostrar os dispositivos pareados, e ter um botao de scan.
    /// A lista de devices pareados terá a opção de enviar um comando, ou desparear.
    /// Ao clicar no botão de scan, abre uma nova tela e mostra os nearby devices.
    /// Ao clicar em um nearby device, emparelha com o mesmo.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth PoC App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: _enableBluetooth,
              child: const Text('Enable Bluetooth'),
            ),
            TextButton(
              onPressed: _scanForDevices,
              child: const Text('Scan for devices'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Connect to device'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Send command'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Disconnect'),
            ),
            StreamBuilder<List<ScanResult>>(
              stream: _devicesStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No devices found.');
                } else {
                  return Column(
                    children: [
                      for (var device in snapshot.data!) ...[
                        ListTile(
                          title: Text(device.device.localName.isEmpty
                              ? 'Unknown Device'
                              : device.device.localName),
                          subtitle: Text('RSSI: ${device.rssi}'),
                          onTap: () {
                            _connectToDevice(device
                                .device); // Adicione a lógica para emparelhar com o dispositivo aqui
                          },
                        ),
                        const Divider(),
                      ],
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

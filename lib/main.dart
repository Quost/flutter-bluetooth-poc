import 'dart:io';

import 'package:bluetooth_poc/views/bluetooth_view.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request().then((status) {
      runApp(const BluetoothPocApp());
    });
  } else {
    runApp(const BluetoothPocApp());
  }
}

class BluetoothPocApp extends StatelessWidget {
  const BluetoothPocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth PoC App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BluetoothView(),
    );
  }
}

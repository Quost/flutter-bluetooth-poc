import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  final VoidCallback enableBluetooth;
  final VoidCallback scanForDevices;

  const HomeView(
      {super.key, required this.enableBluetooth, required this.scanForDevices});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth PoC App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: enableBluetooth,
              child: const Text('Enable Bluetooth'),
            ),
            TextButton(
              onPressed: scanForDevices,
              child: const Text('Scan for devices'),
            ),
            // Outros botões e widgets aqui
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BatteryDemoPage extends StatefulWidget {
  const BatteryDemoPage({super.key});

  @override
  State<BatteryDemoPage> createState() => _BatteryDemoPageState();
}

class _BatteryDemoPageState extends State<BatteryDemoPage> {
  static const _channel = MethodChannel('battery_channel');

  String result = "No data yet";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Android & iOS Battery Demo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: getAndroidBattery,
              child: const Text("Get Android Battery"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: getIosBattery,
              child: const Text("Get iOS Battery"),
            ),

            const SizedBox(height: 30),

            Text(result, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

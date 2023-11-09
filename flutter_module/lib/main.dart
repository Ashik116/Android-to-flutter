import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('getEPC');
  String dataFromNative = "No Data";

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      if (call.method == "receiveEPCString") {
        setState(() {
          dataFromNative = call.arguments as String;
        });
      }
    });

    // Trigger the method channel to start receiving data
    startReceivingData();
  }

  Future<void> startReceivingData() async {
    try {
      await platform.invokeMethod('getData');
    } on PlatformException catch (e) {
      print("Failed to get data from native: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter App with Kotlin Integration'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Data from Kotlin:',
              ),
              Text(
                dataFromNative,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
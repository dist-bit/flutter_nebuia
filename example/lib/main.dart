import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:nebuia_plugin/nebuia_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  Uint8List fingerIndex = Uint8List.fromList([]);

  @override
  void initState() {
    super.initState();
   // initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    NebuiaPlugin.setReport = "61ef054041522a08818e3265";
    NebuiaPlugin.setTemporalCode = "98595191";
    //NebuiaPlugin.setClientURI = "http://192.168.1.104:3000/api/v1/services";
    Fingers? fingers = await NebuiaPlugin.fingerDetection(0);
    print(fingers);
    /* String? videoPath = await NebuiaPlugin.recordActivity(['TEXTO 1', 'TEXTO 2']);
    if(videoPath != null) {
      print(videoPath);
    }
    LinkedHashMap? fingers = await NebuiaPlugin.fingerDetection(0);
    if(fingers != null) {
     setState(() => fingerIndex = Uint8List.fromList(fingers['index']!));
    }

    LinkedHashMap? address = await NebuiaPlugin.captureAddressProof;
    if(address != null) {
      print(address);
    }

    Uint8List? face = await NebuiaPlugin.getIDFrontImage;
    if(face != null) {
      setState(() => fingerIndex = Uint8List.fromList(face));
    }

    await NebuiaPlugin.saveEmail('miguel@distbit.io');
    bool status = await NebuiaPlugin.generateOTPEmail;
    print(status);

    LinkedHashMap? fingers = await NebuiaPlugin.fingerDetection(0);
    if(fingers != null) {
      setState(() => fingerIndex = Uint8List.fromList(fingers['index']!));
    }

    Uint8List? wsq = await NebuiaPlugin.generateWSQFingerprint(fingerIndex);

    if(wsq != null) {
      print(wsq);
      String s = String.fromCharCodes(wsq);
      print(s);
    }

    String? path = await NebuiaPlugin.recordActivity(['texto1', 'texto2', 'texto3']);

    if(path != null) {
      print(path);
    }

    await NebuiaPlugin.documentDetection;

     */

    LinkedHashMap? address = await NebuiaPlugin.captureAddressProof;
    if(address != null) {
      print(address);
    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: TextButton(child: Text('Prueba'), onPressed: () => initPlatformState(),),
            ),
            if(fingerIndex.isNotEmpty)
              Image.memory(fingerIndex)
          ],
        ),
      ),
    );
  }
}

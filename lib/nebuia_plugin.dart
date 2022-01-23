
import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class NebuiaPlugin {
  static const MethodChannel _channel = MethodChannel('nebuia_plugin');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static set setReport(String report) {
    _channel.invokeMethod('setReport', {
      'report': report
    });
  }

  static set setClientURI(String uri) {
    _channel.invokeMethod('setClientURI', {
      'uri': uri
    });
  }

  static set setTemporalCode(String code) {
    _channel.invokeMethod('setTemporalCode', {
      'code': code
    });
  }

  static Future<String?> get createReport async {
    final String? report = await _channel.invokeMethod('createReport', {});
    return report;
  }

  static Future<void> get faceLiveDetection async {
    await _channel.invokeMethod('faceLiveDetection', {});
  }

  static Future<LinkedHashMap?> fingerDetection(int hand) async {
    final LinkedHashMap? fingers = await _channel.invokeMethod('fingerDetection', {
      'hand': hand
    });

    return fingers;
  }

  static Future<Uint8List?> generateWSQFingerprint(Uint8List image) async {
    final Uint8List? wsq = await _channel.invokeMethod('generateWSQFingerprint', {
      'image': image
    });

    return wsq;
  }

  static Future<String?> recordActivity(List<String> text) async {
    final String? path = await _channel.invokeMethod('recordActivity', {
      'text': text
    });

    return path;
  }

  static Future<void> get documentDetection async {
    await _channel.invokeMethod('documentDetection', {});
  }

  static Future<LinkedHashMap?> get captureAddressProof async {
    final LinkedHashMap? address = await _channel.invokeMethod('captureAddressProof', {});
    return address;
  }

  static Future<bool> saveAddress(String address) async {
    final bool status = await _channel.invokeMethod('saveAddress', {
      'address': address
    });

    return status;
  }

  static Future<bool> saveEmail(String email) async {
    final bool status = await _channel.invokeMethod('saveEmail', {
      'email': email
    });

    return status;
  }

  static Future<bool> savePhone(String phone) async {
    final bool status = await _channel.invokeMethod('savePhone', {
      'phone': phone
    });

    return status;
  }

  static Future<bool> get generateOTPEmail async {
    final bool status = await _channel.invokeMethod('generateOTPEmail', { });
    return status;
  }

  static Future<bool> get generateOTPPhone async {
    final bool status = await _channel.invokeMethod('generateOTPPhone', { });
    return status;
  }

  static Future<bool> verifyOTPEmail(String code) async {
    final bool status = await _channel.invokeMethod('verifyOTPEmail', {
      'code': code
    });

    return status;
  }

  static Future<bool> verifyOTPPhone(String code) async {
    final bool status = await _channel.invokeMethod('verifyOTPPhone', {
      'code': code
    });

    return status;
  }

  static Future<Uint8List?> get getFaceImage async {
    final Uint8List? face = await _channel.invokeMethod('getFaceImage', { });
    return face;
  }

  static Future<Uint8List?> get getIDFrontImage async {
    final Uint8List? idFront = await _channel.invokeMethod('getIDFrontImage', { });
    return idFront;
  }

  static Future<Uint8List?> get getIDBackImage async {
    final Uint8List? idBack = await _channel.invokeMethod('getIDBackImage', { });
    return idBack;
  }
}

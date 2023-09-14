import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';

import 'fingers.dart';

export 'fingers.dart';

class NebuiaPlugin {
  static const MethodChannel _channel = MethodChannel(
    'nebuia_plugin',
  );

  static set setReport(
    String report,
  ) {
    _channel.invokeMethod(
      'setReport',
      {
        'report': report,
      },
    );
  }

  static set setClientURI(
    String uri,
  ) {
    _channel.invokeMethod(
      'setClientURI',
      {
        'uri': uri,
      },
    );
  }

  static set setTemporalCode(
    String code,
  ) {
    _channel.invokeMethod(
      'setTemporalCode',
      {
        'code': code,
      },
    );
  }

  static Future<String?> get createReport async {
    final report = await _channel.invokeMethod<String>(
      'createReport',
      {},
    );
    return report;
  }

  static Future<bool?> faceLiveDetection({
    required bool showId,
  }) async {
    final status = await _channel.invokeMethod<bool>(
      'faceLiveDetection',
      {
        'showID': showId,
      },
    );
    return status;
  }

  static Future<Fingers?> fingerDetection({
    required int hand,
    required bool skipStep,
  }) async {
    final result = await _channel.invokeMethod(
      'fingerDetection',
      {
        'hand': hand,
        'skip': skipStep,
      },
    );

    if (result is String) {
      return const Fingers(
        index: null,
        middle: null,
        ring: null,
        little: null,
        skip: true,
      );
    }

    final LinkedHashMap? fingers = result;

    if (fingers == null) {
      return null;
    }

    return Fingers(
      index: Finger(
        image: fingers['index']['image'],
        score: fingers['index']['score'],
      ),
      middle: Finger(
        image: fingers['middle']['image'],
        score: fingers['middle']['score'],
      ),
      ring: Finger(
        image: fingers['ring']['image'],
        score: fingers['ring']['score'],
      ),
      little: Finger(
        image: fingers['little']['image'],
        score: fingers['little']['score'],
      ),
      skip: fingers['skip'],
    );
  }

  static Future<Uint8List?> generateWSQFingerprint({
    required Uint8List image,
  }) async {
    final wsq = await _channel.invokeMethod<Uint8List>(
      'generateWSQFingerprint',
      {
        'image': image,
      },
    );

    return wsq;
  }

  static Future<Uint8List?> genericCapture() async {
    final image = await _channel.invokeMethod<Uint8List>(
      'genericCapture',
      {},
    );

    return image;
  }

  static Future<String?> recordActivity({
    required List<String> text,
    required bool getNameFromId,
  }) async {
    final path = await _channel.invokeMethod<String>(
      'recordActivity',
      {
        'text': text,
        'getNameFromId': getNameFromId,
      },
    );

    return path;
  }

  static Future<bool> get documentDetection async {
    return await _channel.invokeMethod(
      'documentDetection',
      {},
    );
  }

  static Future<LinkedHashMap?> get captureAddressProof async {
    final address = await _channel.invokeMethod<LinkedHashMap>(
      'captureAddressProof',
      {},
    );

    return address;
  }

  static Future<LinkedHashMap?> saveAddress({
    required String address,
  }) async {
    final result = await _channel.invokeMethod<LinkedHashMap>(
      'saveAddress',
      {
        'address': address,
      },
    );

    return result;
  }

  static Future<bool> saveEmail({
    required String email,
  }) async {
    final status = await _channel.invokeMethod<bool>(
      'saveEmail',
      {
        'email': email,
      },
    );

    return status!;
  }

  static Future<bool> savePhone({
    required String phone,
  }) async {
    final status = await _channel.invokeMethod<bool>(
      'savePhone',
      {
        'phone': phone,
      },
    );

    return status!;
  }

  static Future<bool> get generateOTPEmail async {
    final status = await _channel.invokeMethod<bool>(
      'generateOTPEmail',
      {},
    );

    return status!;
  }

  static Future<bool> get generateOTPPhone async {
    final status = await _channel.invokeMethod<bool>(
      'generateOTPPhone',
      {},
    );

    return status!;
  }

  static Future<bool> verifyOTPEmail({
    required String code,
  }) async {
    final status = await _channel.invokeMethod<bool>(
      'verifyOTPEmail',
      {
        'code': code,
      },
    );

    return status!;
  }

  static Future<bool> verifyOTPPhone({
    required String code,
  }) async {
    final status = await _channel.invokeMethod<bool>(
      'verifyOTPPhone',
      {
        'code': code,
      },
    );

    return status!;
  }

  static Future<Uint8List?> get getFaceImage async {
    final face = await _channel.invokeMethod<Uint8List>(
      'getFaceImage',
      {},
    );

    return face;
  }

  static Future<Uint8List?> get getIDFrontImage async {
    final idFront = await _channel.invokeMethod<Uint8List>(
      'getIDFrontImage',
      {},
    );

    return idFront;
  }

  static Future<Uint8List?> get getIDBackImage async {
    final idBack = await _channel.invokeMethod<Uint8List>(
      'getIDBackImage',
      {},
    );

    return idBack;
  }

  static Future<LinkedHashMap> get reportData async {
    final data = await _channel.invokeMethod<LinkedHashMap>(
      'getReportData',
      {},
    );

    return data!;
  }

  static Future<LinkedHashMap> get getSignatureTemplates async {
    final data = await _channel.invokeMethod<LinkedHashMap>(
      'getSignatureTemplates',
      {},
    );

    print(getSignatureTemplates);
    return data!;
  }
}

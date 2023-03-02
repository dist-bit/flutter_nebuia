# NebuIA

[![N|Nebula](https://i.ibb.co/DC46xJv/banner-min.png)](https://nebuia.com)

## Introduction

NebuIA Native Core is a library for NebuIA services integration. NebuIA use platform native channels and run over native
languages Objective-C for iOS and Kotlin/Java for Android.

NebuIA is a Deep Learning library and supports:

- Face detection and auto crop
- Proof of life in real time
  - Darkened images
  - Office fluorescent lighting
  - Office with lighting turned off, illuminated only by natural sunlight
  - Supported attacks
    - Printing
    - 2D Mask
    - 2 Replay
- Document detection in real time
  - Faster and best accuracy than conventional ID Detector (95%)
  - Supports auto cropping
- Proof of address
  - Automatic address extraction
- Typical OTP verifications for email and phone number via SMS
  - Time-Based One-Time Password (TOTP)
  - HMAC-Based One-Time Password (HOTP)
  * [RFC 4226: "RFC 4226 HOTP: An HMAC-Based One-Time Password Algorithm"](https://www.ietf.org/rfc/rfc4226.txt)
  * [RFC 6238: "TOTP: Time-Based One-Time Password Algorithm"](https://tools.ietf.org/html/rfc6238)

## Requirements

- Flutter 2 - Null safety

## Integration

Add `nebuia_plugin` to your project:

```yaml
nebuia_plugin: ^x.x.x
```

For Android, add public and private keys to your `values.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="nebuia_public_key">S5PS103-RHWM8E8-*******-7GQ0NX1</string>
    <string name="nebuia_secret_key">c96d9080-c479-4439-****-b1523c2e0af4</string>
</resources>
```

For iOS, add public and private keys to your `Info.plist`:

```xml
<key>NebuIAPublicKey</key>
<string>S5PS103-RHWM8E8-*******-7GQ0NX1</string>
<key>NebuIASecretKey</key>
<string>c96d9080-c479-4439-****-b1523c2e0af4</string>
```

## Sample Integration

```dart
import 'package:nebuia_plugin/nebuia_plugin.dart';

// Set client endpoint (only if you need custom client installation) - omit for default services.
NebuiaPlugin.setClientURI = 'https://my.endpoint.com/api/v1/services';

// Call your service for temporal code generation.
// Code is response number string.
NebuiaPlugin.setTemporalCode = code;

// Create a new report.
// Store `generatedReport` in your database for future usage.
final String? generatedReport = await NebuiaPlugin.createReport;

// If you already have a report:
NebuiaPlugin.setReport = generatedReport;

// Scan Mexican ID/passport.
final bool wasSuccessful = await NebuiaPlugin.documentDetection;

// Face spoofing test.
final bool? wasSuccessful = await NebuiaPlugin.faceLiveDetection;

// Scan proof of address.
// The result is a `LinkedHashMap` containing all extracted data from
// the address proof sheet.
final LinkedHashMap? address = await NebuiaPlugin.captureAddressProof;

// Save the desired address to NebuIA services.
final LinkedHashMap? address = await NebuiaPlugin.saveAddress(
  address,
);

// Scan hand fingers.
// Left hand: 0.
// Right hand: 1.
Fingers? fingers = await NebuiaPlugin.fingerDetection(
  0,
  false,
);

// Generate WSQ from fingerprint.
// The generated image is returned in bytes.
Uint8List? wsq = await NebuiaPlugin.generateWSQFingerprint(
  image,
);

// save email
bool status = await NebuiaPlugin.saveEmail(email);
// save phone
bool status = await NebuiaPlugin.savePhone(phone);
// send OTP email
bool status = await NebuiaPlugin.generateOTPEmail;
// send OTP phone
bool status = await NebuiaPlugin.generateOTPPhone;
// verify OTP email
bool status = await NebuiaPlugin.verifyOTPEmail(code);
// verify OTP phone
bool status = await NebuiaPlugin.verifyOTPPhone(code);

// Generate record
String? path = await NebuiaPlugin.recordActivity(text);

// get face image
Uint8List? face = NebuiaPlugin.getFaceImage;

// get ID front image
Uint8List? face = NebuiaPlugin.getIDFrontImage;
// get ID back image
Uint8List? face = NebuiaPlugin.getIDBackImage;
```

### Notes

##### Address validation flow sample

Address model sample - generated with josn serializer

```dart
LinkedHashMap? _address = await NebuiaPlugin.captureAddressProof;
if (_address != null) {
        // check address response
        if (_address.containsKey('status')) {
          // check status response
          if (_address['status']) {
            // check if payload is valid response
            if (_address['payload'].runtimeType.toString() ==
                '_InternalLinkedHashMap<Object?, Object?>') {
              var _payload = _address['payload'];
              // if valid and status is true save address
              if (_payload['valid']) {
                // show form address
                try {
                  // try to deserialize address
                  addressModel = AddressModel.fromJson(Map.from(_payload));
                  sendEvent(
                    NebuIAEvent(
                        action: NebuIAAction.addressVerified),
                  );
                } catch (e) {
                  sendEvent(
                    NebuIAEvent(
                        action: NebuIAAction.addressError,
                        message: 'address not found'),
                  );
                }
              } else {
                // verify manual address
                _validateAddress(_payload['address'][0]);
              }
            } else {
              sendEvent(
                NebuIAEvent(
                    action: NebuIAAction.addressError,
                    message: 'address not found'),
              );
            }
          } else {
            sendEvent(
              NebuIAEvent(
                  action: NebuIAAction.addressError,
                  message: 'address not found'),
            );
          }
        } else {
          sendEvent(
            NebuIAEvent(
                action: NebuIAAction.addressError,
                message: 'address not found'),
          );
        }
} else {
    // logic for failed address
}
```

```dart
part 'address.model.g.dart';

@JsonSerializable()
class AddressModel extends BaseNetworkModel<AddressModel> {
  late List<String>? address;
  final List<VerificationsAddress> verifications;
  final ZoneAddress zone;
  final StateAddress state;
  final bool valid;

  // manual input
  late String? street;
  late String? outdoor_number;
  late String? interior_number;

  AddressModel(this.address,
      this.verifications, this.zone, this.state, this.valid);

  factory AddressModel.fromJson(Map<String, dynamic> json) => _$AddressModelFromJson(json);

  @override
  AddressModel fromJson(Map<String, dynamic> json) {
    return AddressModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$AddressModelToJson(this);
}
```

```dart
part 'verifications.address.model.g.dart';

@JsonSerializable()
class VerificationsAddress extends BaseNetworkModel<VerificationsAddress> {
  final String description;
  final bool status;
  String? note;

  VerificationsAddress(this.description, this.note, this.status);

  factory VerificationsAddress.fromJson(Map<String, dynamic> json) => _$VerificationsAddressFromJson(json);

  @override
  VerificationsAddress fromJson(Map<String, dynamic> json) {
    return VerificationsAddress.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$VerificationsAddressToJson(this);
}
```

```dart
part 'state.address.model.g.dart';

@JsonSerializable()
class StateAddress extends BaseNetworkModel<StateAddress> {
  final String complete_name;
  final String abbreviation;
  final String renapo;
  final String two_digits;
  final String three_digits_nomenclature;
  final String key;

  StateAddress(this.complete_name, this.abbreviation, this.renapo,
      this.two_digits, this.three_digits_nomenclature, this.key);

  factory StateAddress.fromJson(Map<String, dynamic> json) => _$StateAddressFromJson(json);

  @override
  StateAddress fromJson(Map<String, dynamic> json) {
    return StateAddress.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$StateAddressToJson(this);
}
```

```dart
part 'zone.address.model.g.dart';

@JsonSerializable()
class ZoneAddress extends BaseNetworkModel<ZoneAddress> {
  final String zip_code;
  final String township;
  final String township_type;
  final String municipality;
  final String state;
  final String city;
  final String cp_id;
  final String state_id;
  final String office_id;
  final String township_type_id;
  final String municipality_id;
  final String township_zip_type_id;
  final String zone;
  final String city_id;

  ZoneAddress(
      this.zip_code,
      this.township,
      this.township_type,
      this.municipality,
      this.state,
      this.city,
      this.cp_id,
      this.state_id,
      this.office_id,
      this.township_type_id,
      this.municipality_id,
      this.township_zip_type_id,
      this.zone,
      this.city_id);

  factory ZoneAddress.fromJson(Map<String, dynamic> json) => _$ZoneAddressFromJson(json);

  @override
  ZoneAddress fromJson(Map<String, dynamic> json) {
    return ZoneAddress.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$ZoneAddressToJson(this);
}

```

##### Fingerprint

On fingerprint scanner end you can pass any finger image to get WSQ File.

```dart
await NebuiaPlugin.generateWSQFingerprint(image);
```

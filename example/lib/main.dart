import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nebuia_plugin/nebuia_plugin.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Uint8List fingerIndex = Uint8List.fromList([]);

  @override
  void initState() {
    super.initState();
    //NebuiaPlugin.setClientURI = "http://192.168.1.104:3000/api/v1/services";
    NebuiaPlugin.setTemporalCode = "000000";
    // SET CLIENT REPORT
    //nebuIA.setReport("62422330ad9791096fd9c4fe")
    NebuiaPlugin.setReport = "62422330ad9791096fd9c4fe";
  }

  Widget _card(
      IconData icon, String title, String subtitle, VoidCallback action) {
    return Card(
      child: ListTile(
        onTap: action,
        leading: Icon(icon),
        title: Text(title,
            style: const TextStyle(
                color: Color(0xff040217), fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: TextStyle(
                color: Colors.grey[600], fontWeight: FontWeight.w400)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: const Color(0xfffdfdfd),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xfffdfdfd),
            title: const Text(
              '',
              style: TextStyle(color: Color(0xff040217)),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: 180.0,
                    height: 180.0,
                    child: Image.asset('assets/images/id_one.png'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                  child: Text(
                    'Necesitamos verificar tu identidad antes de continuar',
                    style: TextStyle(
                        color: Color(0xff040217),
                        fontWeight: FontWeight.w600,
                        fontSize: 22.0),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                  child: Text(
                    'Necesitamos verificar tu identidad antes de continuar, para eso deberas completar los siguientes pasos',
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w400,
                        fontSize: 14.0),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Padding(
                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Column(
                      children: [
                        _card(Icons.email_outlined, 'Verificar email',
                            'Verifica tu email mediante OTP', () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FormPage(
                                    title: 'Verificar email',
                                    item: Verification.email)),
                          );
                        }),
                        _card(
                            Icons.phone_android_outlined,
                            'Verificar teléfono',
                            'Verifica tu teléfono mediante OTP', () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FormPage(
                                    title: 'Verificar teléfono',
                                    item: Verification.phone)),
                          );
                        }),
                        _card(Icons.face, 'Prueba de vida',
                            'Verificación facial y prueba de vida', () async {
                          bool? result = await NebuiaPlugin.faceLiveDetection(
                              showId: false);
                        }),
                        _card(Icons.credit_card, 'Documento de identidad',
                            'Sube tu INE / Pasaporte', () async {
                          bool? result = await NebuiaPlugin.documentDetection;
                        }),
                        _card(
                            Icons.document_scanner,
                            'Comprobante de domicilio',
                            'Comprobante de domicilio', () async {
                          LinkedHashMap? address =
                              await NebuiaPlugin.captureAddressProof;
                          if (address != null) {
                            //print(address);
                          }
                        }),
                        _card(Icons.fingerprint, 'Huellas dactilares',
                            'Escanea tus huellas dactilares', () async {
                          Fingers? fingers = await NebuiaPlugin.fingerDetection(
                              hand: 0, skipStep: false);
                          if (fingers != null) {
                            //print(address);
                          }
                        }),
                      ],
                    )),
              ],
            ),
          )),
    );
  }
}

enum Verification { email, phone }

class FormPage extends StatefulWidget {
  const FormPage({Key? key, required this.title, required this.item})
      : super(key: key);

  final String title;
  final Verification item;

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  String? _itemToValidate;
  String? _OTP;
  bool _showOTPInput = false;

  String? _validateEmail(String? value) {
    if (value != null && value.isEmpty) {
      return 'Ingresa una dirección de correo válida';
    }

    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (value != null) {}
    if (!regex.hasMatch(value!)) {
      return 'Ingresa una dirección de correo válida';
    } else {
      return null;
    }
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isEmpty) {
      return 'Ingresa un número valido';
    }

    if (!value!.startsWith('+')) {
      return 'El número debe iniciar con el código de país';
    }

    return null;
  }

  String? _validateOTP(String? value) {
    if (value != null && value.isEmpty && value.length != 6) {
      return 'Ingresa un código valido';
    }
    return null;
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      bool status = widget.item == Verification.email
          ? await NebuiaPlugin.saveEmail(email: _itemToValidate!)
          : await NebuiaPlugin.savePhone(phone: _itemToValidate!);
      if (status) {
        if (widget.item == Verification.email) {
          _showOTPInput = await NebuiaPlugin.generateOTPEmail;
        } else {
          _showOTPInput = await NebuiaPlugin.generateOTPPhone;
        }

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text("OTP enviado a $_itemToValidate",
              style: TextStyle(color: Colors.white)),
        ));
      }
    }
  }

  void _verifyOTP() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      bool status = widget.item == Verification.email
          ? await NebuiaPlugin.verifyOTPEmail(code: _OTP!)
          : await NebuiaPlugin.verifyOTPPhone(code: _OTP!);
      if (status) {
        FocusManager.instance.primaryFocus?.unfocus();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Código otp correcto",
              style: TextStyle(color: Colors.white)),
        ));

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Código otp incorrecto",
              style: TextStyle(color: Colors.white)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xfffdfdfd),
        iconTheme: const IconThemeData(color: Color(0xff040217)),
        title: Text(widget.title,
            style: const TextStyle(color: Color(0xff040217))),
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: 180,
                    height: 180,
                    child:
                        Image.asset('assets/images/digits_verifications.png'),
                  ),
                  const SizedBox(height: 15.0),
                  Text(
                    widget.item == Verification.email
                        ? 'Ingresa una dirección de correo electrónico válida'
                        : 'Ingresa el número de teléfono a verificar',
                    style: const TextStyle(
                        color: Color(0xff040217),
                        fontWeight: FontWeight.w600,
                        fontSize: 22.0),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    'La verificación por OTP nos permitirá incrementar el nivel de seguridad al permitirnos estar seguro de que el dispositvo sea tuyo.',
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w400,
                        fontSize: 14.0),
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: widget.item == Verification.email
                            ? 'Correo electrónico'
                            : 'Número de teléfono',
                        hintText: widget.item == Verification.email
                            ? ''
                            : '+52 XXXXXXXXX'),
                    keyboardType: TextInputType.emailAddress,
                    validator: widget.item == Verification.email
                        ? _validateEmail
                        : _validatePhone,
                    onSaved: (value) {
                      setState(() => _itemToValidate = value);
                    },
                  ),
                  Visibility(
                      visible: _showOTPInput,
                      child: Column(
                        children: [
                          const SizedBox(height: 30.0),
                          TextFormField(
                            maxLength: 6,
                            decoration: const InputDecoration(
                                labelText: 'Código OTP', hintText: '00000'),
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateOTP,
                            onSaved: (value) {
                              setState(() => _OTP = value);
                            },
                          ),
                        ],
                      )),
                  const SizedBox(height: 30.0),
                  SizedBox(
                    width: 200,
                    height: 55.0,
                    child: TextButton(
                      onPressed: _showOTPInput ? _verifyOTP : _saveItem,
                      child: Text(
                        !_showOTPInput ? 'Solicitar OTP' : 'Verificar OTP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xff0099D8),
                        primary: Colors.white,
                        alignment: Alignment.center,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                ],
              ),
            )),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:secugenfplib/secugenfplib.dart';


class Scanner extends StatefulWidget {

  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {

  final _secugenfplib = Secugenfplib();

  int _timeout_ms = 3000, _quality = 80;

  bool? _isDeviceReady;
  Uint8List? _fpImageBytes, _fpRegisterBytes, _fpVerifyBytes;
  ImageCaptureResult? _firstCaptureResult, _secondCaptureResult;

  @override
  void initState() {
    super.initState();

    _isDeviceReady = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDevice();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [


              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  _fingerprintImage(imageBytes: _fpRegisterBytes),

                  SizedBox(height: 10,),

                  _actionButton(
                    btnText: 'REGISTER FINGER',
                    onPressed: () => _isDeviceReady! ? _captureFirstFinger() : null,
                  ),
                ],
              ),


            ],
          ),
        ),
      ),
    );
  }


  Widget _fingerprintImage({required Uint8List? imageBytes}) {

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * .25,
      color: Colors.grey[200],
      child: imageBytes == null ? SizedBox() : Image.memory(imageBytes, fit: BoxFit.contain),
    );
  }

  Widget _actionButton({required String btnText, required Function()? onPressed}) {

    return ElevatedButton(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(1),
        backgroundColor: MaterialStateProperty.all(Colors.grey[300]),
      ),
      onPressed: onPressed,
      child: Text(btnText,
        style: TextStyle(
          letterSpacing: .65,
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }


  Future<void> _initializeDevice() async {

    try {
      _isDeviceReady = await _secugenfplib.initializeDevice();
    } on SgfplibException catch (e) {
      print(e.message);
      _showAlertDialog(context, e.message!);
    }

  }



  Future<void> _captureFirstFinger() async {

    _fpRegisterBytes = _firstCaptureResult  = null;

    try {
      final captureResult = await _secugenfplib.captureFingerprintWithQuality(timeout: _timeout_ms, quality: _quality);
      _fpRegisterBytes = captureResult!.imageBytes;
      _firstCaptureResult = captureResult;
    } on SgfplibException catch (e) {
      print(e.message);
      _showAlertDialog(context, e.message!);
    }

    setState(() {});
  }




  void _showAlertDialog(BuildContext context, String message) {

    AlertDialog alert = AlertDialog(
      title: Text("SecuGen Fingerprint SDK"),
      content: Text(message),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:groundwater_management/authentication/Role.dart';
import 'package:groundwater_management/l10n/language_picker.dart';
import 'package:groundwater_management/screens/AdminHome.dart';
import 'package:groundwater_management/screens/home.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OTP extends StatefulWidget {
  final String phone;
  OTP(this.phone);
  @override
  _OTPState createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String _verificationCode = '';
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: TextStyle(
      fontSize: 20,
      color: Color.fromRGBO(30, 60, 87, 1),
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.green),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.ver,
        ),
        backgroundColor: Colors.orange!,
        actions: [
            LanguagePicker()
          ],
      ),

      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 40),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 9.0),
                child: Text(
                  AppLocalizations.of(context)!.msg1('+91-${widget.phone}'),
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Pinput(
              length: 6,
              defaultPinTheme: defaultPinTheme,
              controller: _pinPutController,
              focusNode: _pinPutFocusNode,
              onCompleted: (pin) async {
                try {
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: _verificationCode,
                    smsCode: pin,
                  );
                  
                  await FirebaseAuth.instance
                      .signInWithCredential(credential)
                      .then((value) async {
                    if (value.user != null) {
                      await checkRole('${widget.phone}').then((value) async{
                        if(value==true) {
                            Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => AdminHome()),
                          (route) => false);
                        }  
                        else {
                            Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                          (route) => false);
                        }
                      });
                    }
                  });
                } catch (e) {
                  FocusScope.of(context).unfocus();

                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.invalid,
                      backgroundColor: Colors.red,
                      textColor: Colors.white
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phone}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                  (route) => false);
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.fail,
              backgroundColor: Colors.red,
              textColor: Colors.white
          );
          print(e.message);
        },

        codeSent: (String verificationID, int? resendToken) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 120));
  }

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }
}

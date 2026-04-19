import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:groundwater_management/authentication/register.dart';
import 'package:groundwater_management/functions/rounded_button.dart';
import 'package:groundwater_management/l10n/language_picker.dart';
import '../functions/functions.dart';
import 'otp.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProfile {  // RENAMED to avoid conflict with Firebase User
  String phone;
  UserProfile({required this.phone});
}

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);
  
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  var isLoading = false;
  var _mob = '';
  List details = [];
  TextEditingController _controller = TextEditingController();

   @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
 
  displaySnackBar(text) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

 Future<bool> login() async{
    setState(() {});
    return checkRegistered(_mob);
  }
  
  Future<bool> checkRegistered(String phone) async {
    bool mobReg = false;
    await FirebaseFirestore.instance.collection("user").get().then((value) {
        details = value.docs.map((result) {
        return UserProfile(  // Using UserProfile instead of User
            phone: result['phone']);
      }).toList();
      mobReg = false;
    });   

    for (int u = 0; u < details.length; u++) {
      if(details[u].phone==_mob){
        mobReg = true;
        break;
      }
    } 

    details = [];
    if(mobReg==false) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.firstsignup,
          backgroundColor: Colors.green,
          textColor: Colors.white
      );
    }
    return mobReg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.signin,
        ),
        backgroundColor: Colors.orange!,
        actions: [
            LanguagePicker()
          ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(children: [
                Image(image: AssetImage('assets/otp2.gif')),
                SizedBox(height:5),
                Container(
                  margin: EdgeInsets.only(top: 40, right: 10, left: 10),
                  child: TextFormField(    
                    enabled: !isLoading,
                    key: ValueKey('mob'),
                    validator:(value) { 
                              if (value!.isEmpty) {
                                return AppLocalizations.of(context)!.required;
                              }
                              else if(!isNumeric(value!) || value.length != 10){
                                return AppLocalizations.of(context)!.digitsinmob;
                              }
                              return null;
                            },
                      onSaved: (value) {
                        _mob = value!;
                      },    
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.phone ,
                        color: Colors.green[900],
                      ),
                      hintText: AppLocalizations.of(context)!.mobile,
                      prefix: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text('+91'),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(29),
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.all(16),
                      fillColor: Color(0xFFF1E6FF),
                    ),
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    controller: _controller,
                  ),
                ),
              ]),
            ),
           
            Container(
              margin: EdgeInsets.all(10),
              width: double.infinity,
              child:  RoundedButton(
                text: AppLocalizations.of(context)!.cont,
                color: Colors.orange[700]!,
                textColor: Colors.white,

                press : () {
                  if(_formKey.currentState!.validate()){
                    FocusScope.of(context).unfocus();
                     _formKey.currentState!.save();
        
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.wait,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white
                    );
        
                    login().then((mobReg){
                    if(mobReg){
                        Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => OTP(_controller.text)));
                    }
                    else{
                          Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Register()));              
                    }
                  });
                  }
                },
              ),
          ),

          Container(
              margin: EdgeInsets.only(top: 5, bottom: 5),
              alignment: AlignmentDirectional.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0), 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text( AppLocalizations.of(context)!.noacc,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold
                        ),
                    )),
                    InkWell(
                      child: Text(
                        AppLocalizations.of(context)!.signup,
                        style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                        onTap: () => {
                          Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Register()))
                        },
                        ),
                ],),
             ), 
            ),
        ],
        ),
      ),
    );
  }
}

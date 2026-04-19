import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:groundwater_management/functions/functions.dart';
import 'package:groundwater_management/functions/rounded_button.dart';
import 'package:groundwater_management/l10n/language_picker.dart';
import 'package:groundwater_management/screens/welcome.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
var _uid='';

class UserProfile {
  String name, phone, wellid, address, city, pin, state, id;
  UserProfile({required this.name, required this.phone, required this.wellid,
    required this.address, required this.city, required this.pin, required this.state, required this.id});
}

class EditProfile extends StatefulWidget {
  List _items1;
  EditProfile(this._items1, {Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState(_items1);
}

class _EditProfileState extends State<EditProfile> {
  List _items1;
  _EditProfileState(this._items1);

  final _formkey = GlobalKey<FormState>();
  var _name = '';
  var _phone = '';
  var _address = '';
  var _city = '';
  var _state = '';
  var _wellid = '';
  var _pin = '';

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }
  
  getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _uid = user.uid;
    }
  }

  checking() {
    final validity = _formkey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();
    if (validity) {
      _formkey.currentState?.save();
      findforedit();
    }
  }

  findforedit(){
    DocumentReference documentReference = FirebaseFirestore.instance.collection('user').doc(_items1[7]['value']);
    documentReference.update({'name': _name, 'phone': _items1[17]['value'], 'wellid': _wellid, 'city': _city,'pin':_pin,'state':_state, 'id':_items1[7]['value'].toString()}).then((result){
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.profileupdated,
          backgroundColor: Colors.green,
          textColor: Colors.white
      );
    }).catchError((onError){
      print("Error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text(
        AppLocalizations.of(context)!.editprofile,
      ),
        backgroundColor: Colors.orange!,
        actions: [
          LanguagePicker(),          
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red[900]),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                      (route) => false);
            },
          ),
        ],
      ),
 
      body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                      child: TextFormField(
                        key: ValueKey('_name'),
                        validator: (value) {
                          if(value?.isEmpty ?? true){
                            return AppLocalizations.of(context)!.required;
                          }
                          return null;
                        },
                        initialValue: _items1[0]['value'],
                        onSaved: (value) {
                          _name = value ?? '';
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person ,
                            color: Colors.green[900],
                          ),
                          hintText: AppLocalizations.of(context)!.name,
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
                      )),
                  SizedBox(height: 10),
                  
                  Container(
                      child: TextFormField(
                        key: ValueKey('_wellid'),
                        validator: (value) {
                          if(value?.isEmpty ?? true){
                            return AppLocalizations.of(context)!.required;
                          }
                          return null;
                        },
                        initialValue: _items1[2]['value'],
                        onSaved: (value) {
                          _wellid = value ?? '';
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.confirmation_number,
                            color: Colors.green[900],
                          ),
                          hintText: AppLocalizations.of(context)!.wellid,
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
                      )),
                  SizedBox(height: 10),
                  
                  Container(
                      child: TextFormField(
                        key: ValueKey('_address'),
                        validator: (value) {
                          if(value?.isEmpty ?? true){
                            return AppLocalizations.of(context)!.required;
                          }
                          return null;
                        },
                        initialValue: _items1[3]['value'],
                        onSaved: (value) {
                          _address = value ?? '';
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: Colors.green[900],
                          ),
                          hintText: AppLocalizations.of(context)!.address,
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
                      )),
                  SizedBox(height: 10),
                  
                  Container(
                      child: TextFormField(
                        key: ValueKey('_city'),
                        validator: (value) {
                          if(value?.isEmpty ?? true){
                            return AppLocalizations.of(context)!.required;
                          }
                          return null;
                        },
                        initialValue: _items1[4]['value'],
                        onSaved: (value) {
                          _city = value ?? '';
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.location_city ,
                            color: Colors.green[900],
                          ),
                          hintText: AppLocalizations.of(context)!.city,
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
                      )),
                  SizedBox(height: 10),
                  
                  Container(
                      child: TextFormField(
                        key: ValueKey('_pin'),
                        validator: (value) {
                          if(value?.isEmpty ?? true){
                            return AppLocalizations.of(context)!.required;
                          }
                          else if(!isNumeric(value!) || value!.length != 6){
                            return AppLocalizations.of(context)!.digitsinpin;
                          }
                          return null;
                        },
                        initialValue: _items1[5]['value'],
                        onSaved: (value) {
                          _pin = value ?? '';
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.confirmation_number,
                            color: Colors.green[900],
                          ),
                          hintText: AppLocalizations.of(context)!.pincode,
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
                      )),
                  SizedBox(height: 10),
                  
                  Container(
                      child: TextFormField(
                        key: ValueKey('_state'),
                        validator: (value) {
                          if(value?.isEmpty ?? true){
                            return AppLocalizations.of(context)!.required;
                          }
                          return null;
                        },
                        initialValue: _items1[6]['value'],
                        onSaved: (value) {
                          _state = value ?? '';
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.location_searching,
                            color: Colors.green[900],
                          ),
                          hintText: AppLocalizations.of(context)!.state,
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
                      )),
                  SizedBox(height: 10),
                  
                Container(
                      child: RoundedButton(
                        text: AppLocalizations.of(context)!.editprofile,
                        color: Colors.orange[700]!,
                        textColor: Colors.white,
                        press: (){checking();},
                      )),
                    ]),
                  ),
          )));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:groundwater_management/functions/functions.dart';
import 'package:groundwater_management/functions/rounded_button.dart';
import 'package:groundwater_management/l10n/language_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class User {
  String name, phone, wellid, address, city, pin, state;
  User({required this.name, required this.phone, required this.wellid, 
  required this.address, required this.city, required this.pin, required this.state});
}

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
 final _formKey = GlobalKey<FormState>();

  var _name = '';
  var _phone = '';
  var _address = '';
  var _city = '';
  var _state = '';
  var _wellid = '';
  var _pin = '';
  var notPresent = 0;
  var mobNotReg = 0;
  List details = [];

addusertofirebase(String name, String phone, String wellid, String address, String city,String pin,String state) async {
    
    await FirebaseFirestore.instance.collection("user").get().then((value) {
        details = value.docs.map((result) {
        return User(
            name: result['name'],
            phone: result['phone'],
            wellid: result['wellid'],
            address: result['address'],
            city: result['city'],
            pin: result['pin'],
            state: result['state']);
      }).toList();
      notPresent = 1;
      mobNotReg = 1;
    });   

    for (int u = 0; u < details.length; u++) {
      if(details[u].phone== _phone){
        mobNotReg = 0;
        break;
      }

      if (details[u].name == _name && details[u].phone == _phone && details[u].address==_address &&
       details[u].city==_city && details[u].pin==_pin && details[u].state==_state) {
        notPresent = 0;
        break;
      }
    } 

    details = [];

    if(notPresent==1 && mobNotReg==1) {
      DocumentReference documentReference = FirebaseFirestore.instance.collection('user').doc();
      documentReference.set({'name': name, 'phone': phone, 'wellid': wellid, 'address': address,
        'city':city, 'pin': pin, 'state': state, 'id':documentReference.id});

      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.regsuccessful,
          backgroundColor: Colors.green,
          textColor: Colors.white
      );
    }
    else if(notPresent==0){
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.alreadyreg,
          backgroundColor: Colors.red,
          textColor: Colors.white
      );
    }
    else{
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.mobregistered,
          backgroundColor: Colors.red,
          textColor: Colors.white
      );
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text(
          AppLocalizations.of(context)!.signup,
        ),
        backgroundColor: Colors.orange!,
        actions: [
            LanguagePicker()
          ],          
      ),

      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    child: TextFormField(
                      key: ValueKey('name'),
                      validator: (value) {
                        if(value!.isEmpty ){
                          return AppLocalizations.of(context)!.required;
                        }
                        return null;
                      }, 
                      onSaved: (value) {
                        _name = value!;
                      },     
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
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
                    ),
                  ),
                  SizedBox(height: 10),
                  
                  Container(
                    child: TextFormField(
                      key: ValueKey('phone'),
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
                        _phone = value!;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone ,
                          color: Colors.green[900],
                        ),
                        
                        hintText: AppLocalizations.of(context)!.mobile,
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
                    ),
                  ),
                  SizedBox(height: 10),
                  
                Container(
                    child: TextFormField(
                      key: ValueKey('wellid'),
                      validator: (value) {
                        if(value!.isEmpty ){
                          return AppLocalizations.of(context)!.required;
                        }
                        return null;
                      },  
                      onSaved: (value) {
                        _wellid = value!;
                      },    
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.confirmation_number,
                          color: Colors.green[900],
                        ),
                        hintText: AppLocalizations.of(context)!.ids,
                        
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
                    ),
                  ),
                  SizedBox(height: 10.0),

                  Container(
                    child: TextFormField(   
                      key: ValueKey('address'),
                      validator: (value) {
                        if(value!.isEmpty ){
                          return AppLocalizations.of(context)!.required;
                        }
                        return null;
                      }, 
                      onSaved: (value) {
                        _address = value!;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.location_on ,
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
                    ),
                  ),
                  SizedBox(height: 10.0),

                  Container(
                    child: TextFormField(
                  key: ValueKey('city'),
                  validator: (value) {
                    if(value!.isEmpty ){
                      return AppLocalizations.of(context)!.required;
                    }
                    return null;
                  }, 
                  onSaved: (value) {
                    _city = value!;
                   },     
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.location_city,
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
                    ),
                  ),
                SizedBox(height: 10),

                  Container(
                    child: TextFormField(
                      key: ValueKey('pin'),
                      validator:(value) { 
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.required;
                        }
                        else if(!isNumeric(value!) || value!.length != 6){
                          return AppLocalizations.of(context)!.digitsinpin;
                        }
                        return null;
                      },   
                      onSaved: (value) {
                        _pin = value!;
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
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  
                SizedBox(height: 10),

                Container(
                    child: TextFormField(
                  key: ValueKey('state'),
                  validator: (value) {
                    if(value!.isEmpty ){
                      return AppLocalizations.of(context)!.required;
                    }
                    return null;
                  },     
                  onSaved: (value) {
                    _state = value!;
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
                    ),
                  ),

                  SizedBox(height: 20),
                
                  Container(
                      child: RoundedButton(
                        text:  AppLocalizations.of(context)!.signup,
                        color: Colors.orange[700]!,
                        textColor: Colors.white,
                        press: (){
                          if(_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            addusertofirebase(_name, _phone, _wellid, _address, _city, _pin, _state);
                          }
                        },
                      )),
                ],
              ),
            )),
      ),
    );
  }
}

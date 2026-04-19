import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:groundwater_management/functions/rounded_button.dart';
import 'package:groundwater_management/l10n/language_picker.dart';
import 'package:groundwater_management/screens/welcome.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
var _uid = '';

class Data {
  String l1, l2, y, m, w, uid, wid, s, v;
  Data({required this.l1, required this.l2, required this.y, required this.m, required this.w, required this.wid, required this.uid, required this.s, required this.v});
}

class AddData extends StatefulWidget {
  final List _items1;
  final String _phone;
  AddData(this._items1, this._phone, {Key? key}) : super(key: key);

  @override
  _AddDataState createState() => _AddDataState(_items1, _phone);
}

class _AddDataState extends State<AddData> {
  final List _items1;
  final String _phone;
  _AddDataState(this._items1, this._phone);

  getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _uid = user.uid;
      _getcurrentlocation();
    }
  }

  final _formkey = GlobalKey<FormState>();
  var _l1 = '';
  var _l2 = '';
  var _m = '';
  var _y = '';
  var _w = '';
  var _wid = '';
  var _s = '';
  var _v = '';
  var time = DateTime.now();
  var fl = 1;

  List<Map<String, dynamic>> get _items => [
    {'value': 'January', 'label': AppLocalizations.of(context)!.m1},
    {'value': 'February', 'label': AppLocalizations.of(context)!.m2},
    {'value': 'March', 'label': AppLocalizations.of(context)!.m3},
    {'value': 'April', 'label': AppLocalizations.of(context)!.m4},
    {'value': 'May', 'label': AppLocalizations.of(context)!.m5},
    {'value': 'June', 'label': AppLocalizations.of(context)!.m6},
    {'value': 'July', 'label': AppLocalizations.of(context)!.m7},
    {'value': 'August', 'label': AppLocalizations.of(context)!.m8},
    {'value': 'September', 'label': AppLocalizations.of(context)!.m9},
    {'value': 'October', 'label': AppLocalizations.of(context)!.m10},
    {'value': 'November', 'label': AppLocalizations.of(context)!.m11},
    {'value': 'December', 'label': AppLocalizations.of(context)!.m12},
  ];

  List list = [];

  bool _isNumeric(String? result) {
    if (result == null) {
      return false;
    }
    return double.tryParse(result) != null;
  }

  void _getcurrentlocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) {
      setState(() {
        _l1 = value.latitude.toString();
        _l2 = value.longitude.toString();
      });
      check();
    });
  }

  check() {
    final validity = _formkey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();
    if (validity) {
      _formkey.currentState?.save();
      find(_l1, _l2, _w, _y, _m, _uid, _wid, _s, _v);
    }
  }

  find(String l1, String l2, String w, String y, String m, String uid, String wid, String s, String v) async {
    await FirebaseFirestore.instance.collection("data").get().then((value) {
      list = value.docs.map((result) {
        return Data(
            l1: result['l1'],
            l2: result['l2'],
            y: result['y'],
            m: result['m'],
            w: result['w'],
            wid: result['wid'],
            uid: result['uid'],
            s: result['s'],
            v: result['v']);
      }).toList();
    });
    
    for (int i = 0; i < list.length; i++) {
      if (list[i].s.toLowerCase() == _s.toLowerCase() &&
          list[i].v.toLowerCase() == _v.toLowerCase() &&
          list[i].y == _y &&
          list[i].m == _m &&
          list[i].uid == _uid &&
          list[i].wid == _wid) {
        fl = 0;
        break;
      }
    }
    list = [];
    if (fl == 1) {
      adddatatofirebase(_l1, _l2, _w, _y, _m, _uid, _wid, _s, _v);
    } else {
      fl = 1;
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.dataexist,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  adddatatofirebase(String l1, String l2, String w, String y, String m, String uid, String wid, String s, String v) async {
    DocumentReference documentReference = FirebaseFirestore.instance.collection('data').doc();
    documentReference.set({
      'l1': l1,
      'l2': l2,
      'm': m,
      'w': w,
      'wid': wid,
      's': s,
      'v': v,
      'y': y,
      'timestamp': time,
      'uid': uid,
      'id': documentReference.id,
      'phone': _phone
    });
    Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.dataadded,
        backgroundColor: Colors.green,
        textColor: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newadd),
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
                      child: SelectFormField(
                    initialValue: _items1[0]['value'],
                    labelText: 'Well Id',
                    items: _items1.cast<Map<String, dynamic>>(),
                    onSaved: (value) {
                      _wid = value ?? '';
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.add, color: Colors.green[900]),
                      hintText: AppLocalizations.of(context)!.wellid,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(29),
                        borderSide: BorderSide(width: 0, style: BorderStyle.none),
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.all(16),
                      fillColor: Color(0xFFF1E6FF),
                    ),
                  )),
                  SizedBox(height: 10),
                  Container(
                      child: TextFormField(
                    key: ValueKey('s'),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return AppLocalizations.of(context)!.required;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _s = value ?? '';
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.location_city, color: Colors.green[900]),
                      hintText: AppLocalizations.of(context)!.state,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(29),
                        borderSide: BorderSide(width: 0, style: BorderStyle.none),
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.all(16),
                      fillColor: Color(0xFFF1E6FF),
                    ),
                  )),
                  SizedBox(height: 10),
                  Container(
                      child: TextFormField(
                    key: ValueKey('v'),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return AppLocalizations.of(context)!.required;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _v = value ?? '';
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.location_city, color: Colors.green[900]),
                      hintText: AppLocalizations.of(context)!.village,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(29),
                        borderSide: BorderSide(width: 0, style: BorderStyle.none),
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.all(16),
                      fillColor: Color(0xFFF1E6FF),
                    ),
                  )),
                  SizedBox(height: 10),
                  Container(
                    child: TextFormField(
                      key: ValueKey('y'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context)!.required;
                        } else if (!_isNumeric(value) ||
                            (value?.length ?? 0) != 4 ||
                            int.parse(value!) > time.year) {
                          return AppLocalizations.of(context)!.incorrect;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _y = value ?? '';
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.calendar_today, color: Colors.green[900]),
                        hintText: AppLocalizations.of(context)!.year,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide: BorderSide(width: 0, style: BorderStyle.none),
                        ),
                        filled: true,
                        contentPadding: EdgeInsets.all(16),
                        fillColor: Color(0xFFF1E6FF),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: TextFormField(
                      key: ValueKey('w'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context)!.required;
                        } else if (!_isNumeric(value)) {
                          return AppLocalizations.of(context)!.incorrect;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _w = value ?? '';
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.waterfall_chart, color: Colors.green[900]),
                        hintText: AppLocalizations.of(context)!.waterlevel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide: BorderSide(width: 0, style: BorderStyle.none),
                        ),
                        filled: true,
                        contentPadding: EdgeInsets.all(16),
                        fillColor: Color(0xFFF1E6FF),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                      child: SelectFormField(
                    initialValue: 'January',
                    labelText: AppLocalizations.of(context)!.month,
                    items: _items,
                    onSaved: (value) {
                      _m = value ?? '';
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.calendar_view_day_sharp, color: Colors.green[900]),
                      hintText: AppLocalizations.of(context)!.month,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(29),
                        borderSide: BorderSide(width: 0, style: BorderStyle.none),
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.all(16),
                      fillColor: Color(0xFFF1E6FF),
                    ),
                  )),
                  SizedBox(height: 20),
                  Container(
                      child: RoundedButton(
                    text: AppLocalizations.of(context)!.add,
                    color: Colors.orange[700]!,
                    textColor: Colors.white,
                    press: () {
                      getCurrentUser();
                    },
                  ))
                ],
              ),
            )),
      ),
    );
  }
}

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

class Data {
  String l1, l2, y, m, w, uid, wid, s, v;
  Data({required this.l1, required this.l2, required this.y, required this.m, required this.w, required this.wid, required this.uid, required this.s, required this.v});  // FIXED: Added required to all parameters
}

class EditData extends StatefulWidget {
  var d;
  List items1;

  EditData({required this.d, required this.items1, Key? key}) : super(key: key);  // FIXED: Added required and Key?
  
  @override
  _EditDataState createState() => _EditDataState(d, items1);
}

class _EditDataState extends State<EditData> {
  var d;
  List items1;
  _EditDataState(this.d, this.items1);

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
  var _uid = '';
  
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
  
  bool _isNumeric(String? result) {  // FIXED: Made parameter nullable
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
      _uid = d['uid'];
      checking();
    });
  }
  
  checking() {
    final validity = _formkey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();
    if (validity) {
      _formkey.currentState?.save();
      findforedit(_l1, _l2, _w, _y, _m, _uid, _wid, _s, _v);
    }
  }
  
  findforedit(String l1, String l2, String w, String y, String m, String uid, String wid, String s, String v) async {
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
          list[i].w == _w &&
          list[i].uid == _uid &&
          list[i].wid == _wid) {
        fl = 0;
        break;
      }
    }
    list = [];
    if (fl == 1) {
      editdatafirebase(_l1, _l2, _w, _y, _m, _uid, _wid, _s, _v);
    } else {
      fl = 1;
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.dataexist,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }
  
  editdatafirebase(String l1, String l2, String w, String y, String m, String uid, String wid, String s, String v) async {
    DocumentReference documentReference = FirebaseFirestore.instance.collection('data').doc(d['id']);
    documentReference.update({
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
      'id': d['id']
    }).then((result) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.dataupdated,
          backgroundColor: Colors.green,
          textColor: Colors.white);
    }).catchError((onError) {
      print("onError");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editdata),
        backgroundColor: Colors.orange,  // FIXED: Removed invalid !
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
          )
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
                    initialValue: d['wid'],
                    labelText: 'Well Id',
                    items: items1.cast<Map<String, dynamic>>(),  // FIXED: Type casting
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
                    initialValue: d['s'],
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
                    initialValue: d['v'],
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
                        } else if (!_isNumeric(value) ||  // FIXED: Handle null parameter
                            (value?.length ?? 0) != 4 ||
                            int.parse(value!) > time.year) {
                          return AppLocalizations.of(context)!.incorrect;
                        }
                        return null;
                      },
                      initialValue: d['y'],
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
                        } else if (!_isNumeric(value)) {  // FIXED: Handle null parameter
                          return AppLocalizations.of(context)!.incorrect;
                        }
                        return null;
                      },
                      initialValue: d['w'],
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
                    initialValue: d['m'],
                    labelText: 'Month',
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
                    text: AppLocalizations.of(context)!.editdata,
                    color: Colors.orange[700]!,  // FIXED: Added !
                    textColor: Colors.white,
                    press: () {
                      _getcurrentlocation();
                    },
                  ))
                ],
              ),
            )),
      ),
    );
  }
}

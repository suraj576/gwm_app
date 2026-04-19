import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:groundwater_management/functions/rounded_button.dart';
import 'package:groundwater_management/l10n/language_picker.dart';
import 'package:groundwater_management/screens/components/edit_data.dart';
import 'package:groundwater_management/screens/welcome.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
var _uid = '';

class Data {
  String l1, l2, y, m, w, uid, id, wid, s, v, flag;
  Data({required this.l1, required this.l2, required this.y, required this.m, required this.w, required this.uid, required this.wid, required this.id, required this.s, required this.v, required this.flag});
}

class OwnData extends StatefulWidget {
  final List _items1;
  OwnData(this._items1, {Key? key}) : super(key: key);

  @override
  _OwnDataState createState() => _OwnDataState(_items1);
}

class _OwnDataState extends State<OwnData> {
  final List _items1;
  _OwnDataState(this._items1);
  
  String keyWord = '';  // Initialize field
  List searchList = [];
  List list = [];
  var _fl = 0;
  bool _loading = true;

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

  Future<void> getresults() async {
    await getresultsList();
    searchList.clear();
    for (int i = 0; i < list.length; i++) {
      if (list[i].uid == _uid) {
        searchList.add(list[i]);
      }
    }
    if (searchList.length == 0) {
      _fl = 1;
    }
    list.clear();
  }

  Future<void> getresultsList() async {
    var snapshot = await FirebaseFirestore.instance.collection("data").get();
    setState(() {
      _loading = true;
    });
    list = snapshot.docs.map((result) {
      var temp = _items1.where((element) => element['value'] == result['wid']);
      return Data(
          l1: result['l1'],
          l2: result['l2'],
          y: result['y'],
          m: result['m'],
          w: result['w'],
          uid: result['uid'],
          wid: result['wid'],
          id: result['id'],
          s: result['s'],
          v: result['v'],
          flag: temp.length == 0 ? '1' : '0');
    }).toList();
    setState(() {
      _loading = false;
    });
  }

  delete(String id) {
    DocumentReference documentReference = FirebaseFirestore.instance.collection('data').doc(id);
    documentReference.delete().whenComplete(() {
      getresults();
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.datadeleted,
          backgroundColor: Colors.green,
          textColor: Colors.white);
    });
  }

  edit(String id) {
    var document = FirebaseFirestore.instance.collection('data').doc(id);
    var d = <String, dynamic>{};  // Fixed map initialization
    document.get().then((value) {
      d['l1'] = value['l1'];
      d['l2'] = value['l2'];
      d['y'] = value['y'];
      d['m'] = value['m'];
      d['w'] = value['w'];
      d['uid'] = value['uid'];
      d['wid'] = value['wid'];
      d['id'] = value['id'];
      d['s'] = value['s'];
      d['v'] = value['v'];
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EditData(d: d, items1: _items1)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
          future: getresultsList(),
          builder: (BuildContext context, snapshot) {
            return Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  title: Text(AppLocalizations.of(context)!.update),
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
                    )
                  ],
                ),
                body: _loading == true
                    ? Container(
                        child: Center(
                          child: Text("Loading..."),
                        ))
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(8, 20, 8, 5),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Container(
                                  child: RoundedButton(
                                text: AppLocalizations.of(context)!.view,
                                color: Colors.orange[700]!,
                                textColor: Colors.white,
                                press: () {
                                  getresults();
                                  setState(() {});
                                },
                              )),
                              SizedBox(height: 20),
                              searchList.length > 0
                                  ? Container(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          headingRowColor: MaterialStateColor.resolveWith(
                                              (states) => Colors.lightBlue[50]!),
                                          dataRowColor: MaterialStateColor.resolveWith(
                                              (states) => Colors.white),
                                          columns: [
                                            DataColumn(
                                                label: Text(
                                              AppLocalizations.of(context)!.latitude,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                            DataColumn(
                                                label: Text(
                                              AppLocalizations.of(context)!.longitude,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                            DataColumn(
                                                label: Text(
                                              AppLocalizations.of(context)!.year,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                            DataColumn(
                                                label: Text(
                                              AppLocalizations.of(context)!.month,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                            DataColumn(
                                                label: Text(
                                              AppLocalizations.of(context)!.waterlevel,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                            DataColumn(
                                                label: Text(
                                              AppLocalizations.of(context)!.wellid,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                            DataColumn(
                                                label: Text(
                                              AppLocalizations.of(context)!.state,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                            DataColumn(
                                                label: Text(
                                              AppLocalizations.of(context)!.village,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                            DataColumn(
                                                label: Text(
                                              AppLocalizations.of(context)!.delete,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                            DataColumn(
                                                label: Text(
                                              AppLocalizations.of(context)!.edit,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                          ],
                                          rows: searchList
                                              .map(((element) => DataRow(
                                                    cells: <DataCell>[
                                                      DataCell(Text(element.l1)),
                                                      DataCell(Text(element.l2)),
                                                      DataCell(Text(element.y)),
                                                      DataCell(Text(element.m)),
                                                      DataCell(Text(element.w)),
                                                      DataCell(Text(element.wid)),
                                                      DataCell(Text(element.s)),
                                                      DataCell(Text(element.v)),
                                                      DataCell(
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed: () {
                                                            delete(element.id);
                                                          },
                                                        ),
                                                      ),
                                                      DataCell(
                                                        element.flag == '0'
                                                            ? IconButton(
                                                                icon: const Icon(
                                                                  Icons.edit,
                                                                  color: Colors.green,
                                                                ),
                                                                onPressed: () {
                                                                  edit(element.id);
                                                                },
                                                              )
                                                            : IconButton(
                                                                icon: const Icon(
                                                                  Icons.edit,
                                                                  color: Colors.blueGrey,
                                                                ),
                                                                onPressed: () {
                                                                  Fluttertoast.showToast(
                                                                      msg: AppLocalizations.of(context)!.itemnotexist,
                                                                      backgroundColor: Colors.red,
                                                                      textColor: Colors.white);
                                                                },
                                                              ),
                                                      ),
                                                    ],
                                                  )))
                                              .toList(),
                                        ),
                                      ),
                                    )
                                  : _fl == 1
                                      ? Center(
                                          child: Text(
                                          AppLocalizations.of(context)!.nodataadded,
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold),
                                        ))
                                      : Center(child: Text('')),
                            ],
                          ),
                        ),
                      ));
          }),
    );
  }
}

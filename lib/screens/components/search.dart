import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groundwater_management/functions/button_widget.dart';
import 'package:groundwater_management/functions/rounded_button.dart';
import 'package:groundwater_management/l10n/language_picker.dart';
import 'package:groundwater_management/screens/welcome.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:select_form_field/select_form_field.dart';

class Data {
  String y, l1, l2, m, w, wid, s, v;
  Data({required this.y, required this.l1, required this.l2, required this.m, required this.w, required this.wid, required this.s, required this.v});  // FIXED: Added required to all parameters
}

class SearchResult extends StatefulWidget {
  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  String keyWord = '';  // FIXED: Initialize field
  List<Data> searchList = [];
  List list = [];
  final List<Map<String, dynamic>> _items_search = [];
  final List<Map<String, dynamic>> _state = [];
  final List<Map<String, dynamic>> _village = [];
  final _formkey = GlobalKey<FormState>();
  var _wid = '';
  var _m = '';
  var _m2 = '';
  var _y2 = '';
  var _y = '';
  var _s = '';
  var _v = '';
  var _fl = 0;
  var time = DateTime.now();
  bool _loading = true;
  
  Map<String, int> _items = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12,
  };

  late DateTimeRange dateRange;  // FIXED: Use late keyword

  @override
  void initState() {
    dateRange = DateTimeRange(start: DateTime.now(), end: DateTime.now());  // FIXED: Initialize dateRange
    super.initState();
  }

  Future getresultsList() async {
    var snapshot = await FirebaseFirestore.instance.collection("data").get();

    _items_search.clear();
    setState(() {
      _loading = true;
    });
    list = snapshot.docs.map((result) {
      var temp = _items_search.where((element) => element['value'] == result['wid']);
      if (temp.length == 0) {
        _items_search.add({
          'value': result['wid'],
          'label': result['wid'],
        });
      }
      return Data(
          y: result['y'],
          l1: result['l1'],
          l2: result['l2'],
          m: result['m'],
          w: result['w'],
          wid: result['wid'],
          s: result['s'],
          v: result['v']);
    }).toList();

    setState(() {
      _loading = false;
    });
  }

  getstate(String wid) {
    _state.clear();
    for (int i = 0; i < list.length; i++) {
      if (list[i].wid == wid) {
        var temp1 = _state.where((element) => element['value'] == list[i].s);
        if (temp1.length == 0) {
          _state.add({
            'value': list[i].s,
            'label': list[i].s,
          });
        }
      }
    }

    _state.sort((a, b) {
      return a['value'].compareTo(b['value']);
    });
  }

  searchFunctionality(String y2, String y, String m2, String m, String wid, String s, String v) {
    _fl = 0;
    searchList.clear();
    final validity = _formkey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();
    if (validity) {
      _formkey.currentState?.save();

      if (m.length > 0 && y2.length > 0 && y.length > 0 && m2.length > 0 && wid.length > 0 && s.length > 0 && v.length > 0) {
        setState(() {
          _loading = true;
        });
        for (int i = 0; i < list.length; i++) {
          if (list[i].wid == wid && (list[i].v).toLowerCase() == v.toLowerCase() && list[i].s == s) {
            if (y != y2) {
              if (int.parse(list[i].y) == int.parse(y) && (_items[list[i].m] ?? 0) >= int.parse(m) && (_items[list[i].m] ?? 0) <= 12) {  // FIXED: Added null safety
                searchList.add(list[i]);
              } else if (int.parse(list[i].y) == int.parse(y2) && (_items[list[i].m] ?? 0) <= int.parse(m2) && (_items[list[i].m] ?? 0) >= 1) {  // FIXED: Added null safety
                searchList.add(list[i]);
              } else if (int.parse(list[i].y) > int.parse(y) && int.parse(list[i].y) < int.parse(y2)) {
                searchList.add(list[i]);
              }
            } else {
              if (int.parse(list[i].y) == int.parse(y) && (_items[list[i].m] ?? 0) >= int.parse(m) && (_items[list[i].m] ?? 0) <= int.parse(m2)) {  // FIXED: Added null safety
                searchList.add(list[i]);
              }
            }
          }
        }
        setState(() {
          _loading = false;
        });
      } else if (wid.length > 0 && s.length > 0 && v.length > 0) {
        setState(() {
          _loading = true;
        });
        for (int i = 0; i < list.length; i++) {
          if (list[i].wid == wid && (list[i].v).toLowerCase() == v.toLowerCase() && list[i].s == s) {
            searchList.add(list[i]);
          }
        }
        setState(() {
          _loading = false;
        });
      } else {
        searchList = List<Data>.from(list);  // FIXED: Proper type casting
      }
      if (searchList.length == 0) {
        _fl = 1;
      }
    }
  }

  String getFrom() {
    if (dateRange == null) {
      return 'From';
    } else {
      _y = DateFormat('yyyy').format(dateRange.start);
      _m = DateFormat('MM').format(dateRange.start);
      return DateFormat('MM/yyyy').format(dateRange.start);
    }
  }

  String getUntil() {
    if (dateRange == null) {
      return 'Until';
    } else {
      _y2 = DateFormat('yyyy').format(dateRange.end);
      _m2 = DateFormat('MM').format(dateRange.end);
      return DateFormat('MM/yyyy').format(dateRange.end);
    }
  }

  Future pickDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(hours: 24 * 3)),
    );
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1000),
      lastDate: DateTime(DateTime.now().year + 1000),
      initialDateRange: dateRange,
    );

    if (newDateRange == null) return;

    setState(() => {dateRange = newDateRange});
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
                  title: Text(AppLocalizations.of(context)!.search2),  // FIXED: Added !
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
                body: _loading == true
                    ? Container(
                        child: Center(
                          child: Text("Loading..."),
                        ))
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(8, 20, 8, 5),
                          child: Form(
                            key: _formkey,
                            child: Column(
                              children: [
                                SelectFormField(
                                  initialValue: '',
                                  labelText: 'Select Well Id',
                                  items: _items_search,
                                  key: ValueKey('wid'),
                                  validator: (value) {
                                    if (value == '') {
                                      return AppLocalizations.of(context)!.required;
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _wid = value ?? '';
                                    getstate(value ?? '');  // FIXED: Handle null value
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.search, color: Colors.green[900]),
                                    hintText: AppLocalizations.of(context)!.wellid,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(29),
                                      borderSide: BorderSide(width: 0, style: BorderStyle.none),
                                    ),
                                    filled: true,
                                    contentPadding: EdgeInsets.all(16),
                                    fillColor: Color(0xFFF1E6FF),
                                  ),
                                ),
                                SizedBox(height: 20),
                                SelectFormField(
                                  initialValue: '',
                                  labelText: 'Select State',
                                  items: _state,
                                  key: ValueKey('s'),
                                  validator: (value) {
                                    if (value == '') {
                                      return AppLocalizations.of(context)!.required;
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _s = value ?? '';
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.search, color: Colors.green[900]),
                                    hintText: AppLocalizations.of(context)!.state,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(29),
                                      borderSide: BorderSide(width: 0, style: BorderStyle.none),
                                    ),
                                    filled: true,
                                    contentPadding: EdgeInsets.all(16),
                                    fillColor: Color(0xFFF1E6FF),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Container(
                                    child: TextFormField(
                                  key: ValueKey('v'),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return AppLocalizations.of(context)!.required;
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
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
                                SizedBox(height: 20),
                                Container(
                                  child: HeaderWidget(
                                    title: AppLocalizations.of(context)!.select,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: ButtonWidget(
                                            text: getFrom(),
                                            onClicked: () => pickDateRange(context),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, color: Colors.black87),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ButtonWidget(
                                            text: getUntil(),
                                            onClicked: () => pickDateRange(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Container(
                                    child: RoundedButton(
                                  text: AppLocalizations.of(context)!.search,
                                  color: Colors.orange[700]!,  // FIXED: Added !
                                  textColor: Colors.white,
                                  press: () {
                                    if (_y2.length > 0 ||
                                        _m2.length > 0 ||
                                        _m.length > 0 ||
                                        _y.length > 0 ||
                                        _wid.length > 0 ||
                                        _s.length > 0 ||
                                        _v.length > 0) {
                                      searchFunctionality(_y2, _y, _m2, _m, _wid, _s, _v);
                                      setState(() {});
                                    } else {
                                      searchFunctionality(_y2, _y, _m2, _m, _wid, _s, _v);
                                      setState(() {});
                                    }
                                  },
                                )),
                                SizedBox(height: 20),
                                searchList.length > 0
                                    ? Container(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            headingRowColor: MaterialStateColor.resolveWith((states) => Colors.lightBlue[50]!),  // FIXED: Added !
                                            dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                                            columns: [
                                              DataColumn(
                                                  label: Text(
                                                AppLocalizations.of(context)!.wellid,
                                                style: const TextStyle(color: Colors.black87, fontSize: 20.0, fontWeight: FontWeight.bold),
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                AppLocalizations.of(context)!.latitude,
                                                style: const TextStyle(color: Colors.black87, fontSize: 20.0, fontWeight: FontWeight.bold),
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                AppLocalizations.of(context)!.longitude,
                                                style: const TextStyle(color: Colors.black87, fontSize: 20.0, fontWeight: FontWeight.bold),
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                AppLocalizations.of(context)!.year,
                                                style: const TextStyle(color: Colors.black87, fontSize: 20.0, fontWeight: FontWeight.bold),
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                AppLocalizations.of(context)!.month,
                                                style: const TextStyle(color: Colors.black87, fontSize: 20.0, fontWeight: FontWeight.bold),
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                AppLocalizations.of(context)!.waterlevel,
                                                style: const TextStyle(color: Colors.black87, fontSize: 20.0, fontWeight: FontWeight.bold),
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                AppLocalizations.of(context)!.state,
                                                style: const TextStyle(color: Colors.black87, fontSize: 20.0, fontWeight: FontWeight.bold),
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                AppLocalizations.of(context)!.village,
                                                style: const TextStyle(color: Colors.black87, fontSize: 20.0, fontWeight: FontWeight.bold),
                                              )),
                                            ],
                                            rows: searchList
                                                .map(((element) => DataRow(cells: <DataCell>[
                                                      DataCell(Text(element.wid)),
                                                      DataCell(Text(element.l1)),
                                                      DataCell(Text(element.l2)),
                                                      DataCell(Text(element.y)),
                                                      DataCell(Text(element.m)),
                                                      DataCell(Text(element.w)),
                                                      DataCell(Text(element.s)),
                                                      DataCell(Text(element.v)),
                                                    ])))
                                                .toList(),
                                          ),
                                        ),
                                      )
                                    : _fl == 1
                                        ? Center(
                                            child: Text(
                                            AppLocalizations.of(context)!.norecord,
                                            style: const TextStyle(color: Colors.red, fontSize: 20.0, fontWeight: FontWeight.bold),
                                          ))
                                        : Center(child: Text('')),
                              ],
                            ),
                          ),
                        ),
                      ));
          }),
    );
  }
}

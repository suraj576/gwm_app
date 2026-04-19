import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groundwater_management/functions/button_widget.dart';
import 'package:groundwater_management/functions/rounded_button.dart';
import 'package:groundwater_management/l10n/language_picker.dart';
import 'package:groundwater_management/screens/welcome.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Data {
  String y, l1, l2, m, w, wid, s, v;
  Data({required this.y, required this.l1, required this.l2, required this.m, required this.w, required this.wid, required this.s, required this.v});
}

class GraphResult extends StatefulWidget {
  @override
  _GraphResultState createState() => _GraphResultState();
}

class _GraphResultState extends State<GraphResult> {
  String keyWord = '';
  List<Data> searchList = [];
  List<Data> searchList1 = [];
  List<Data> searchList2 = [];
  final List<Map<String, dynamic>> _items_search = [];
  final List<Map<String, dynamic>> _state = [];
  final List<Map<String, dynamic>> _village = [];
  List list = [];
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
  var _val = 'Month-view';
  
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
  
  List<Map<String, dynamic>> get _options => [
    {
      'value': 'Month-view',
      'label': AppLocalizations.of(context)!.monthview,
    },
    {
      'value': 'Year-view',
      'label': AppLocalizations.of(context)!.yearview,
    },
  ];

  late TooltipBehavior _tooltipBehavior;
  late DateTimeRange dateRange;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    dateRange = DateTimeRange(start: DateTime.now(), end: DateTime.now());
    super.initState();
  }

  void func1() {
    searchList2.sort((a, b) {
      return (_items[a.m] ?? 0).compareTo(_items[b.m] ?? 0);
    });
  }
  
  void func2() {
    searchList1.sort((a, b) {
      return int.parse(a.y).compareTo(int.parse(b.y));
    });
  }

  Future getresultsList() async {
    var snapshot = await FirebaseFirestore.instance.collection("data").get();

    _items_search.clear();
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

    setState(() {});
    return list;
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
    searchList.clear();
    searchList1.clear();
    searchList2.clear();
    _fl = 0;
    final validity = _formkey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();
    if (validity) {
      _formkey.currentState?.save();

      if (m.length > 0 && y2.length > 0 && y.length > 0 && m2.length > 0 && wid.length > 0 && s.length > 0 && v.length > 0) {
        for (int i = 0; i < list.length; i++) {
          if (list[i].wid == wid && (list[i].v).toLowerCase() == v.toLowerCase() && list[i].s == s) {
            if (y != y2) {
              if (int.parse(list[i].y) == int.parse(y) && (_items[list[i].m] ?? 0) >= int.parse(m) && (_items[list[i].m] ?? 0) <= 12) {
                searchList.add(list[i]);
                searchList1.add(list[i]);
                searchList2.add(list[i]);
              } else if (int.parse(list[i].y) == int.parse(y2) && (_items[list[i].m] ?? 0) <= int.parse(m2) && (_items[list[i].m] ?? 0) >= 1) {
                searchList.add(list[i]);
                searchList1.add(list[i]);
                searchList2.add(list[i]);
              } else if (int.parse(list[i].y) > int.parse(y) && int.parse(list[i].y) < int.parse(y2)) {
                searchList.add(list[i]);
                searchList1.add(list[i]);
                searchList2.add(list[i]);
              }
            } else {
              if (int.parse(list[i].y) == int.parse(y) && (_items[list[i].m] ?? 0) >= int.parse(m) && (_items[list[i].m] ?? 0) <= int.parse(m2)) {
                searchList.add(list[i]);
                searchList1.add(list[i]);
                searchList2.add(list[i]);
              }
            }
          }
        }
      } else if (wid.length > 0 && s.length > 0 && v.length > 0) {
        for (int i = 0; i < list.length; i++) {
          if (list[i].wid == wid && (list[i].v).toLowerCase() == v.toLowerCase() && list[i].s == s) {
            searchList.add(list[i]);
            searchList1.add(list[i]);
            searchList2.add(list[i]);
          }
        }
      } else {
        searchList = List<Data>.from(list);
        searchList1 = List<Data>.from(list);
        searchList2 = List<Data>.from(list);
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
                  title: Text(AppLocalizations.of(context)!.graph),
                  backgroundColor: Colors.orange,
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
                              getstate(value ?? '');
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
                              child: SelectFormField(
                            initialValue: '',
                            labelText: 'Views',
                            items: _options,
                            key: ValueKey('val'),
                            validator: (value) {
                              if (value == '') {
                                return AppLocalizations.of(context)!.required;
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _val = value ?? '';
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.insert_chart, color: Colors.green[900]),
                              hintText: AppLocalizations.of(context)!.selectview,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(29),
                                borderSide: BorderSide(width: 0, style: BorderStyle.none),
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(16),
                              fillColor: Color(0xFFF1E6FF),
                            ),
                          )),
                          Container(
                              child: RoundedButton(
                            text: AppLocalizations.of(context)!.search2,
                            color: Colors.orange[700]!,
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
                                if (_fl != 1) {
                                  func1();
                                  func2();
                                }
                                setState(() {});
                              } else {
                                searchFunctionality(_y2, _y, _m2, _m, _wid, _s, _v);
                                setState(() {});
                              }
                            },
                          )),
                          SizedBox(height: 20),
                          searchList.length > 0
                              ? _val == 'Month-view'
                                  ? SingleChildScrollView(
                                      child: Column(children: [
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.75,
                                          child: SafeArea(
                                              child: Scaffold(
                                            body: SfCartesianChart(
                                              plotAreaBackgroundColor: Colors.white,
                                              title: ChartTitle(text: AppLocalizations.of(context)!.monthvslevel),
                                              legend: Legend(isVisible: true),
                                              tooltipBehavior: _tooltipBehavior,
                                              series: <FastLineSeries>[
                                                FastLineSeries<Data, String>(
                                                  name: AppLocalizations.of(context)!.month,
                                                  dataSource: searchList2,
                                                  xValueMapper: (Data gdp, _) => gdp.m,
                                                  yValueMapper: (Data gdp, _) => double.parse(gdp.w),
                                                  markerSettings: MarkerSettings(
                                                      isVisible: true, shape: DataMarkerType.rectangle),
                                                  dataLabelSettings: DataLabelSettings(isVisible: false, color: Colors.yellow),
                                                  enableTooltip: true,
                                                )
                                              ],
                                              primaryXAxis: CategoryAxis(
                                                  labelRotation: 90,
                                                  majorGridLines: MajorGridLines(width: 0, color: Colors.red, dashArray: <double>[5,5]),
                                                ),
                                                primaryYAxis: NumericAxis(
                                                  majorGridLines: MajorGridLines(width: 0, color: Colors.red, dashArray: <double>[5,5]),
                                                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                                                  title: AxisTitle(text: AppLocalizations.of(context)!.waterlevel),
                                                ),
                                            ),
                                          )),
                                        ),
                                      ]),
                                    )
                                  : SingleChildScrollView(
                                      child: Column(children: [
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.75,
                                          child: SafeArea(
                                              child: Scaffold(
                                            body: SfCartesianChart(
                                              plotAreaBackgroundColor: Colors.white,
                                              title: ChartTitle(text: AppLocalizations.of(context)!.yearvslevel),
                                              legend: Legend(isVisible: true),
                                              tooltipBehavior: _tooltipBehavior,
                                              series: <FastLineSeries>[
                                                FastLineSeries<Data, String>(
                                                    name: AppLocalizations.of(context)!.year,
                                                    dataSource: searchList1,
                                                    xValueMapper: (Data gdp, _) => gdp.y,
                                                    yValueMapper: (Data gdp, _) => double.parse(gdp.w),
                                                    markerSettings: MarkerSettings(
                                                        isVisible: true, shape: DataMarkerType.rectangle),
                                                    dataLabelSettings: DataLabelSettings(isVisible: false, color: Colors.yellow),
                                                    enableTooltip: true)
                                              ],
                                              primaryXAxis: CategoryAxis(
                                                labelRotation: 90,
                                                majorGridLines: MajorGridLines(width: 0, color: Colors.red, dashArray: <double>[5,5]),
                                              ),
                                              primaryYAxis: NumericAxis(
                                                majorGridLines: MajorGridLines(width: 0, color: Colors.red, dashArray: <double>[5,5]),
                                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                                                title: AxisTitle(text: AppLocalizations.of(context)!.waterlevel),
                                              ),
                                            ),
                                          )),
                                        ),
                                      ]),
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

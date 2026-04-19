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
  String year, latitude, longitude, month, waterlevel, wid, state, village;
  Data({required this.year, required this.latitude, required this.longitude, required this.month, required this.waterlevel, required this.wid, required this.state, required this.village});
}

class Data1 {
  String year = '', month = '', waterlevel = '', waterlevel1 = '';
}

class CompareGraphResult extends StatefulWidget {
  @override
  _CompareGraphResultState createState() => _CompareGraphResultState();
}

class _CompareGraphResultState extends State<CompareGraphResult> {
  String keyWord = '';
  List<Data1> result1 = [];
  List<Data1> result2 = [];
  List<Data> searchList1 = [];
  List<Data> searchList2 = [];
  List<Data> searchList3 = [];
  List<Data> searchList4 = [];
  final List<Map<String, dynamic>> _items_search = [];
  final List<Map<String, dynamic>> _state = [];
  final List<Map<String, dynamic>> _village = [];
  List list = [];
  final _formkey = GlobalKey<FormState>();
  var _wid = '';
  var _state1 = '';
  var _village1 = '';
  var _fl = 0;
  var time = DateTime.now();
  var _val = 'Month-view';

  var _wid1 = '';
  var _month1 = '';
  var _month21 = '';
  var _year21 = '';
  var _year1 = '';
  var _state11 = '';
  var _village11 = '';
  
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
  late DateTimeRange dateRange1;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    dateRange1 = DateTimeRange(start: DateTime.now(), end: DateTime.now());
    super.initState();
  }

  void func1() {
    searchList1.sort((a, b) {
      return (_items[a.month] ?? 0).compareTo(_items[b.month] ?? 0);
    });
  }
  
  void func2() {
    searchList2.sort((a, b) {
      return int.parse(a.year).compareTo(int.parse(b.year));
    });
  }
  
  void func3() {
    searchList3.sort((a, b) {
      return (_items[a.month] ?? 0).compareTo(_items[b.month] ?? 0);
    });
  }
  
  void func4() {
    searchList4.sort((a, b) {
      return int.parse(a.year).compareTo(int.parse(b.year));
    });
  }
  
  void func5(List<Data> m1, List<Data> m2) {
    result1.clear();
    int k = 0;
    for (int i = 0; i < m1.length; i++) {
      for (int p = 0; p < m2.length; p++) {
        if (m2[p].year == m1[i].year && m2[p].month == m1[i].month) {
          k = 1;
          Data1 j = Data1();
          j.year = m1[i].year;
          j.month = m1[i].month;
          j.waterlevel = m1[i].waterlevel;
          j.waterlevel1 = m2[p].waterlevel;
          result1.add(j);
          break;
        }
      }
    }
    if (k == 0) {
      _fl = 1;
      return;
    }
    result1.sort((a, b) {
      return (_items[a.month] ?? 0).compareTo(_items[b.month] ?? 0);
    });
  }
  
  void func6(List<Data> m1, List<Data> m2) {
    result2.clear();
    int k = 0;
    for (int i = 0; i < m1.length; i++) {
      for (int p = 0; p < m2.length; p++) {
        if (m2[p].year == m1[i].year && m2[p].month == m1[i].month) {
          k = 1;
          Data1 j = Data1();
          j.year = m1[i].year;
          j.month = m1[i].month;
          j.waterlevel = m1[i].waterlevel;
          j.waterlevel1 = m2[p].waterlevel;
          result2.add(j);
          break;
        }
      }
    }
    if (k == 0) {
      _fl = 1;
      return;
    }

    result2.sort((a, b) {
      return int.parse(a.year).compareTo(int.parse(b.year));
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
          year: result['y'],
          latitude: result['l1'],
          longitude: result['l2'],
          month: result['m'],
          waterlevel: result['w'],
          wid: result['wid'],
          state: result['s'],
          village: result['v']);
    }).toList();

    setState(() {});
    return list;
  }

  getstate(String wid) {
    _state.clear();
    for (int i = 0; i < list.length; i++) {
      if (list[i].wid == wid) {
        var temp1 = _state.where((element) => element['value'] == list[i].state);
        if (temp1.length == 0) {
          _state.add({
            'value': list[i].state,
            'label': list[i].state,
          });
        }
      }
    }

    _state.sort((a, b) {
      return a['value'].compareTo(b['value']);
    });
  }

  searchFunctionality(String wid, String state1, String village1,
      String year21, String year1, String month21, String month1, String wid1, String state11, String village11) {
    searchList1.clear();
    searchList2.clear();
    searchList3.clear();
    searchList4.clear();
    result1.clear();
    result2.clear();
    _fl = 0;
    final validity = _formkey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();
    if (validity) {
      _formkey.currentState?.save();

      if (month1.length > 0 && year21.length > 0 && year1.length > 0 && month21.length > 0 && wid.length > 0 && state1.length > 0 && village1.length > 0) {
        for (int i = 0; i < list.length; i++) {
          if (list[i].wid == wid && (list[i].village).toLowerCase() == (village1).toLowerCase() && list[i].state == state1) {
            if (year1 != year21) {
              if (int.parse(list[i].year) == int.parse(year1) && (_items[list[i].month] ?? 0) >= int.parse(month1) && (_items[list[i].month] ?? 0) <= 12) {
                searchList1.add(list[i]);
                searchList2.add(list[i]);
              } else if (int.parse(list[i].year) == int.parse(year21) && (_items[list[i].month] ?? 0) <= int.parse(month21) && (_items[list[i].month] ?? 0) >= 1) {
                searchList1.add(list[i]);
                searchList2.add(list[i]);
              } else if (int.parse(list[i].year) > int.parse(year1) && int.parse(list[i].year) < int.parse(year21)) {
                searchList1.add(list[i]);
                searchList2.add(list[i]);
              }
            } else {
              if (int.parse(list[i].year) == int.parse(year1) && (_items[list[i].month] ?? 0) >= int.parse(month1) && (_items[list[i].month] ?? 0) <= int.parse(month21)) {
                searchList1.add(list[i]);
                searchList2.add(list[i]);
              }
            }
          }
        }
      } else if (wid.length > 0 && state1.length > 0 && village1.length > 0) {
        for (int i = 0; i < list.length; i++) {
          if (list[i].wid == wid && (list[i].village).toLowerCase() == (village1).toLowerCase() && list[i].state == state1) {
            searchList1.add(list[i]);
            searchList2.add(list[i]);
          }
        }
      } else {
        searchList1 = List<Data>.from(list);
        searchList2 = List<Data>.from(list);
      }
      
      // list 2
      if (month1.length > 0 && year21.length > 0 && year1.length > 0 && month21.length > 0 && wid1.length > 0 && state11.length > 0 && village11.length > 0) {
        for (int i = 0; i < list.length; i++) {
          if (list[i].wid == wid1 && (list[i].village).toLowerCase() == (village11).toLowerCase() && list[i].state == state11) {
            if (year1 != year21) {
              if (int.parse(list[i].year) == int.parse(year1) && (_items[list[i].month] ?? 0) >= int.parse(month1) && (_items[list[i].month] ?? 0) <= 12) {
                searchList3.add(list[i]);
                searchList4.add(list[i]);
              } else if (int.parse(list[i].year) == int.parse(year21) && (_items[list[i].month] ?? 0) <= int.parse(month21) && (_items[list[i].month] ?? 0) >= 1) {
                searchList3.add(list[i]);
                searchList4.add(list[i]);
              } else if (int.parse(list[i].year) > int.parse(year1) && int.parse(list[i].year) < int.parse(year21)) {
                searchList3.add(list[i]);
                searchList4.add(list[i]);
              }
            } else {
              if (int.parse(list[i].year) == int.parse(year1) && (_items[list[i].month] ?? 0) >= int.parse(month1) && (_items[list[i].month] ?? 0) <= int.parse(month21)) {
                searchList3.add(list[i]);
                searchList4.add(list[i]);
              }
            }
          }
        }
      } else if (wid1.length > 0 && state11.length > 0 && village11.length > 0) {
        for (int i = 0; i < list.length; i++) {
          if (list[i].wid == wid1 && (list[i].village).toLowerCase() == (village11).toLowerCase() && list[i].state == state11) {
            searchList3.add(list[i]);
            searchList4.add(list[i]);
          }
        }
      } else {
        searchList3 = List<Data>.from(list);
        searchList4 = List<Data>.from(list);
      }

      if (searchList1.length == 0 || searchList3.length == 0) {
        print("lp");
        _fl = 1;
      }
    }
  }

  String getFrom1() {
    _year1 = DateFormat('yyyy').format(dateRange1.start);
    _month1 = DateFormat('MM').format(dateRange1.start);
    return DateFormat('MM/yyyy').format(dateRange1.start);
  }

  String getUntil1() {
    _year21 = DateFormat('yyyy').format(dateRange1.end);
    _month21 = DateFormat('MM').format(dateRange1.end);
    return DateFormat('MM/yyyy').format(dateRange1.end);
  }

  Future pickDateRange1(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(hours: 24 * 3)),
    );
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1000),
      lastDate: DateTime(DateTime.now().year + 1000),
      initialDateRange: dateRange1,
    );

    if (newDateRange == null) return;

    setState(() => {dateRange1 = newDateRange});
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
                  title: Text(AppLocalizations.of(context)!.compare_graph),
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
                              hintText: AppLocalizations.of(context)!.wellid1,
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
                            key: ValueKey('state1'),
                            validator: (value) {
                              if (value == '') {
                                return AppLocalizations.of(context)!.required;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _state1 = value ?? '';
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search, color: Colors.green[900]),
                              hintText: AppLocalizations.of(context)!.state1,
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
                            key: ValueKey('village1'),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return AppLocalizations.of(context)!.required;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _village1 = value ?? '';
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.location_city, color: Colors.green[900]),
                              hintText: AppLocalizations.of(context)!.village1,
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
                          
                          // list 2 - Second well selection
                          SelectFormField(
                            initialValue: '',
                            labelText: 'Select Well Id',
                            items: _items_search,
                            key: ValueKey('wid1'),
                            validator: (value) {
                              if (value == '') {
                                return AppLocalizations.of(context)!.required;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _wid1 = value ?? '';
                              getstate(value ?? '');
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search, color: Colors.green[900]),
                              hintText: AppLocalizations.of(context)!.wellid2,
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
                            key: ValueKey('state11'),
                            validator: (value) {
                              if (value == '') {
                                return AppLocalizations.of(context)!.required;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _state11 = value ?? '';
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search, color: Colors.green[900]),
                              hintText: AppLocalizations.of(context)!.state2,
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
                            key: ValueKey('village11'),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return AppLocalizations.of(context)!.required;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _village11 = value ?? '';
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.location_city, color: Colors.green[900]),
                              hintText: AppLocalizations.of(context)!.village2,
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
                                      text: getFrom1(),
                                      onClicked: () => pickDateRange1(context),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: Colors.black87),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ButtonWidget(
                                      text: getUntil1(),
                                      onClicked: () => pickDateRange1(context),
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
                              if (_wid.length > 0 ||
                                  _state1.length > 0 ||
                                  _village1.length > 0 ||
                                  _year21.length > 0 ||
                                  _month21.length > 0 ||
                                  _month1.length > 0 ||
                                  _year1.length > 0 ||
                                  _wid1.length > 0 ||
                                  _state11.length > 0 ||
                                  _village11.length > 0) {
                                searchFunctionality(_wid, _state1, _village1, _year21, _year1, _month21, _month1, _wid1, _state11, _village11);
                                if (_fl != 1) {
                                  func1();
                                  func2();
                                  func3();
                                  func4();
                                  func5(searchList1, searchList3);
                                  if (_fl != 1) {
                                    func6(searchList2, searchList4);
                                  }
                                }
                                setState(() {});
                              } else {
                                searchFunctionality(_wid, _state1, _village1, _year21, _year1, _month21, _month1, _wid1, _state11, _village11);
                                setState(() {});
                              }
                            },
                          )),
                          SizedBox(height: 20),
                          result1.length > 0
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
                                                FastLineSeries<Data1, String>(
                                                  name: AppLocalizations.of(context)!.wellid1,
                                                  dataSource: result1,
                                                  xValueMapper: (Data1 gdp, _) => gdp.month,
                                                  yValueMapper: (Data1 gdp, _) => double.parse(gdp.waterlevel),
                                                  markerSettings: MarkerSettings(
                                                      isVisible: true, shape: DataMarkerType.rectangle),
                                                  dataLabelSettings: DataLabelSettings(isVisible: false, color: Colors.yellow),
                                                  enableTooltip: true,
                                                ),
                                                FastLineSeries<Data1, String>(
                                                  name: AppLocalizations.of(context)!.wellid2,
                                                  dataSource: result1,
                                                  xValueMapper: (Data1 gdp, _) => gdp.month,
                                                  yValueMapper: (Data1 gdp, _) => double.parse(gdp.waterlevel1),
                                                  markerSettings: MarkerSettings(
                                                      isVisible: true, shape: DataMarkerType.rectangle),
                                                  dataLabelSettings: DataLabelSettings(isVisible: false, color: Colors.yellow),
                                                  enableTooltip: true,
                                                ),
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
                                                FastLineSeries<Data1, String>(
                                                    name: AppLocalizations.of(context)!.wellid1,
                                                    dataSource: result2,
                                                    xValueMapper: (Data1 gdp, _) => gdp.year,
                                                    yValueMapper: (Data1 gdp, _) => double.parse(gdp.waterlevel),
                                                    markerSettings: MarkerSettings(
                                                        isVisible: true, shape: DataMarkerType.rectangle),
                                                    dataLabelSettings: DataLabelSettings(isVisible: false, color: Colors.yellow),
                                                    enableTooltip: true),
                                                FastLineSeries<Data1, String>(
                                                    name: AppLocalizations.of(context)!.wellid2,
                                                    dataSource: result2,
                                                    xValueMapper: (Data1 gdp, _) => gdp.year,
                                                    yValueMapper: (Data1 gdp, _) => double.parse(gdp.waterlevel1),
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
                                      AppLocalizations.of(context)!.norecord1,
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

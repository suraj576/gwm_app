import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:groundwater_management/l10n/language_picker.dart';
import 'package:groundwater_management/screens/welcome.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
var _uid = "";

class allDataList extends StatefulWidget {  
  @override
  _allDataListState createState() => _allDataListState();
}

class _allDataListState extends State<allDataList> {
  List<DocumentSnapshot> dataList = [];
  bool _loadingProducts = true;
  var _cntData=1;
  int _perpage = 20;
  DocumentSnapshot? _lastDocument;
  ScrollController _scrollController = ScrollController();
  bool _gettingMoreProducts = false;
  bool _moreProductsAvailable = true;

  getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _uid = user.uid;
    }
  }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  getDataList() async {
    Query q = _firestore.collection("data");
    
    setState(() {
      _loadingProducts = true;      
    });
    
    QuerySnapshot querySnapshot = await q.get();
    dataList = querySnapshot.docs;
    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    }

    setState(() {
      _loadingProducts = false;      
    });
  }
  
  _getMoreProducts() async {
    print('get product called');

    if(_moreProductsAvailable==false) {
      print("No more products");
      return;
    }

    if(_gettingMoreProducts==true) {
      return;
    }
  
    _gettingMoreProducts = true;

    Query q = _firestore.collection("data");
    
    QuerySnapshot querySnapshot = await q.get();
    
    if(querySnapshot.docs.length < _perpage) {
      _moreProductsAvailable = false;
    }
    
    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    }

    dataList.addAll(querySnapshot.docs);
    setState(() {
      _gettingMoreProducts = false;
    });
  }

  @override
  void initState(){
    super.initState();
    getDataList();
    _scrollController.addListener(() {
      double maxscroll = _scrollController.position.maxScrollExtent;
      double currentscroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height*0.25;
      
      if(maxscroll-currentscroll <= delta) {
        _getMoreProducts();
      }
    });
  }
  
  deleteUser(String id){
    DocumentReference documentReference = FirebaseFirestore.instance.collection('data').doc(id);
    documentReference.delete().whenComplete((){
      getDataList();
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.datadeleted,
          backgroundColor: Colors.green,
          textColor: Colors.white
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(
        AppLocalizations.of(context)!.datalist,
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
          )
        ],
      ),
      
      body: _loadingProducts == true  ?  
      Container(
        child: Center(
          child: Text("Loading..."),
        )):
      Container(
        child: dataList.length==0 ?
        Center(
          child: Text("No data to show"),
        ):   SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: EdgeInsets.fromLTRB(8, 20, 8, 5),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Container(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor:
                          MaterialStateColor.resolveWith((states) => Colors.lightBlue![50]!),
                          dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                          columns: [
                            DataColumn(label: Text(
                              AppLocalizations.of(context)!.latitude,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                            DataColumn(label: Text(
                              AppLocalizations.of(context)!.longitude,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                            DataColumn(label: Text(
                              AppLocalizations.of(context)!.year,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                            DataColumn(label: Text(
                              AppLocalizations.of(context)!.month,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                            DataColumn(label: Text(
                              AppLocalizations.of(context)!.waterlevel,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                            DataColumn(label: Text(
                              AppLocalizations.of(context)!.wellid,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                            DataColumn(label: Text(
                              AppLocalizations.of(context)!.state,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                            DataColumn(label: Text(
                              AppLocalizations.of(context)!.village,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                            DataColumn(label: Text(
                              AppLocalizations.of(context)!.mobile,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                            DataColumn(label: Text(
                              AppLocalizations.of(context)!.delete,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                          ],
                          rows: dataList
                              .map(
                            ((element) => DataRow(
                              cells: <DataCell>[
                                DataCell(Text(element['l1'] ?? '')),
                                DataCell(Text(element['l2'] ?? '')),
                                DataCell(Text(element['y'] ?? '')),
                                DataCell(Text(element['m'] ?? '')),
                                DataCell(Text(element['w'] ?? '')),
                                DataCell(Text(element['wid'] ?? '')),
                                DataCell(Text(element['s'] ?? '')),
                                DataCell(Text(element['v'] ?? '')),
                                DataCell(Text(element['phone'] ?? '')),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                        deleteUser(element['id'] ?? '');
                                    },
                                  ),
                                ),
                              ],
                            )),
                          ).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ))
        );
  }
}

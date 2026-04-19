import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:groundwater_management/l10n/language_picker.dart';
import 'package:groundwater_management/screens/welcome.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
var _uid = "";

class allUsersList extends StatefulWidget {  
  @override
  _allUsersListState createState() => _allUsersListState();
}

class _allUsersListState extends State<allUsersList> {
  List<DocumentSnapshot> userList = [];
  bool _loadingUsers = true;
  var _cntData = 1;
  int _perpage = 20;
  DocumentSnapshot? _lastDocument;
  ScrollController _scrollController = ScrollController();
  bool _gettingMoreUsers = false;
  bool _moreUsersAvailable = true;

  getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _uid = user.uid;
    }
  }
 
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  getUserList() async {
    Query q = _firestore.collection("user");
    
    setState(() {
      _loadingUsers = true;      
    });
    
    QuerySnapshot querySnapshot = await q.get();
    userList = querySnapshot.docs;
    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    }

    setState(() {
      _loadingUsers = false;      
    });
  }
  
  _getMoreUsers() async {
    print('get user called');

    if(_moreUsersAvailable == false) {
      print("No more user");
      return;
    }

    if(_gettingMoreUsers == true) {
      return;
    }
  
    _gettingMoreUsers = true;

    Query q = _firestore.collection("user");
    
    QuerySnapshot querySnapshot = await q.get();
    
    if(querySnapshot.docs.length < _perpage) {
      _moreUsersAvailable = false;
    }
    
    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    }

    userList.addAll(querySnapshot.docs);
    setState(() {
      _gettingMoreUsers = false;
    });
  }

  @override
  void initState(){
    super.initState();
    getCurrentUser();
    getUserList();
    _scrollController.addListener(() {
      double maxscroll = _scrollController.position.maxScrollExtent;
      double currentscroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      
      if(maxscroll - currentscroll <= delta) {
        _getMoreUsers();
      }
    });
  }
  
  deleteUser(String id){
    DocumentReference documentReference = FirebaseFirestore.instance.collection('user').doc(id);
    documentReference.delete().whenComplete((){
      getUserList();
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
        AppLocalizations.of(context)!.userlist,
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
      
      body: _loadingUsers == true  ?  
      Container(
        child: Center(
          child: Text("Loading..."),
        )):
      Container(
        child: userList.length == 0 ?
        Center(
          child: Text("No user to show"),
        ) : SingleChildScrollView(
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
                              AppLocalizations.of(context)!.name,
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
                              AppLocalizations.of(context)!.wellid,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                            DataColumn(label: Text(
                              AppLocalizations.of(context)!.address,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                            DataColumn(label: Text(
                              AppLocalizations.of(context)!.city,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                            DataColumn(label: Text(
                              AppLocalizations.of(context)!.pincode,
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
                              AppLocalizations.of(context)!.delete,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                              ),
                            )),
                          ],
                          rows: userList.map(
                            ((element) => DataRow(
                              cells: <DataCell>[
                                DataCell(Text(element['name'] ?? '')),
                                DataCell(Text(element['phone'] ?? '')),
                                DataCell(Text(element['wellid'] ?? '')),
                                DataCell(Text(element['address'] ?? '')),
                                DataCell(Text(element['city'] ?? '')),
                                DataCell(Text(element['pin'] ?? '')),
                                DataCell(Text(element['state'] ?? '')),
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

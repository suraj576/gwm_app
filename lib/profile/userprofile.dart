import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:groundwater_management/l10n/language_picker.dart';
import 'package:groundwater_management/profile/editprofile.dart';
import 'package:groundwater_management/screens/welcome.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
var _uid = '';

class Profile extends StatefulWidget {
  final List _items1;  // FIXED: Added final keyword
  Profile(this._items1, {Key? key}) : super(key: key);  // FIXED: Added Key? parameter

  @override
  _ProfileState createState() => _ProfileState(_items1);
}

class _ProfileState extends State<Profile> {
  final List _items1;  // FIXED: Added final keyword
  _ProfileState(this._items1);
  
  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }
  
  getCurrentUser() async {
    User? user = _auth.currentUser;  // FIXED: Proper syntax for getting current user
    if (user != null) {
      _uid = user.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),  // FIXED: Added !
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
          ),
        ],
      ),

      body: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(20),
        children: [
          Center(
            child: ClipOval(
              child: Material(
                color: Colors.transparent,
                child: Ink.image(
                  image: AssetImage('assets/profile_img.png'),
                  fit: BoxFit.cover,
                  width: 128,
                  height: 128,
                  child: InkWell(onTap: (){}),   
                ),
              ),
            ),          
          ),

          SizedBox(height: 10),
          Center(
            child: Text(
              _items1[0]['value'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
   
          SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),  
            child: Card(
              elevation: 4,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(
                      _items1[1]['value'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        ),
                    ),
                    dense: true,
                  ),
                  Divider(
                    height: 0.6,
                    color: Colors.black87,
                  ),
                  ListTile(
                    leading: Icon(Icons.confirmation_number),
                    title: Text(
                      _items1[2]['value'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        ),
                    ),
                    dense: true,
                  ),
                  Divider(
                    height: 0.6,
                    color: Colors.black87,
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text(
                      _items1[3]['value'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        ),
                    ),
                    dense: true,
                  ),
                  Divider(
                    height: 0.6,
                    color: Colors.black87,
                  ),
                  ListTile(
                    leading: Icon(Icons.location_city),
                    title: Text(
                      _items1[4]['value'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        ),
                    ),
                    dense: true,
                  ),
                  Divider(
                    height: 0.6,
                    color: Colors.black87,
                  ),
                  ListTile(
                    leading: Icon(Icons.confirmation_number),
                    title: Text(
                      _items1[5]['value'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        ),
                    ),
                    dense: true,
                  ),
                  Divider(
                    height: 0.6,
                    color: Colors.black87,
                  ),
                  ListTile(
                    leading: Icon(Icons.location_searching),
                    title: Text(
                      _items1[6]['value'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        ),
                      ),
                      dense: true,
                  ),
                ],
              ),
            ),
          ),        
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditProfile(_items1)
          ));
        },
        tooltip: 'Edit',
        child: Icon(
          Icons.edit,
          color: Colors.red,
        ),
        backgroundColor: Colors.orange,  // FIXED: Removed invalid !
      ),
    );
  }
}

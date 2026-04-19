import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  String phone;
  Admin({required this.phone});
}

Future<bool> checkRole(String phone) async{
  bool isAdmin= false;
  List details = [];
  await FirebaseFirestore.instance.collection("admin").get().then((value) {
        details = value.docs.map((result) {
        print(phone);
        print(result['phone']);
        return Admin(
          phone: result['phone']);
      }).toList();
  });   
    
  for (int u = 0; u < details.length; u++) {
      if(details[u].phone== phone){
        isAdmin = true;
        break;
      }
  }
  print('anjai');
  print(isAdmin);
  return isAdmin;
}

import 'package:flutter/material.dart';
import 'components/add_data.dart';

class AddDataScreen extends StatelessWidget {
  List _items1;
  String _phone;
  AddDataScreen(this._items1,this._phone);
  @override
  Widget build(BuildContext context) {
    return AddData(_items1,_phone);
  }
}

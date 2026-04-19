import 'package:flutter/material.dart';
import 'components/view_added_data.dart';

class ViewAddedDataScreen extends StatelessWidget {
  List _items1;
  ViewAddedDataScreen(this._items1);
  @override
  Widget build(BuildContext context) {
    return OwnData(_items1);
  }
}

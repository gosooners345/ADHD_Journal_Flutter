import 'package:flutter/material.dart';




extension ListUpdate on List<dynamic>{

  void update(dynamic object, int index){
    this.removeAt(index);
    this.insert(index, object);

  }
}
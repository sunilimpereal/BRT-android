import 'dart:convert';

import 'package:BRT/models/reserve.dart';
import 'package:BRT/models/states.dart';

class CheckPost {
  String id;

  String name;
  Reserve reserve;
  CheckPost({this.id, this.name, this.reserve});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'reserve': reserve.toMap()};
  }

  factory CheckPost.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return CheckPost(
        id: map['id'].toString(),
        name: map['name'],
        reserve: Reserve.fromMap(map['reserve']));
  }

  String toJson() => json.encode(toMap());

  factory CheckPost.fromJson(String source) =>
      CheckPost.fromMap(json.decode(source));
}

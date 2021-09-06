import 'dart:convert';

import 'package:BRT/models/states.dart';

class Reserve {
  String id;
  StatesModel state;
  String name;
  Reserve({
    this.id,
    this.state,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'state': state?.toMap(),
      'name': name,
    };
  }

  factory Reserve.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Reserve(
      id: map['id'].toString(),
      state: StatesModel.fromMap(map['state']),
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Reserve.fromJson(String source) =>
      Reserve.fromMap(json.decode(source));
}

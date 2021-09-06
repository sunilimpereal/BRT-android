import 'dart:convert';

class StatesModel {
  String id, name, rtoCode;
  StatesModel({this.id, this.name, this.rtoCode});

  StatesModel.fromMap(Map<String, dynamic> map) {
    this.id = map['id'].toString();
    this.name = map['name'];
    this.rtoCode = map['rto_code'];
  }

  Map<String, dynamic> toMap() {
    return {
      'rto_code': rtoCode,
      'id': id,
      'name': name,
    };
  }

  String toJson() => json.encode(toMap());

  factory StatesModel.fromJson(String source) =>
      StatesModel.fromMap(json.decode(source));
}

import 'dart:convert';

class Vehicle {
  String type,
      districtCode,
      series,
      uniqueNumber,
      driverName,
      driverPhone,
      state;
  Vehicle(
      {this.type,
      this.districtCode,
      this.series,
      this.uniqueNumber,
      this.driverName,
      this.driverPhone,
      this.state});

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'district_code': districtCode,
      'series': series,
      'number': uniqueNumber,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'state': state
    };
  }

  Vehicle.fromMap(Map<String, dynamic> map) {
    this.districtCode = map['district_code'];
    this.driverName = map['driver_name'];
    this.driverPhone = map['driver_phone'];
    this.series = map['series'];
    this.type = map['type'];
    this.state = map['state'].toString();
    this.uniqueNumber = map['number'];
  }

  String toJson() => json.encode(toMap());

  factory Vehicle.fromJson(String source) =>
      Vehicle.fromMap(json.decode(source));
}

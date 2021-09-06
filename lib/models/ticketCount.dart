import 'dart:convert';

class TicketCountModel {
  String entryTickets;
  String fineTickets;
  String vehicleInside;
  TicketCountModel({
    this.entryTickets,
    this.fineTickets,
    this.vehicleInside,
  });

  Map<String, dynamic> toMap() {
    return {
      'entry_ticket': entryTickets,
      'fine-only-ticket': fineTickets,
      'vehicles_inside': vehicleInside,
    };
  }

  factory TicketCountModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    return TicketCountModel(
      entryTickets: map['entry_ticket'].toString(),
      fineTickets: map['fine-only-ticket'].toString(),
      vehicleInside: map['vehicles_inside'].toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory TicketCountModel.fromJson(String source) =>
      TicketCountModel.fromMap(json.decode(source));
}

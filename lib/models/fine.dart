import 'dart:convert';

class Fine {
  List<dynamic> fineId;
  String fineamout;
  String ticketId;

  Fine({this.fineId, this.fineamout, this.ticketId});

  Map<String, dynamic> toMap() {
    return {
      'fine': fineId, 'amount': fineamout,
      //'ticket': ticketId
    };
  }

  factory Fine.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Fine(
        fineId: map['fine'],
        fineamout: map['amount'].toString(),
        ticketId: map['ticket']);
  }

  String toJson() => json.encode(toMap());

  factory Fine.fromJson(String source) => Fine.fromMap(json.decode(source));
}
//return {'fine': fineId, 'amount': fineamout, 'ticket': ticketId};

import 'package:BRT/models/fine.dart';
import 'package:BRT/models/raiseFine.dart';
import 'package:BRT/services/database.dart';
import 'package:sembast/sembast.dart';
import 'package:BRT/main.dart';

class RaiseFineDao {
  static const String _ticketCountFolderName = 'raisedFineTickets';
  final _raisedFineTicketStore =
      intMapStoreFactory.store(_ticketCountFolderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(RaisedFineModel ticket) async {
    final response =
        await _raisedFineTicketStore.add(await _db, ticket.toMap());
    return response;
  }

  Future remove(RaisedFineModel ticket) async {
    //  await _raisedFineTicketStore.delete(await _db, finder: finder);

    final finder = Finder(filter: Filter.equals("ticket", ticket.ticketNumber));
    // final finder = Finder(filter: Filter.byKey(ticket.ticketNumber));

    int a = await _raisedFineTicketStore.delete(await _db, finder: finder);
    print(a);
  }

  Future<List<RaisedFineModel>> getAllRaisedFineTickets() async {
    final records = await _raisedFineTicketStore.find(await _db);
    return records.map((snapshot) {
      final tickets = RaisedFineModel.fromMap(snapshot.value);

      return tickets;
    }).toList();
  }
}

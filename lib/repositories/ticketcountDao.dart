import 'package:BRT/models/ticketCount.dart';
import 'package:BRT/services/database.dart';
import 'package:sembast/sembast.dart';

class TicketCountDao {
  static const String _ticketCountFolderName = 'ticketCount';
  final _ticketCountFolderStore =
      intMapStoreFactory.store(_ticketCountFolderName);

  Future<Database> get _db async => await AppDatabase.instance.database;
  Future insertTicketCount(TicketCountModel ticket) async {
    final response =
        await _ticketCountFolderStore.add(await _db, ticket.toMap());
    return response;
  }

  Future updateTicketCount(TicketCountModel ticket) async {
    final response =
        await _ticketCountFolderStore.update(await _db, ticket.toMap());
    return response;
  }

  Future<TicketCountModel> getAllCountsFromLocal() async {
    final records = await _ticketCountFolderStore.findFirst(await _db);
    if (records != null) {
      return TicketCountModel.fromMap(records.value);
    } else {
      return null;
    }
  }
}

import 'package:BRT/models/entryTicket.dart';
import 'package:BRT/services/database.dart';
import 'package:BRT/services/utilityFunctions.dart';
import 'package:sembast/sembast.dart';

class FineTicketDao {
  static const String fineTicketStoreName = "FineTickets";
  final _entryTicketStore = intMapStoreFactory.store(fineTicketStoreName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(EntryTicketModel ticket) async {
    final response = await _entryTicketStore.add(await _db, ticket.toMap());
    return response;
  }

  Future<String> getFineTicketCount() async {
    final tickets = await getTicketsByDate(DateTime.now().toUtc());
    String count =
        tickets.where((element) => element.fine != null).length.toString();
    return count;
  }

  Future remove(EntryTicketModel ticket) async {
    final finder = Finder(filter: Filter.byKey(ticket.ticketNumber));
    await _entryTicketStore.delete(await _db, finder: finder);
  }

  Future<List<EntryTicketModel>> getAllFineTickets() async {
    final records = await _entryTicketStore.find(await _db);
    return records.map((snapshot) {
      final tickets = EntryTicketModel.fromMap(snapshot.value);
      return tickets;
    }).toList();
  }

  
  

  Future<List<EntryTicketModel>> getTicketsByDate(DateTime date) async {
    final records = await _entryTicketStore.find(await _db);
    return records
        .map((snapshot) {
          final tickets = EntryTicketModel.fromMap(snapshot.value);
          return tickets;
        })
        .toList()
        .where((element) =>
            getFormattedDate(DateTime.parse(element.date)) ==
            getFormattedDate(date))
        .toList()
        .reversed
        .toList();
  }
}

import 'package:BRT/main.dart';
import 'package:BRT/models/entryTicket.dart';
import 'package:BRT/models/ticketCount.dart';
import 'package:BRT/services/database.dart';
import 'package:BRT/services/utilityFunctions.dart';
import 'package:sembast/sembast.dart';
import 'package:BRT/models/raiseFine.dart';

class TicketCollectorDao {
  static const String ticketCollectorStoreName = "ticketCollector";
  final _ticketCollectorStore =
      intMapStoreFactory.store(ticketCollectorStoreName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  /// returns generated key after saving
  Future<int> insert(EntryTicketModel ticket) async {
    final response = await _ticketCollectorStore.add(await _db, ticket.toMap());
    return response;
  }

  Future remove(EntryTicketModel ticket) async {
    final finder = Finder(filter: Filter.equals("number", ticket.ticketNumber));
    // final finder = Finder(filter: Filter.byKey(ticket.ticketNumber));
    print(finder.toString());
    int a = await _ticketCollectorStore.delete(await _db, finder: finder);
    print(a);
  }

  Future<List<EntryTicketModel>> getAllEntryTickets() async {
    final records = await _ticketCollectorStore.find(await _db);
    return records
        .map((snapshot) {
          final tickets = EntryTicketModel.fromMap(snapshot.value);

          return tickets;
        })
        .toList()
        .reversed;
  }

  Future<void> deleteTicketCollection() async {
    await _ticketCollectorStore.drop(await _db);
  }

  Future<TicketCountModel> getOfflineTicketCount() async {
    final tickets = await getTicketsByDate(DateTime.now().toUtc());

    TicketCountModel ticketCountModel = TicketCountModel(
        vehicleInside: tickets
            .where((element) => element.hasExited == false)
            .length
            .toString(),
        entryTickets: tickets.length.toString(),
        fineTickets:
            tickets.where((element) => element.fine != null).length.toString());

    return ticketCountModel;
  }

  /// Takes the ticket and change its Exited property to true [Offline Storage]
  Future markExitOffline(EntryTicketModel ticket) async {
    final finder = Finder(filter: Filter.equals("number", ticket.ticketNumber));

    //  _entryTicketStore.delete(await _db, finder: finder);
    await _ticketCollectorStore.update(await _db, ticket.toMap(),
        finder: finder);

    //  var record = await _entryTicketStore.findFirst(await _db, finder: finder);

    //print(record.toString());
  }

  Future<void> raiseFineOffline(RaisedFineModel fine) async {
    double amount = 0;
    final finder = Finder(filter: Filter.equals("number", fine.ticketNumber));
    var record =
        await _ticketCollectorStore.findFirst(await _db, finder: finder);

    EntryTicketModel ticket = EntryTicketModel.fromMap(record.value);
    for (var fineAmount in fine.fine) {
      amount += double.parse(fineAmount.fineamout);
    }
    ticket.fine != null
        ? ticket.fine.addAll(fine.fine)
        : ticket.fine = fine.fine;
    ticket.totalfine = (double.parse(ticket.totalfine) + amount).toString();
    //  _entryTicketStore.delete(await _db, finder: finder);
    await _ticketCollectorStore.update(await _db, ticket.toMap(),
        finder: finder);
  }

  Future<List<EntryTicketModel>> getTicketsByDate(DateTime date) async {
    final records = await _ticketCollectorStore.find(await _db);
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

import 'package:BRT/main.dart';
import 'package:BRT/models/entryTicket.dart';
import 'package:BRT/models/ticketCount.dart';
import 'package:BRT/repositories/fineTicketDao.dart';
import 'package:BRT/services/database.dart';
import 'package:BRT/services/utilityFunctions.dart';
import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';

class EntryTicketDao {
  static const String entryTicketStoreName = "EntryTickets";
  final _entryTicketStore = intMapStoreFactory.store(entryTicketStoreName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  /// returns generated key after saving
  Future<int> insert(EntryTicketModel ticket) async {
    final response = await _entryTicketStore.add(await _db, ticket.toMap());
    return response;
  }

  Future remove(EntryTicketModel ticket) async {
    final finder = Finder(filter: Filter.equals("number", ticket.ticketNumber));
    // final finder = Finder(filter: Filter.byKey(ticket.ticketNumber));
    print(finder.toString());
    int a = await _entryTicketStore.delete(await _db, finder: finder);
    print(a);
  }

  Future markExitOffline(EntryTicketModel ticket) async {
    final finder = Finder(filter: Filter.equals("number", ticket.ticketNumber));
    //  _entryTicketStore.delete(await _db, finder: finder);
    // if(finder.)
    final list = await _entryTicketStore.find(await _db, finder: finder);
    if (list.isEmpty) {
      await _entryTicketStore.add(await _db, ticket.toMap());
    } else {
      await _entryTicketStore.update(await _db, ticket.toMap(), finder: finder);
    }

    await ticketCollectorDao.markExitOffline(ticket);

    //  var record = await _entryTicketStore.findFirst(await _db, finder: finder);

    //print(record.toString());
  }

  Future<List<EntryTicketModel>> getAllEntryTickets() async {
    final records = await _entryTicketStore.find(await _db);
    return records.map((snapshot) {
      final tickets = EntryTicketModel.fromMap(snapshot.value);

      return tickets;
    }).toList();
  }

  Future<TicketCountModel> getOfflineTicketCount() async {
    final tickets = await getTicketsByDate(DateTime.now().toUtc());

    TicketCountModel ticketCountModel = TicketCountModel(
        vehicleInside: tickets
            .where((element) =>
                element.hasExited == false && element.stayStatus == null)
            .length
            .toString(),
        entryTickets: tickets.length.toString(),
        fineTickets: await FineTicketDao().getFineTicketCount());

    return ticketCountModel;
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

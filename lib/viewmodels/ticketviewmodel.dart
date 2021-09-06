import 'dart:convert';

import 'package:BRT/main.dart';
import 'package:BRT/models/entryTicket.dart';
import 'package:BRT/models/fine.dart';
import 'package:BRT/models/raiseFine.dart';
import 'package:BRT/models/reserve.dart';
import 'package:BRT/models/reservestay.dart';
import 'package:BRT/models/states.dart';
import 'package:BRT/models/ticketCount.dart';
import 'package:BRT/services/httpServices.dart';
import 'package:BRT/strings.dart';

import '../services/utilityFunctions.dart';

class TicketViewModel {
  final String _accessToken;
  TicketViewModel(this._accessToken);

  Future<Response> saveTicket(EntryTicketModel ticket) async {
    final body = ticket.toMap();
    final response = await postRequest(
        accessToken: _accessToken,
        api: "ticket/",
        body: body,
        successStatusCode: 201);
    return response;
  }

  Future<Response> updateTicket(EntryTicketModel ticket) async {
    final body = ticket.toMap();
    final response = await putRequest(
        accessToken: _accessToken,
        api: "ticket/${ticket.ticketNumber}/",
        body: body,
        successStatusCode: 200);
    return response;
  }

  Future<TicketCountModel> getTicketCount() async {
    TicketCountModel count;
    final current = DateTime.now();
    final response = await postRequest(
      accessToken: _accessToken,
      successStatusCode: 200,
      body: {
        "start_range": DateTime(current.year, current.month, current.day)
            .toUtc()
            .toString()
            .substring(0, 19),
        "end_range": DateTime(current.year, current.month, current.day + 1)
            .toUtc()
            .toString()
            .substring(0, 19)
      },
      api: 'ticket-count/',
    );
    if (response.didSucceed) {
      final decodedResponse = json.decode(response.object);
      count = TicketCountModel.fromMap(decodedResponse);
    }
    return count;
  }

  Future<List<EntryTicketModel>> getAllTickets() async {
    List<EntryTicketModel> tickets = [];
    final response = await getRequest(
      accessToken: _accessToken,
      api: 'ticket/',
      successStatusCode: 200,
    );
    if (response.didSucceed) {
      if (response.object != null) {
        final decodedResponse = json.decode(response.object);
        for (var ticket in decodedResponse["tickets"]) {
          tickets.add(EntryTicketModel.fromMap(ticket));
        }
      }
    }
    return tickets;
  }

  Future<List<EntryTicketModel>> getTicketsByDate(DateTime date) async {
    List<EntryTicketModel> tickets = [];
    final response = await getRequest(
      accessToken: _accessToken,
      api:
          'ticket/?entry_ts__gte=${getFormattedDate(date)} 00:00:00&entry_ts__lte=${getFormattedDate(date.add(Duration(days: 1)))} 06:30:00',
      successStatusCode: 200,
    );
    if (response.didSucceed) {
      if (response.object != null) {
        final decodedResponse = json.decode(response.object);
        for (var ticket in decodedResponse["tickets"]) {
          tickets.add(EntryTicketModel.fromMap(ticket));
        }
      }
    }
    return tickets;
  }

  Future<Response> raiseFine(RaisedFineModel fine) async {
    final body = fine.toMap();
    final response = await postRequest(
        accessToken: accessToken,
        api: "raise-fine/",
        body: body,
        successStatusCode: 201);
    return response;
  }

  Future<Response> saveFineTicket(EntryTicketModel ticket) async {
    final body = ticket.toMap();
    final response = await postRequest(
        accessToken: _accessToken,
        api: "/fine-only-ticket/",
        body: body,
        successStatusCode: 201);

    return response;
  }

  Future<List<StatesModel>> getStatesList() async {
    final List<StatesModel> states = [];
    final response = await getRequest(
        accessToken: _accessToken,
        api: "reserve-state/",
        successStatusCode: 200);
    if (response.didSucceed) {
      if (response.object != null) {
        final decodedResponse = json.decode(response.object);
        for (var state in decodedResponse) {
          StatesModel statesModel = StatesModel.fromMap(state);
          states.add(statesModel);
        }
      }
    }
    return states;
  }

  // Future<Response> markExit(EntryTicketModel ticket) {
  //   final response = patchRequest(
  //     accessToken: _accessToken,
  //     successStatusCode: 200,
  //     api: "ticket/" + ticketNumber + "/",
  //     body: {"has_exited": "true"},
  //   );
  //   return response;
  // }

  Future<List<Reserve>> getReserveList() async {
    final List<Reserve> reserves = [];
    final response = await getRequest(
        accessToken: _accessToken, api: "reserve/", successStatusCode: 200);
    if (response.didSucceed) {
      if (response.object != null) {
        final decodedResponse = json.decode(response.object);
        for (var reserve in decodedResponse) {
          Reserve statesModel = Reserve.fromMap(reserve);
          reserves.add(statesModel);
        }
      }
    }
    return reserves;
  }

  Future<List<ReserveStay>> getReserveStayList() async {
    final List<ReserveStay> reserves = [];
    final response = await getRequest(
        accessToken: _accessToken,
        api: "reserve-stay/",
        successStatusCode: 200);
    if (response.didSucceed) {
      if (response.object != null) {
        final decodedResponse = json.decode(response.object);
        for (var reserve in decodedResponse) {
          ReserveStay statesModel = ReserveStay.fromMap(reserve);
          reserves.add(statesModel);
        }
      }
    }
    return reserves;
  }

  Future<EntryTicketModel> getTicketByNumber(String ticketNumber) async {
    EntryTicketModel ticket;
    // final number = json.decode(ticketNumber)['number'];
    final response = await getRequest(
        accessToken: _accessToken,
        api: 'ticket/$ticketNumber/',
        successStatusCode: 200);
    if (response.didSucceed) {
      if (response.object != null) {
        final decodedResponse = json.decode(response.object);
        ticket = EntryTicketModel.fromMap(decodedResponse);
      }
    }
    return ticket;
  }
}

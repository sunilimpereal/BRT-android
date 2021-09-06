import 'package:BRT/models/checkpost.dart';
import 'package:BRT/models/reserve.dart';
import 'package:BRT/models/reservestay.dart';
import 'package:BRT/models/states.dart';
import 'package:BRT/models/ticketCount.dart';

// Global App Variables
List<StatesModel> availableStates = [];
TicketCountModel ticketCount;
List<ReserveStay> availableReserves = [];
List<CheckPost> availableCheckPost = [];
String lastSyncTime;

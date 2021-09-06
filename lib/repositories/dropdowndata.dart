import 'package:BRT/models/checkpost.dart';
import 'package:BRT/models/reserve.dart';
import 'package:BRT/models/reservestay.dart';
import 'package:BRT/models/states.dart';
import 'package:BRT/services/database.dart';
import 'package:sembast/sembast.dart';

class DropDownDataDao {
  static const String _statesFolderName = 'states';
  static const String _reservesFolderName = 'reserves';
  static const String _checkPostFolderName = 'checkpost';

  final _statesFolderStore = intMapStoreFactory.store(_statesFolderName);
  final _reserveFolderStore = intMapStoreFactory.store(_reservesFolderName);
  final _checkPostFolderStore = intMapStoreFactory.store(_checkPostFolderName);
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insertStates(StatesModel state) async {
    final response = await _statesFolderStore.add(await _db, state.toMap());
    return response;
  }

  Future insertReserves(ReserveStay reserve) async {
    final response = await _reserveFolderStore.add(await _db, reserve.toMap());
    return response;
  }

  Future insertCheckPost(CheckPost checkPost) async {
    final response =
        await _checkPostFolderStore.add(await _db, checkPost.toMap());
    return response;
  }

  Future updateStates(StatesModel state) async {
    final response = await _statesFolderStore.update(await _db, state.toMap());
    return response;
  }

  Future updateReserves(ReserveStay reserve) async {
    final response =
        await _reserveFolderStore.update(await _db, reserve.toMap());
    return response;
  }

  Future updateCheckPost(CheckPost cp) async {
    final response = await _checkPostFolderStore.update(await _db, cp.toMap());
    return response;
  }

  Future<List<StatesModel>> getAllStatesFromLocal() async {
    final records = await _statesFolderStore.find(await _db);
    return records.map((snapshot) {
      final states = StatesModel.fromMap(snapshot.value);
      return states;
    }).toList();
  }

  Future<List<ReserveStay>> getAllReservesFromLocal() async {
    final records = await _reserveFolderStore.find(await _db);
    return records.map((snapshot) {
      final states = ReserveStay.fromMap(snapshot.value);
      return states;
    }).toList();
  }

  Future<bool> isStateDataEmpty() async {
    final records = await _statesFolderStore.find(await _db);
    return records.isEmpty;
  }

  Future<bool> isReserveDataEmpty() async {
    final records = await _reserveFolderStore.find(await _db);
    return records.isEmpty;
  }

  Future<bool> isCheckPostDataEmpty() async {
    final records = await _checkPostFolderStore.find(await _db);
    return records.isEmpty;
  }

  Future<List<CheckPost>> getAllCheckPostsFromLocal() async {
    final records = await _checkPostFolderStore.find(await _db);
    return records.map((snapshot) {
      final checkPosts = CheckPost.fromMap(snapshot.value);
      return checkPosts;
    }).toList();
  }
}

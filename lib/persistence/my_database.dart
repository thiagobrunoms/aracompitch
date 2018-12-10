import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class MyDatabase {
  String _databasePath;
  String _databaseFullPath;
  Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;

    _db = await initDb();
    return _db;
  }

  //Creating a database with name test.dn in your directory
  initDb() async {
    _databasePath = await getDatabasesPath();

    String path = p.join(_databasePath, "pitch.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    print("chamou on create de db");
    await db
        .execute("CREATE TABLE MyIdeas(id INTEGER PRIMARY KEY, ideaId TEXT )");

    await db.execute(
        "CREATE TABLE MyWishes(id INTEGER PRIMARY KEY, wishId TEXT, ideaId TEXT )");

    print("Created tables");
  }

  void saveIdea(String ideaId) async {
    print("Saving idea: " + ideaId);
    var dbTransaction = await db;
    await dbTransaction.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO MyIdeas(ideaId) VALUES(' + '\'' + ideaId + '\'' + ')');
    });
  }

  Future saveAWish(String wishId, String ideaId) async {
    print("Saving idea: ${ideaId} com id de firebase = ${wishId}");
    var dbTransaction = await db;
    var response = await dbTransaction.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO MyWishes(wishId, ideaId) VALUES(' +
              '\'' +
              wishId +
              '\'' +
              ',' +
              '\'' +
              ideaId +
              '\')');
    });

    return response;
  }

  Future<List<Map>> getMyIdeas() async {
    print("getting ideias");
    var dbTransaction = await db;
    List<Map> list = await dbTransaction.rawQuery('SELECT * FROM MyIdeas');
    for (int i = 0; i < list.length; i++) {
      print(list[i]);
    }

    return list;
  }

  Future<List<Map>> getMyWishes() async {
    print("getting wishes");
    var dbTransaction = await db;
    List<Map> list = await dbTransaction.rawQuery('SELECT * FROM MyWishes');

    return list;
  }

  void deleteIdea(String ideaId) async {
    print("Deleting idea: " + ideaId);
    var dbTransaction = await db;
    await dbTransaction.transaction((txn) async {
      return await txn.rawInsert(
          'DELETE FROM MyIdeas WHERE ideaId=' + '\'' + ideaId + '\'');
    });
  }

  void deleteAWish(String wishId) async {
    print("Deleting idea: " + wishId);
    var dbTransaction = await db;
    await dbTransaction.transaction((txn) async {
      return await txn.rawInsert(
          'DELETE FROM MyWishes WHERE wishId=' + '\'' + wishId + '\'');
    });
  }
}

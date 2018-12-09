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

    String path = p.join(_databasePath, "test.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db
        .execute("CREATE TABLE MyWishes(id INTEGER PRIMARY KEY, ideaId TEXT )");
    print("Created tables");
  }

  void saveIdea(String ideaId) async {
    print("Saving idea: " + ideaId);
    var dbTransaction = await db;
    await dbTransaction.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO MyWishes(ideaId) VALUES(' + '\'' + ideaId + '\'' + ')');
    });
  }

  Future<List<Map>> getMyIdeas() async {
    print("getting ideias");
    var dbTransaction = await db;
    List<Map> list = await dbTransaction.rawQuery('SELECT * FROM MyWishes');
    for (int i = 0; i < list.length; i++) {
      print(list[i]);
    }

    return list;
  }
}

import 'package:proverbs_app/models/proverb.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor(); // singleton => single instance of database

  final String _table = "proverbs";
  final String _id = "id";
  final String _eng = "eng";
  final String _kor = "kor";
  final String _explain = "explain";
  final String _seen = "seen";
  late String _favorite = "favorite";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<void> deleteDatabase(String databasePath) async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    await deleteDatabase(databasePath);
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE $_table (
          $_id INTEGER PRIMARY KEY,
          $_eng TEXT NOT NULL,
          $_kor TEXT NOT NULL,
          $_explain TEXT NOT NULL,
          $_seen INTEGER NOT NULL,
          $_favorite INTEGER NOT NULL
        )
        ''');


        // proverbs upload
        await addProverbs(db, "Empty cart is noisy.", "빈수레가 요란하다", "The little they know, the louder they become.");
        await addProverbs(db, "Where soybeans planted, soybeans sprout,\nWhere red beans planted, red beans sprout.", "콩 심은데 콩나고 팥 심은데 팥난다", "In everything, there is a result that matches the cause.");
        await addProverbs(db, "Stopping going is worse than not going.", "가다 말면 안가는 것만 못하다", "If you're going to quit doing something midway,\n it's better not to do it in the first place.");
        await addProverbs(db, "Would you be full with one spoonful of food?", "한 술 밥에 배 부르랴", "No matter what, it is difficult to get good results right from the start.");
        await addProverbs(db, "It takes two hands to make a sound.", "손뼉도 마주 쳐야 소리가 난다", "The good and bad between people originate from themselves.");
        await addProverbs(db, "See one, Know ten.", "하나를 보고 열을 안다", "If you look at one thing, you can infer the whole thing.");
        await addProverbs(db, "Even a tiger comes when talked about.", "호랑이도 제 말하면 온다", "When someone is talked about, they appear in an unexpected way.");
        await addProverbs(db, "Beat on the stone bridge before crossing it", "돌다리도 두들겨 보고 건너라", "Even if it seems safe, be careful before making choice.");
        await addProverbs(db, "Even if the sky falls, there is a hole to emerge from.", "하늘이 무너져도 솟아날 구멍이 있다", "No matter how difficult something is, there is a way to solve it.");

      },
    );
  }
  Future<void> favorite(int id) async{
    final db=await database;
    await db.update(_table, {
      _favorite:1,
    },
        where: 'id =?',
        whereArgs: [
          id,
        ]

    );

  }

  Future<void> unfavorite(int id) async{
    final db=await database;
    await db.update(_table, {
      _favorite:0,
    },
        where: 'id =?',
        whereArgs: [
          id,
        ]

    );
  }
  static Future<void> addProverbs(Database db, String eng, String kor, String explain) async {
    final String _table = "proverbs";
    final String _id = "id";
    final String _eng = "eng";
    final String _kor = "kor";
    final String _explain = "explain";
    final String _seen = "seen";
    final String _favorite = "favorite";
    try {
      await db.insert(
        _table,
        {
          _eng: eng,
          _kor: kor,
          _explain: explain,
          _seen: 0,
          _favorite: 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Proverb added: $eng');
    } catch (e) {
      print('Error inserting proverb: $e');
    }
  }

  Future<List<Proverb>> getProverbs() async {
    final db = await database;
    try {
      final data = await db.query(_table);
      print(data); // Print the raw data for debugging

      return data.map((e) => Proverb(
        id: e[_id] as int,
        eng: e[_eng] as String,
        kor: e[_kor] as String,
        explain: e[_explain] as String,
        seen: e[_seen] as int,
        favorite: e[_favorite] as int,
      )).toList();
    } catch (e) {
      print('Error fetching proverbs: $e');
      return [];
    }
  }
}

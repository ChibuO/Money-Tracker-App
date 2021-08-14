import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
//import 'package:path_provider/path_provider.dart';

//database table and column names
/*final String tableEntries = "entries";
final String columnId = "_id";
final String columnTitle = "title";
final String columnBalance = "balance";
final String columnDate = "last date";
final String columnAction = "last action";
final String columnLastAmount = "last amount"; */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("yelp");

  //open the database and store the reference
  final Future<Database> database = openDatabase(
    //set the path to the database
    join(await getDatabasesPath(), 'bank_database.db'),
    //when first created, create a table to store entries
    onCreate: (db, version) {
      //run the CREATE TABLE statement on the database
      return db.execute("CREATE TABLE entries(id INTEGER PRIMARY KEY, "
          "title TEXT NOT NULL, balance REAL NOT NULL, date TEXT NOT NULL, "
          "action TEXT NOT NULL, lastAmount REAL NOT NULL, note TEXT NOT NULL");
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  //function that inserts entries into the database
  Future<void> insertEntry(Entry entry) async {
    //get the reference to the database
    final Database db = await database;

    //insert the dog into the correct table
    await db.insert(
      'entries',
      entry.toMap(),
      /* //If I wanted no duplicates, I would use this line
      conflictAlgorithm: ConflictAlgorithm.replace,*/
    );
  }

  //method the retrieves all the entries from the dogs table
  Future<List<Entry>> entries() async {
    //get reference
    final Database db = await database;
    //query the table for all Entries
    final List<Map<String, dynamic>> maps = await db.query('entries');
    //convert the List<Map<String, dynamic>> into a List<Dog>
    return List.generate(maps.length, (i) {
      return Entry(
        id: maps[i]['id'],
        title: maps[i]['title'],
        balance: maps[i]['balance'],
        action: maps[i]['action'],
        lastAmount: maps[i]['lastAmount'],
        date: maps[i]['date'],
        note: maps[i]['note'],
      );
    });
  }

  Future<void> updateEntry(Entry entry) async {
    //reference
    final db = await database;
    //update the given Entry
    await db.update(
      'entries',
      entry.toMap(),
      //ensure that the Entry has matching id
      where: "id = ?",
      //pass the Entry's is as a whereArg to prevent SQL injection
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteEntry(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'entries',
      // Use a `where` clause to delete a specific dog.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  /*final piggy12 = Entry(
      id: 0,
      title: "Piggy Bank",
      balance: 45.00,
      action: "Withdrew",
      lastAmount: 32.00,
      date: "09/23/2009",
      note: "huh");

  await insertEntry(piggy12);
  print(await entries());

  await updateEntry(Entry(
      id: piggy12.id,
      title: piggy12.title,
      balance: piggy12.balance + 9,
      action: piggy12.action,
      lastAmount: piggy12.lastAmount - 9,
      date: piggy12.date,
      note: piggy12.note));

  print(await entries());

  await deleteEntry(piggy12.id);
  print(await entries());*/
}

class Entry {
  int id;
  String title;
  double balance;
  String date;
  String action;
  double lastAmount;
  String note;

  Entry(
      {this.id,
      this.title,
      this.balance,
      this.date,
      this.action,
      this.lastAmount,
      this.note});

  //converts an Entry into a Map
  //the keys correspond to a column in the database
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'balance': balance,
      'date': date,
      'action': action,
      'lastAmount': lastAmount,
      'note': note
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Entry{id: $id, title: $title, date: $date, action: $action, lastAmount: $lastAmount, note: $note}';
  }
}

//data model class
/*class Entry {
  int id;
  String title;
  double balance;
  String date;
  String action;
  double lastAmount;

  Entry();

  //convenience constructor to create an Entry Object
  Entry.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    title = map[columnTitle];
    balance = map[columnBalance];
    date = map[columnDate];
    action = map[columnAction];
    lastAmount = map[columnLastAmount];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTitle: title,
      columnBalance: balance,
      columnDate: date,
      columnAction: action,
      columnLastAmount: lastAmount
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}

class DatabaseHelper {
  //This is the actual database filename that is saved in the docs directory
  static final _databaseName = "BankDatabase3.db";

  //Increment this version when you need to change the schema
  static final _databaseVersion = 1;

  //Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  //only allow a single open connection to the database
  static Database _database;
  Future<Database> get database async {
    print("1.5 _database");
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  //SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE $tableEntries (
        $columnId INTEGER PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnBalance REAL NOT NULL,
        $columnDate TEXT NOT NULL, 
        $columnAction TEXT NOT NULL,
        $columnLastAmount REAL NOT NULL)''');
  }

  //database helper methods:
  Future<int> insert(Entry entry) async {
    Database db = await database;
    int id = await db.insert(tableEntries, entry.toMap());
    return id;
  }

  Future<Entry> queryEntry(int id) async {
    Database db = await database;
    print("2 base made");
    List<Map> maps = await db.query(tableEntries,
        columns: [
          columnId,
          columnTitle,
          columnBalance,
          columnDate,
          columnAction,
          columnLastAmount
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Entry.fromMap(maps.first);
    }
    return null;
  }

  //queryAllWords()
  //delete(int id)
  //update(Entry entry)
}*/

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
//import 'package:money_tracker/database_helpers.dart';
import 'package:money_tracker/entry.dart';
import 'package:money_tracker/models/global.dart';

class TextSaver extends StatefulWidget {
  @override
  _TextSaverState createState() => _TextSaverState();
}

class _TextSaverState extends State<TextSaver> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.green, accentColor: brownColor),
      home: FutureBuilder(
          future: Hive.openBox('entries'),
          //initialData: m,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                return MyHomePage();
              }
            } else {
              //if not done yet, instead of returning
              //null, it returns an empty scaffold
              return Scaffold();
            }
          }
      )
    );
  }

  @override
  void dispose() {
    Hive.box('entries').close();
    super.dispose();
  }
}

class MyHomePage extends StatelessWidget {
  final entriesBox = Hive.box('entries');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saving data'),
      ),
      body: Column(
        children: [
          Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text('Read'),
                  onPressed: () {
                    final newEntry = Entry("account", "Withdrew", 50.00,
                        "05/07/20", "g-ma");
                    Hive.box("entries").add(newEntry);
                    //main();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text('Save'),
                  onPressed: () {
                   // _save();
                    print(entriesBox.getAt(entriesBox.length-1).balance);
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: entriesBox.length,
              itemBuilder: (context, index) {
                final entry = entriesBox.getAt(index) as Entry;
                return ListTile(
                  title: Text(entry.balance.toString()),
                  subtitle: Text(entry.note),
                );
              }
            ),
          )
        ],
      ),
    );
  }

  /*_read() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    print("0 huh?");
    int rowId = 1;
    print("1.1");
    Entry entry = await helper.queryEntry(rowId);
    print("1 Entry entry");
    if (entry == null) {
      print("read row $rowId: empty");
    } else {
      print("read row $rowId: ${entry.title} ${entry.balance} "
          "${entry.date} ${entry.action} ${entry.lastAmount}");
    }
  }

  _save() async {
    Entry entry = Entry(
        title: "Piggy Bank",
        balance: 45.00,
    action = "Withdrew",
    lastAmount = 32.00,
    date = "09/23/2009",
    );
    /*DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insert(entry);
    print("inserted row: $id");*/
  }*/
}

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker/entry.dart';
import "package:money_tracker/models/global.dart";
import "package:money_tracker/models/inner_shadow.dart";
import 'package:auto_size_text/auto_size_text.dart';
import 'package:money_tracker/bank_page.dart';

void main() async {
  //initialize Hive for directory:
  await Hive.initFlutter();
  Hive.registerAdapter(EntryAdapter());
  await Hive.openBox("accounts");
  await Hive.openBox('entry_list');
  Hive.box("accounts").values.forEach((element) {
    print(element);
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //to un-focus off of text fields when you click away
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'Money Tracker',
        theme: ThemeData(
          //the scroll overflow will be brown instead of blue
          accentColor: brownColor,
        ),
        home: Scaffold(
          backgroundColor: greenColor,
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              BankScreen(),
              _buildTitleBlock(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Container(
      height: 230,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        boxShadow: [
          new BoxShadow(
            color: Colors.black,
            blurRadius: 9.0,
            spreadRadius: 2.0,
          ),
        ],
        color: yellowColor1,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: InnerShadow(
        blur: 9,
        color: new Color(0xFFB7B797),
        offset: const Offset(0, -9),
        child: Container(
          height: 200,
          width: 350,
          decoration: BoxDecoration(
            color: yellowColor2,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                Image.asset('assets/images/money_logo.png'),
                SizedBox(height: 20),
                Text(
                  "Money Tracker",
                  style: titleFontStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///TODO: fix problem where accounts screen isn't updating
///TODO: provide check before making new bank account
///TODO: add delete option when you hold down on bank name
///TODO: add rename option when you hold down on bank name
///TODO: add text at bottom of account list to explain how to delete and rename

class BankScreen extends StatefulWidget {
  @override
  _BankScreenState createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: 300),
      reverse: false,
      //ternary operator, probably don't need this
      children: getList(),
    );
  }

  List<Widget> getList() {
    var accountBox = Hive.box("accounts");
    List<Widget> buildBoxes = [];
    for (int i = 0; i < accountBox.length; i++) {
      buildBoxes.add(BuildBox(
        infoMap: accountBox.getAt(accountBox.length - 1 - i),
      ));
    }
    buildBoxes.add(newAccount());
    return buildBoxes;
  }

  Container newAccount() {
      //add new account block (+)
      return Container(
        alignment: AlignmentDirectional.center,
        child: InkWell(
          onTap: () {
            createAlertDialog(context).then((bankTitle) {
              if(bankTitle != null && bankTitle.isNotEmpty) {
                var accountBox = Hive.box("accounts");
                var infoMap = {
                  'name': bankTitle,
                  'balance': 0.00,
                  'last_date': "",
                  'last_action': "",
                  'last_amount': 0.00,
                };
                setState(() {
                  accountBox.put(infoMap["name"], infoMap);
                });
                navigateBankPage(context, bankTitle);
              }
            });
          },
          borderRadius: BorderRadius.circular(30),
          highlightColor: yellowColor2,
          splashColor: yellowColor2,
          child: Ink(
            height: 135,
            width: 380,
            decoration: BoxDecoration(
              boxShadow: [
                new BoxShadow(
                  color: Colors.black,
                  blurRadius: 9.0,
                  spreadRadius: 2.0,
                ),
              ],
              border: Border.all(color: yellowColor1, width: 10),
              color: yellowColor3,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.add,
              color: brownColor,
              size: 70,
            ),
          ),
        ),
      );
  } //widget

  TextEditingController labelTextController = TextEditingController();

  Future<String> createAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false, //can exit by tapping outside the box
        builder: (context) {
          return AlertDialog(
            title: Text(
              "New Bank Source",
              style: TextStyle(color: brownColor),
            ),
            backgroundColor: yellowColor2,
            actionsPadding: EdgeInsets.only(right: 20.0, bottom: 10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            content: TextField(
              style: TextStyle(color: brownColor, fontSize: 20),
              controller: labelTextController,
            ),
            actions: <Widget>[
              MaterialButton(
                color: yellowColor3,
                elevation: 5.0,
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                  labelTextController.clear();
                },
              ),
              SizedBox(width: 10),
              MaterialButton(
                color: yellowColor3,
                elevation: 5.0,
                child: Text("Create"),
                onPressed: () {
                  Navigator.of(context)
                      .pop(labelTextController.text.toString());
                  labelTextController.clear();
                },
              ),
            ],
          );
        });
  }

  //what should happen when we come back to this page
  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  //to get to next screen
  void navigateBankPage(BuildContext context, String bankTitle) {
    Route route = MaterialPageRoute(builder: (context) => BankHistory(accountName: bankTitle));
    Navigator.push(context, route).then(onGoBack);
  }
} //State

class BuildBox extends StatefulWidget {
  BuildBox({this.infoMap});
  final Map infoMap;

  @override
  _BuildBoxState createState() => _BuildBoxState();
}

class _BuildBoxState extends State<BuildBox> {
  @override
  Widget build(BuildContext context) {
    Map newInfoMap = widget.infoMap;
    //for updating the infoMap during set state
    return Column(children: [
      Container(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Ink(
              height: 135,
              width: 380,
              decoration: BoxDecoration(
                boxShadow: [
                  new BoxShadow(
                    color: Colors.black,
                    blurRadius: 9.0,
                    spreadRadius: 2.0,
                  ),
                ],
                color: yellowColor3,
                border: Border.all(color: yellowColor1, width: 10),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            InkWell(
              onTap: () {
                Route route = MaterialPageRoute(builder: (context) => BankHistory(accountName: widget.infoMap["name"]));
                Navigator.push(context, route).then((value) {
                  newInfoMap = Hive.box("accounts").get(widget.infoMap["name"]);
                  setState(() {});
                });
              },
              borderRadius: BorderRadius.circular(30),
              highlightColor: yellowColor2,
              splashColor: yellowColor2,
              child: Container(
                width: 380,
                height: 135,
                padding: EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: .78,
                  heightFactor: .85,
                  child: Column(
                    children: [
                      AutoSizeText(
                        "${widget.infoMap["name"]}: \$${widget.infoMap["balance"]}",
                        style: regFontStyleBold,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "${newInfoMap["last_action"]} \$${newInfoMap["last_amount"]} on ${newInfoMap["last_date"]}",
                        style: regFontStyleBold,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 25),
    ]);
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:hive_flutter/hive_flutter.dart';
import "package:money_tracker/models/global.dart";
import 'package:auto_size_text/auto_size_text.dart';
import 'package:money_tracker/bank_page.dart';
import 'package:intl/intl.dart'; //for number format
import 'db_functions.dart';
import 'hive_adapters.dart';

void main() async {
  await hiveStart();
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
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: brownColor),
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
      height: 190,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        boxShadow: [
          new BoxShadow(
            color: darkGreenColor,
            blurRadius: 7.0,
            spreadRadius: 2.0,
          ),
        ],
        color: tanBorderColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        child: Container(
          height: 160,
          width: 350,
          decoration: BoxDecoration(
            color: innerTanColor,
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
                Image.asset('assets/images/money_logo.png', scale: 1.5),
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


class BankScreen extends StatefulWidget {
  @override
  _BankScreenState createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  late Box<Account> accountsBox;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: getAccounts().listenable(),
        builder: (context, Box<Account> _accountsBox, _) {
          accountsBox = _accountsBox;
          return ListView.builder(
              padding: EdgeInsets.only(top: 230),
              reverse: false,
              itemCount: _accountsBox.values.length + 1, //+1 for the newAccount
              itemBuilder: (BuildContext context, int index) {
                //starts at zero
                if (index == accountsBox.values.length) {
                  return newAccountCard();
                }
                String cardTitle = accountsBox.keyAt(index);
                Account cardInfo = accountsBox.getAt(index) as Account;
                return AccountCard(
                  bankTitle: cardTitle,
                  infoMap: cardInfo,
                );
              });
        });
  }

  Column newAccountCard() {
    //add new account block (+)
    return Column(children: [
      Container(
        alignment: AlignmentDirectional.center,
        child: InkWell(
          onTap: () {
            createNewAccountDialog(context).then((bankTitle) {
              if (bankTitle != null && bankTitle.isNotEmpty) {
                setState(() {
                  createNewAccount(bankTitle);
                });
                navigateBankPage(context, bankTitle);
              }
            });
          },
          borderRadius: BorderRadius.circular(30),
          highlightColor: innerTanColor,
          splashColor: innerTanColor,
          child: Ink(
            height: 135,
            width: 380,
            decoration: BoxDecoration(
              boxShadow: [
                new BoxShadow(
                  color: darkGreenColor,
                  blurRadius: 7.0,
                  spreadRadius: 2.0,
                ),
              ],
              border: Border.all(color: tanBorderColor, width: 10),
              color: darkTanColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.add,
              color: brownColor,
              size: 70,
            ),
          ),
        ),
      ),
      SizedBox(height: 25),
      Text(
        "Hold an account to access its options",
        style: regFontStyleSmallBold,
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 25),
      Text("Shmoney Technologies", style: regFontStyleSmall),
      SizedBox(height: 15),
    ]);
  } //widget

  Future createNewAccountDialog(BuildContext context) {
    TextEditingController labelTextController = TextEditingController();
    bool _validate = false;

    return showDialog(
        context: context,
        barrierDismissible: true, //can exit by tapping outside the box
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter settState) {
                return AlertDialog(
              title: Text(
                "New Bank Source",
                style: TextStyle(color: brownColor),
              ),
              backgroundColor: innerTanColor,
              actionsPadding: EdgeInsets.only(right: 20.0, bottom: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              content: TextField(
                cursorColor: brownColor,
                style: TextStyle(color: brownColor, fontSize: 20),
                controller: labelTextController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: "Name",
                  prefixStyle: inputFontStyle,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: const BorderSide(color: brownColor, width: 2),
                  ),
                  errorText: _validate ? 'Name already in use' : null,
                ),
              ),
              actions: <Widget>[
                MaterialButton(
                  color: darkTanColor,
                  elevation: 3.0,
                  child: Text("Cancel", style: buttonFontStyleBrown),
                  onPressed: () {
                    Navigator.of(context).pop();
                    labelTextController.clear();
                  },
                ),
                SizedBox(width: 10),
                MaterialButton(
                  color: darkTanColor,
                  elevation: 3.0,
                  child: Text("Create", style: buttonFontStyleBrown),
                  onPressed: () {
                    String text = labelTextController.text.toString();
                    List<String> keys = getAccounts().keys.toList().cast<String>().map((a)=>a.toLowerCase()).toList();
                    if (keys.contains(text.toLowerCase())) {
                      settState(() {
                        _validate = true;
                      });
                    } else {
                      _validate = false;
                      Navigator.of(context).pop(text);
                      labelTextController.clear();
                    }
                  },
                ),
              ],
            );
          });
        });
  }

  @override
  void dispose() {
    closeAccountsBox();
    super.dispose();
  }

  //what should happen when we come back to this page
  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  //to get to next screen
  void navigateBankPage(BuildContext context, String bankTitle) {
    Route route = MaterialPageRoute(
        builder: (context) => BankHistory(accountName: bankTitle));
    Navigator.push(context, route).then(onGoBack);
  }
} //State

class AccountCard extends StatelessWidget {
  final String bankTitle;
  final Account infoMap;
  const AccountCard({required this.infoMap, required this.bankTitle});

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat('###,###,###.00');
    var lastAction = "";
    Map<String, double> container = {'width': 380, 'height': 150};

    //replace words with symbols
    if (infoMap.lastAction == "Deposited") {
      lastAction = "+";
    } else if (infoMap.lastAction == "Withdrew") {
      //withdrew
      lastAction = "-";
    }

    //increase height based on how wide the balance is
    if (infoMap.lastAmount >= 10000000000) {
      container["height"] = 175;
    }
    return Column(children: [
      FocusedMenuHolder(
        blurSize: 2.0,
        blurBackgroundColor: reallyDarkGreen,
        menuWidth: MediaQuery.of(context).size.width * .5,
        menuOffset: 10,
        onPressed: () {},
        menuItems: <FocusedMenuItem>[
          FocusedMenuItem(
              title: Text('Rename'),
              onPressed: () {
                createRenameAccountDialog(context).then((newBankTitle) {
                  if (newBankTitle != null && newBankTitle.isNotEmpty) {
                    renameAccount(bankTitle, newBankTitle);
                  }
                });
              },
              trailingIcon: Icon(Icons.create_rounded, color: brownColor),
              backgroundColor: innerTanColor),
          FocusedMenuItem(
              title: Text('Delete'),
              onPressed: () {
                createDeleteAccountDialog(context, bankTitle).then((option) {
                  if (option != null && option == "Delete") {
                    deleteAccount(bankTitle);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: brownColor,
                          content:
                              Text('Account Deleted', style: snackFontStyle)),
                    );
                  }
                });
              },
              backgroundColor: innerTanColor,
              trailingIcon: Icon(Icons.delete, color: brownColor)),
        ],
        child: Container(
          height: container["height"],
          width: container["width"],
          decoration: BoxDecoration(
            boxShadow: [
              new BoxShadow(
                color: darkGreenColor,
                blurRadius: 7.0,
                spreadRadius: 2.0,
              ),
            ],
            color: darkTanColor,
            border: Border.all(color: tanBorderColor, width: 10),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Material(
            color: darkTanColor,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: () {
                Route route = MaterialPageRoute(
                    builder: (context) => BankHistory(accountName: bankTitle));
                Navigator.push(context, route);
              },
              borderRadius: BorderRadius.circular(20),
              highlightColor: tanBorderColor,
              splashColor: tanBorderColor,
              child: FractionallySizedBox(
                widthFactor: .88,
                heightFactor: .85,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      "$bankTitle",
                      style: regFontStyle18,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    SizedBox(
                      height: 2,
                      width: 100,
                      child: const DecoratedBox(
                        decoration: const BoxDecoration(
                          color: brownColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    AutoSizeText(
                      "\$${formatter.format(infoMap.balance)}",
                      style: regFontStyleBold,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                    SizedBox(height: 10),
                    AutoSizeText(
                      "$lastAction\$${formatter.format(infoMap.lastAmount)} on ${infoMap.lastDate}",
                      style: regFontStyle18,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: 25),
    ]);
  }

  Future createRenameAccountDialog(BuildContext context) {
    TextEditingController labelTextController = TextEditingController();
    bool _validate = false;

    return showDialog(
        context: context,
        barrierDismissible: true, //can exit by tapping outside the box
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter settState)
          {
            return AlertDialog(
              title: Text(
                "Rename Account",
                style: TextStyle(color: brownColor),
              ),
              backgroundColor: innerTanColor,
              actionsPadding: EdgeInsets.only(right: 20.0, bottom: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              content: TextField(
                cursorColor: brownColor,
                style: TextStyle(color: brownColor, fontSize: 20),
                controller: labelTextController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: "New name",
                  prefixStyle: inputFontStyle,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: const BorderSide(color: brownColor, width: 2),
                  ),
                  errorText: _validate ? 'Name already in use' : null,
                ),
              ),
              actions: <Widget>[
                MaterialButton(
                  color: darkTanColor,
                  elevation: 3.0,
                  child: Text("Cancel", style: buttonFontStyleBrown),
                  onPressed: () {
                    Navigator.of(context).pop("");
                    labelTextController.clear();
                  },
                ),
                SizedBox(width: 10),
                MaterialButton(
                  color: darkTanColor,
                  elevation: 3.0,
                  child: Text("Rename", style: buttonFontStyleBrown),
                  onPressed: () {
                    String text = labelTextController.text.toString();
                    List<String> keys = getAccounts().keys.toList().cast<String>().map((a)=>a.toLowerCase()).toList();
                    if (keys.contains(text.toLowerCase())) {
                      settState(() {
                        _validate = true;
                      });
                    } else {
                      _validate = false;
                      Navigator.of(context).pop(text);
                      labelTextController.clear();
                    }
                  },
                ),
              ],
            );
          });
        });
  }

  Future createDeleteAccountDialog(BuildContext context, String bankTitle) {
    return showDialog(
        context: context,
        barrierDismissible: true, //can exit by tapping outside the box
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Delete Account",
              style: TextStyle(color: brownColor),
            ),
            backgroundColor: innerTanColor,
            actionsPadding: EdgeInsets.only(right: 20.0, bottom: 10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            content: Text(
                "Are you sure you want to delete $bankTitle this account?",
                style: TextStyle(color: brownColor)),
            actions: <Widget>[
              MaterialButton(
                color: darkTanColor,
                elevation: 3.0,
                child: Text("Cancel", style: buttonFontStyleBrown),
                onPressed: () {
                  Navigator.of(context).pop('Cancel');
                },
              ),
              SizedBox(width: 10),
              MaterialButton(
                color: darkTanColor,
                elevation: 3.0,
                child: Text("Delete", style: buttonFontStyleBrown),
                onPressed: () {
                  Navigator.of(context).pop('Delete');
                },
              ),
            ],
          );
        });
  }
}

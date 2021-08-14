import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import "package:money_tracker/models/global.dart";
import "package:money_tracker/models/inner_shadow.dart";
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

class BankHistory extends StatefulWidget {
  final accountName;
  BankHistory({this.accountName});
  @override
  _BankHistoryState createState() => _BankHistoryState();
}

class _BankHistoryState extends State<BankHistory> {
  bool topVisible = true;
  bool _isVisible = false; //if false then new entry, if true, then no

  @override
  Widget build(BuildContext context) {
    //await Hive.openBox('entry_list');
    //can't use await here cause function not async
    //used to have future builder here
    return Scaffold(
      backgroundColor: greenColor,
      body: Stack(
        children: [
          HistoryList(historyItems: getAccountEntries(widget.accountName)),
          _newEntryBlock(),
          _buildTitleBlock(),
        ],
      ),
    );

  }

  /*@override
  void dispose() {
    Hive.box('entry_list').close();
    super.dispose();
  }*/

  Widget _buildTitleBlock() {
    final accountBox = Hive.box("accounts");
    return Container(
      child: Visibility(
        visible: topVisible,
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Container(
              height: 230,
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
            ),
            InnerShadow(
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
              ),
            ),
            SafeArea(
              child: Container(
                height: 230,
                width: 330,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        FloatingActionButton.extended(
                          icon: Icon(
                            Icons.keyboard_backspace,
                            size: 30,
                          ),
                          splashColor: Colors.grey,
                          backgroundColor: grayColor,
                          foregroundColor: brownColor,
                          label: Text("Back"),
                          onPressed: () {
                              Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    AutoSizeText(
                      (widget.accountName ?? "Null"),
                      style: titleFontStyle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    Text(
                      "${_moneyFormat(accountBox.get(widget.accountName)["balance"])}",
                      style: titleFontStyle,
                    ),
                    Spacer(
                      flex: 5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //need these outside the widget so they don't rebuild
  TextEditingController amountTextController = TextEditingController();
  TextEditingController noteTextController = TextEditingController();
  var _group = "None"; //for radio buttons: deposit or withdraw
  Widget _newEntryBlock() {
    final _formKey = GlobalKey<FormState>();
    return Container(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            height: 290,
            decoration: BoxDecoration(
              boxShadow: [
                new BoxShadow(
                  color: Colors.black,
                  blurRadius: 9.0,
                  spreadRadius: 2.0,
                ),
              ],
              color: yellowColor3,
              border: Border.all(
                color: yellowColor1,
                width: 10,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      Spacer(
                        flex: 1,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _group = "Deposited";
                                  });
                                },
                                splashColor: yellowColor2,
                                highlightColor: yellowColor2,
                                child: Ink(
                                  color: yellowColor3,
                                  child: Row(
                                    children: [
                                      Radio(
                                        value: "Deposited",
                                        activeColor: brownColor,
                                        groupValue: _group,
                                        onChanged: (action) {
                                          setState(() {
                                            _group = action;
                                          });
                                        },
                                      ),
                                      Text(
                                        "Deposit",
                                        style: regFontStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Material(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _group = "Withdrew";
                                  });
                                },
                                splashColor: yellowColor2,
                                highlightColor: yellowColor2,
                                child: Ink(
                                  color: yellowColor3,
                                  child: Row(
                                    children: [
                                      Radio(
                                        value: "Withdrew",
                                        activeColor: brownColor,
                                        groupValue: _group,
                                        onChanged: (action) {
                                          setState(() {
                                            _group = action;
                                          });
                                        },
                                      ),
                                      Text(
                                        "Withdraw",
                                        style: regFontStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Row(
                        children: [
                          Text(
                            "Amount: ",
                            style: regFontStyle,
                          ),
                          Flexible(
                            child: TextFormField(
                              style: TextStyle(color: brownColor, fontSize: 20),
                              controller: amountTextController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(5),
                                prefix: Text("\$ "),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter some text.";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          )
                        ],
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Row(
                        children: [
                          Text(
                            "Note: ",
                            style: regFontStyle,
                          ),
                          Flexible(
                            child: TextFormField(
                              style: TextStyle(color: brownColor, fontSize: 20),
                              controller: noteTextController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(5),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter some text.";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Visibility(
                        visible: _isVisible,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RaisedButton( //cancel button
                              onPressed: () {
                                amountTextController.clear();
                                noteTextController.clear();
                                setState(() {
                                  _group = "None";
                                  _isVisible = !_isVisible;
                                  topVisible = !topVisible;
                                });
                              },
                              child: Text(
                                "CANCEL",
                                style: regFontStyle,
                              ),
                              color: yellowColor2,
                              elevation: 6,
                            ),
                            Builder( //save button
                              builder: (context) => RaisedButton(
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    if (_group != "Deposited" && _group != "Withdrew") {
                                      Scaffold.of(context).showSnackBar(SnackBar(
                                          backgroundColor: brownColor,
                                          content: Text('Deposit or Withdrawal?',
                                              style:
                                              TextStyle(color: greenColor))),);
                                    } else {
                                      createAlertDialog(context).then((optionNum) {
                                        if (optionNum == 2) {
                                          final fullDate = new DateTime.now();
                                          final currentDate = "${fullDate.month}/${fullDate.day}/${fullDate.year}";
                                          final accountBox = Hive.box("accounts");
                                          if (_group == "Deposited") {
                                            accountBox.get(widget.accountName)["balance"] += double.parse(amountTextController.text);
                                          } else {
                                            accountBox.get(widget.accountName)["balance"] -= double.parse(amountTextController.text);
                                          }
                                          var entryMap = {
                                            'account': accountBox.get(widget.accountName)["name"],
                                            'last_action': _group,
                                            'last_amount': _moneyFormat(double.parse(amountTextController.text)),
                                            'last_date': currentDate,
                                            'note': noteTextController.text,
                                            'balance': _moneyFormat(accountBox.get(widget.accountName)["balance"]),
                                          };
                                          var accountMap = {
                                            'name': widget.accountName,
                                            'balance': accountBox.get(widget.accountName)["balance"],
                                            'last_date': currentDate,
                                            'last_action': _group,
                                            'last_amount': double.parse(amountTextController.text),
                                          };

                                          setState(() {
                                            Hive.box("entry_list").add(entryMap);
                                            accountBox.put(widget.accountName, accountMap);

                                            _group = "None";
                                            _isVisible = !_isVisible;
                                            topVisible = !topVisible;
                                          });

                                          amountTextController.clear();
                                          noteTextController.clear();
                                          Scaffold.of(context).showSnackBar(SnackBar(
                                              backgroundColor: brownColor,
                                              content: Text('Saved',
                                                  style:
                                                  TextStyle(color: greenColor))));
                                        }
                                      });
                                    }
                                  }
                                },
                                child: Text(
                                  "SAVE",
                                  style: regFontStyle,
                                ),
                                color: yellowColor2,
                                elevation: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: !_isVisible,
                        replacement: SizedBox(height: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: FlatButton(
                                onPressed: () {
                                  setState(() {
                                    topVisible = !topVisible;
                                    _isVisible = !_isVisible;
                                  });
                                },
                                highlightColor: yellowColor2,
                                splashColor: yellowColor2,
                                child: Text(
                                  "New Entry",
                                  style: subFontStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  createAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false, //can exit by tapping outside the box
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Confirm Entry",
              style: regFontStyleBold,//TextStyle(color: brownColor),
            ),
            backgroundColor: yellowColor2,
            actionsPadding: EdgeInsets.only(right: 20.0, bottom: 10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Is this what you want?\n", style: TextStyle(color: brownColor, fontSize: 18),),
                Text("$_group ${_moneyFormat(double.parse(amountTextController.text))}\n", style: TextStyle(color: brownColor, fontSize: 17),),
                Text("Note: ${noteTextController.text}", style: TextStyle(color: brownColor, fontSize: 17),),
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                color: yellowColor3,
                elevation: 5.0,
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(1);
                },
              ),
              SizedBox(width: 10),
              MaterialButton(
                color: yellowColor3,
                elevation: 5.0,
                child: Text("Save"),
                onPressed: () {
                  Navigator.of(context).pop(2);
                },
              ),
            ],
          );
        });
  }
}

class HistoryList extends StatefulWidget {
  final historyItems;
  HistoryList({this.historyItems});
  @override
  _HistoryListState createState() => _HistoryListState();
}


class _HistoryListState extends State<HistoryList> {
  //final entriesBox = Hive.box('entry_list');
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 40, right: 40, top: 320),
      child: Column(
        children: [
          Text(
            "History",
            style: regFontStyleBoldBig,
          ),
          Divider(
            height: 20,
            color: brownColor,
            thickness: 3,
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: widget.historyItems.length,
              itemBuilder: (context, index) {
                return BuildEntry(
                  hisMap: widget.historyItems[index]
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//model for each history list item
class BuildEntry extends StatelessWidget {
  BuildEntry({this.hisMap});
  final Map hisMap;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText("${hisMap["last_date"]}\nBalance: ${hisMap["balance"]}"
              "\n${hisMap["last_action"]} ${hisMap["last_amount"]} \nNote: ${hisMap["note"]}",
          style: regFontStyle,
          textAlign: TextAlign.left,),
          Divider(
            height: 35,
            color: brownColor,
            thickness: 2,
          ),
        ],
      ),
    );
  }
}

//so that I'm not calling this for each dollar sign
_moneyFormat(dollarAmount) {
  return FlutterMoneyFormatter(
      amount: dollarAmount,
      settings: MoneyFormatterSettings(
        fractionDigits: 2,
        symbolAndNumberSeparator: "",
      )
  ).output.symbolOnLeft;
}

//shortcut to get the map at the given id
Map getAccountMap(String name) {
  var accountBox = Hive.box("accounts");
  int i = 0;
  accountBox.values.forEach((element) {
    if(element["name"] == name) {
      print("3rd " + element["name"]);
      return accountBox.getAt(i);
    }
    i++;
  });

  //if that fails (it shouldn't)
  return accountBox.getAt(0);
}

//to get a list of the entries associated with the chosen account
List<Map> getAccountEntries(String name) {
  List<Map> historyItems = [];
  final entriesBox = Hive.box("entry_list");
  int i = 0;
  entriesBox.values.forEach((element) {
    if (element["account"] == name) {
      //print(entriesBox.getAt(i));
      historyItems.insert(0, element);
    }
    i++;
  });
  return historyItems;
}

//shortcut to get the map at the given id
void updateAccount(String name) {
  var accountBox = Hive.box("accounts");
  accountBox.values.forEach((element) {
    if(element["name"] == name) {
    }
  });
}
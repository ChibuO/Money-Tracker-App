import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker/hive_adapters.dart';
import "package:money_tracker/models/global.dart";
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'db_functions.dart';

class BankHistory extends StatefulWidget {
  final accountName;
  BankHistory({this.accountName});

  @override
  _BankHistoryState createState() => _BankHistoryState();
}

class _BankHistoryState extends State<BankHistory> {
  bool showInput = false;
  late Box<Transaction> bankBox = Hive.box<Transaction>(widget.accountName);

  //callback for showing the new entry block
  setVisible() {
    setState(() {
      showInput = !showInput;
    });
  }

  //if the new entry block is shown and the back button is pressed,
  //hide the new entry block
  Future<bool> _onWillPop() async {
    if (showInput) {
      setVisible();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    //await Hive.openBox('entry_list');
    //can't use await here cause function not async
    //used to have future builder here
    // bankAccount.openAccountBox();
    // openAccountBox(widget.accountName);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: darkTanColor,
        body: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                TitleBlock(accountName: widget.accountName),
                Expanded(
                  child: HistoryList(
                      accountName: widget.accountName,
                      setVisible: setVisible),
                ),
              ],
            ),
            NewEntryBlock(
                accountName: widget.accountName,
                isVisible: showInput,
                setVisible: setVisible),
          ],
        )),);
  }

  @override
  void dispose() {
    closeAccountBox(widget.accountName);
    super.dispose();
  }
}

class NewEntryBlock extends StatefulWidget {
  final TextEditingController amountTextController = TextEditingController();
  final TextEditingController noteTextController = TextEditingController();
  final accountName;
  final isVisible;
  final setVisible;
  NewEntryBlock({this.accountName, this.isVisible, this.setVisible});
  @override
  _NewEntryBlockState createState() => _NewEntryBlockState();
}

class _NewEntryBlockState extends State<NewEntryBlock> {
  bool selected = false;

  String _group = "None";
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return AnimatedPositioned(
      top: widget.isVisible ? 35 : -370,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      child: Container(
        height: 360,
        width: 380,
        decoration: BoxDecoration(
          boxShadow: [
            new BoxShadow(
              color: tanShadowColor,
              blurRadius: 5.0,
              spreadRadius: 2.0,
            ),
          ],
          color: darkTanColor,
          border: Border.all(
            color: tanBorderColor,
            width: 10,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
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
                          splashColor: tanShadowColor,
                          highlightColor: tanShadowColor,
                          child: Ink(
                            color: darkTanColor,
                            child: Row(
                              children: [
                                Radio(
                                  value: "Deposited",
                                  activeColor: brownColor,
                                  groupValue: _group,
                                  onChanged: (action) {
                                    setState(() {
                                      _group = action.toString();
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
                          splashColor: tanShadowColor,
                          highlightColor: tanShadowColor,
                          child: Ink(
                            color: darkTanColor,
                            child: Row(
                              children: [
                                Radio(
                                  value: "Withdrew",
                                  activeColor: brownColor,
                                  groupValue: _group,
                                  onChanged: (action) {
                                    setState(() {
                                      _group = action.toString();
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
                TextFormField(
                  cursorColor: brownColor,
                  style: inputFontStyle,
                  controller: widget.amountTextController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    prefix: Text("\$ "),
                    labelText: "Amount",
                    labelStyle: regFontStyle,
                    prefixStyle: inputFontStyle,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: brownColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter some text.";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  cursorColor: brownColor,
                  style: inputFontStyle,
                  controller: widget.noteTextController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Note",
                    labelStyle: regFontStyle,
                    prefixStyle: inputFontStyle,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: brownColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter some text.";
                    } else {
                      return null;
                    }
                  },
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      //cancel button
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(tanShadowColor),
                      ),
                      onPressed: () {
                        widget.amountTextController.clear();
                        widget.noteTextController.clear();
                        widget.setVisible();
                        setState(() {
                          _group = "None";
                        });
                      },
                      child: Text(
                        "CANCEL",
                        style: regFontStyle,
                      ),
                    ),
                    Builder(
                      //save button
                      builder: (context) => TextButton(
                        style: ButtonStyle(
                          overlayColor:
                              MaterialStateProperty.all(tanShadowColor),
                        ),
                        onPressed: () {
                          submitEntry(_formKey, context);
                        },
                        child: Text(
                          "SAVE",
                          style: regFontStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submitEntry(GlobalKey<FormState> formKey, BuildContext context) {
    //validate form
    if (formKey.currentState!.validate()) {
      // show message if radio button not selected
      if (_group != "Deposited" && _group != "Withdrew") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: brownColor,
              content: Text('Deposit or Withdrawal?', style: snackFontStyle)),
        );
      } else {
        //form is okay, now show confirmation popup
        createAlertDialog(context).then((optionNum) {
          if (optionNum == 2) {
            var infoMap = {
              'action': _group,
              'amount': double.parse(widget.amountTextController.text),
              'note': widget.noteTextController.text,
            };

            setState(() {
              addTransaction(widget.accountName, infoMap);
              _group = "None";
            });

            widget.amountTextController.clear();
            widget.noteTextController.clear();
            widget.setVisible();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: brownColor,
                content: Text('Saved', style: snackFontStyle)));
          }
        });
      }
    }
  }

  createAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false, //can exit by tapping outside the box
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Confirm Entry",
              style: regFontStyleBold, //TextStyle(color: brownColor),
            ),
            backgroundColor: innerTanColor,
            actionsPadding: EdgeInsets.only(right: 20.0, bottom: 10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$_group ${_moneyFormat(double.parse(widget.amountTextController.text))}\n",
                  style: TextStyle(color: brownColor, fontSize: 18),
                ),
                Text(
                  "Note: ${widget.noteTextController.text}",
                  style: TextStyle(color: brownColor, fontSize: 18),
                ),
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                color: darkTanColor,
                elevation: 5.0,
                child: Text("Cancel", style: buttonFontStyleBrown),
                onPressed: () {
                  Navigator.of(context).pop(1);
                },
              ),
              SizedBox(width: 10),
              MaterialButton(
                color: darkTanColor,
                elevation: 5.0,
                child: Text("Save", style: buttonFontStyleBrown),
                onPressed: () {
                  Navigator.of(context).pop(2);
                },
              ),
            ],
          );
        });
  }
}

class TitleBlock extends StatefulWidget {
  final String accountName;
  TitleBlock({required this.accountName});

  @override
  _TitleBlockState createState() => _TitleBlockState();
}

class _TitleBlockState extends State<TitleBlock> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 380,
        height: 120,
        padding: EdgeInsets.only(top: 5),
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: .98,
          heightFactor: .95,
          child: Container(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: FloatingActionButton(
                      child: Icon(
                        Icons.keyboard_backspace,
                        size: 30,
                      ),
                      splashColor: Colors.grey,
                      backgroundColor: grayColor,
                      foregroundColor: darkGrayColor,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  AutoSizeText(
                    (widget.accountName),
                    style: regFontStyleBolder,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AutoSizeText(
                    "${_moneyFormat(getBalance(widget.accountName))}",
                    style: subFontStyle29,
                    maxLines: 1,
                  ),
                ],
              ),
              Spacer(
                flex: 1,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class HistoryList extends StatefulWidget {
  // final historyItems;
  final accountName;
  final Function setVisible;
  HistoryList({this.accountName, required this.setVisible});
  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  late Box<Transaction> transactionsBox;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: EdgeInsets.only(top: 50, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              "History",
              style: regFontStyleBoldBig,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                textStyle: buttonFontStyle,
                primary: grayColor,
                onPrimary: darkGrayColor,
                shadowColor: darkTanColor,
                shape: StadiumBorder(),
              ),
              onPressed: () {
                widget.setVisible();
              },
              child: const Text('New Entry'),
            )
          ]),
          Divider(
            height: 20,
            color: brownColor,
            thickness: 3,
          ),
          FutureBuilder<Box<Transaction>>(
            future: openAccountBox(widget.accountName), // a previously-obtained Future or null
            builder: (BuildContext context, AsyncSnapshot<Box<Transaction>> snapshot) {
              var defaultWidget = Expanded(
                  child: Container(
                    width: 380,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Spacer(flex: 2),
                        Text("Loading Transactions", style: regFontStyle),
                        SizedBox(height: 50),
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(color: brownColor),
                        ),
                        Spacer(flex: 3),
                      ],
                    ),
                  ),

                );
              if (snapshot.hasData) {
                return _actualList();
              } else if (snapshot.hasError) {
                return defaultWidget;
              } else {
                return defaultWidget;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _actualList() {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: getTransactions(widget.accountName).listenable(),
        builder: (context, Box<Transaction> _transactionsBox, _) {
          transactionsBox = _transactionsBox;
          return ListView.builder(
            padding: EdgeInsets.only(top: 10),
            itemCount: _transactionsBox.values.length,
            itemBuilder: (context, index) {
              return HistoryItem(transaction: transactionsBox.getAt(transactionsBox.length - 1 - index) as Transaction);
            },
          );
        },
      ),
    );
  }
}

//model for each history list item
class HistoryItem extends StatelessWidget {
  final Transaction transaction;
  HistoryItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: AutoSizeText(
              "${transaction.date}\nBalance: ${transaction.balance}"
              "\n${transaction.action} ${transaction.amount} \nNote: ${transaction.note}",
              style: regFontStyle,
              textAlign: TextAlign.left,
            ),
          ),
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

//so that I'm not writing this for each dollar sign
_moneyFormat(dollarAmount) {
  var formatter = NumberFormat('###,###,###.00');
  return "\$${formatter.format(dollarAmount)}";
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'hive_adapters.dart';

// file for all the Hive db functions

const String accountsBox = "accounts_list";

// Accounts List DB

Future<void> hiveStart() async {
  //initialize Hive for directory:
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(AccountAdapter());
  //open the boxes
  await Hive.openBox<Account>(accountsBox);
  debugPrint("opened box");
  //Hive.openBox('entry_list');
}

void printAccounts(Box<Account> box) {
  List printAccount(Account account) {
    return [account.balance, account.lastAction, account.lastAmount, account.lastDate];
  }

  debugPrint("---Accounts---");
  for (int i = 0; i < box.length; i++) {
    var key = box.keyAt(i);
    debugPrint("$key : ${printAccount(box.get(key) as Account)}");
  }
  debugPrint("------");
}

Box<Account> getAccounts() {
  var box = Hive.box<Account>(accountsBox);
  printAccounts(box);
  return Hive.box<Account>(accountsBox);
}

Future<void> closeAccountsBox() async {
  var box = Hive.box<Account>(accountsBox);
  await box.close();
  debugPrint("Account box closed");
}

void createNewAccount(String bankTitle) {
  var accountBox = Hive.box<Account>(accountsBox);

  // var infoMap = {
  //   'balance': 0.00,
  //   'last_date': "",
  //   'last_action': "",
  //   'last_amount': 0.00,
  // };
  final infoMap = Account()
  ..balance = 0.00
  ..lastAction = ""
  ..lastAmount = 0.00
  ..lastDate = "";

  // Account infoMap = new Account(0.00, "", 0.00, "");
  accountBox.put(bankTitle, infoMap);
  debugPrint(bankTitle);
}

void renameAccount(String oldBankTitle, String newBankTitle) async {
  var listBox = Hive.box<Account>(accountsBox);
  Account oldAccount = listBox.get(oldBankTitle) as Account;
  listBox.put(newBankTitle, oldAccount);

  //transfer data
  await Hive.openBox<Transaction>(oldBankTitle);
  var oldBox = getTransactions(oldBankTitle);
  await Hive.openBox<Transaction>(newBankTitle); //create new box
  var newBox = getTransactions(newBankTitle);
  newBox.addAll(oldBox.values);

  //delete the old one
  deleteAccount(oldBankTitle);
  debugPrint("$newBankTitle account updated");
  printAccounts(listBox);
}

void deleteAccount(String bankTitle) {
  var box = Hive.box<Account>(accountsBox);
  box.delete(bankTitle);
  Hive.deleteBoxFromDisk(bankTitle);
  debugPrint("$bankTitle account deleted");
  printAccounts(box);
}

void updateAccount(String bankTitle, double balance, String action, double amount, String date) {
  var accountsListBox = Hive.box<Account>(accountsBox);

  final accountMap = Account()
    ..balance = balance
    ..lastAction = action
    ..lastAmount = amount
    ..lastDate = date;

  accountsListBox.put(bankTitle, accountMap);
  debugPrint("account updated");
}

// Single Account DB

Future<Box<Transaction>> openAccountBox(String bankTitle) async {
  print("opening $bankTitle box");
  return await Hive.openBox<Transaction>(bankTitle);
}

Future<void> closeAccountBox(String bankTitle) async {
  var accountBox = Hive.box<Transaction>(bankTitle);
  await accountBox.close();
  debugPrint("$bankTitle box closed");
}

double getBalance(String bankTitle) {
  var accountsListBox = Hive.box<Account>(accountsBox);
  return accountsListBox.get(bankTitle)!.balance;
}

Box<Transaction> getTransactions(String bankTitle) {
  var box = Hive.box<Transaction>(bankTitle);
  debugPrint("# of transactions in $bankTitle: ${box.length}");
  return Hive.box<Transaction>(bankTitle);
}

void addTransaction(String bankTitle, Map infoMap) {
  var accountBox = Hive.box<Transaction>(bankTitle);
  var accountsListBox = Hive.box<Account>(accountsBox);

  var fullDate = new DateTime.now();
  var currentDate = "${fullDate.month}/${fullDate.day}/${fullDate.year}";
  double prevBalance = accountsListBox.get(bankTitle)!.balance;

  if (infoMap["action"] == "Deposited") {
    prevBalance += infoMap["amount"];
  } else {
    prevBalance -= infoMap["amount"];
  }

  Transaction transactionMap = new Transaction(prevBalance, infoMap["action"], infoMap["amount"], currentDate , infoMap["note"]);

  accountBox.add(transactionMap);
  updateAccount(bankTitle, prevBalance, infoMap["action"], infoMap["amount"], currentDate);
}

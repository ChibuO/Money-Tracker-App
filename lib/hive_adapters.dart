import 'package:hive/hive.dart';

part 'hive_adapters.g.dart';

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  late double balance;
  @HiveField(1)
  late String action;
  @HiveField(2)
  late double amount;
  @HiveField(3)
  late String date;
  @HiveField(4)
  late String note;

  Transaction(this.balance, this.action, this.amount, this.date, this.note);
}

@HiveType(typeId: 1)
class Account {
  @HiveField(1)
  late double balance;
  @HiveField(2)
  late String lastAction;
  @HiveField(3)
  late double lastAmount;
  @HiveField(4)
  late String lastDate;

}
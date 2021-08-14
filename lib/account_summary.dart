import 'package:hive/hive.dart';

//part 'account_summary.g.dart';

@HiveType(typeId: 1)
class Entry {
  @HiveField(0)
  final String account;
  @HiveField(1)
  final String action;
  @HiveField(2)
  final double balance;
  @HiveField(3)
  final String date;
  @HiveField(4)
  final String note;

  Entry(this.account, this.action, this.balance,
      this.date, this.note);
}
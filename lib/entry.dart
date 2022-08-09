import 'package:hive/hive.dart';

part 'entry.g.dart';

@HiveType(typeId: 0)
class Entry {
  @HiveField(0)
  late String account;
  @HiveField(1)
  late String action;
  @HiveField(2)
  late double balance;
  @HiveField(3)
  late String date;
  @HiveField(4)
  late String note;

  Entry(this.account, this.action, this.balance,
      this.date, this.note);
}
import 'package:drift/drift.dart';
import 'package:trackpense/data/constants/kjp_miscellaneous.dart';

class Payment extends Table {
  TextColumn get uuid => text().clientDefault(() => KjpMiscellaneous.uuid.v4())();
  DateTimeColumn get date => dateTime().clientDefault(() => DateTime.now())();
  TextColumn get description => text().withLength(min: 1, max: 255)();
  RealColumn get amount => real()();
  BoolColumn get isExpense => boolean()();

  @override
  Set<Column> get primaryKey => {uuid};
}

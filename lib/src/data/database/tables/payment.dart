import 'package:drift/drift.dart';
import 'package:trackpense/src/data/constants/kjp_constants.dart';

class Payment extends Table {
  TextColumn get uuid => text().clientDefault(() => KjpConstants.uuid.v4())();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().withLength(min: 1, max: 255)();
  RealColumn get amount => real()();
  BoolColumn get isExpense => boolean()();

  @override
  Set<Column> get primaryKey => {uuid};
}

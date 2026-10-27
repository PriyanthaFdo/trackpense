import 'package:drift/drift.dart';
import 'package:trackpense/core/config/app_config.dart';

class Payment extends Table {
  TextColumn get uuid => text().clientDefault(() => AppConfig.uuid.v4())();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().withLength(min: 1, max: 200)();
  RealColumn get amount => real()();
  BoolColumn get isExpense => boolean()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}

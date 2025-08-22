import 'package:flutter/material.dart';
import 'package:trackpense/src/app.dart';
import 'package:trackpense/src/data/database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();

  await database
      .into(database.payment)
      .insert(
        PaymentCompanion.insert(
          date: DateTime.now(),
          description: 'new',
          amount: 234.23421,
          isExpense: true,
        ),
      );
  final allItems = await database.select(database.payment).get();

  print('items in database: $allItems');

  runApp(const App());
}

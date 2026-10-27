import 'package:get_it/get_it.dart';
import 'package:trackpense/core/database/database.dart';
import 'package:trackpense/core/logging/app_logger.dart';
import 'package:trackpense/core/presentation/blocs/ui_bloc.dart';
import 'package:trackpense/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:trackpense/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:trackpense/features/transactions/domain/usecases/create_transaction.dart';
import 'package:trackpense/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:trackpense/features/transactions/domain/usecases/update_transaction.dart';
import 'package:trackpense/features/transactions/domain/usecases/watch_transactions.dart';
import 'package:trackpense/features/transactions/presentation/blocs/transaction_bloc.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Initializes the service locator with all dependencies.
Future<void> initServiceLocator() async {
  AppLogger.info('Initializing service locator...');

  // Register singletons
  _registerCoreServices();
  _registerDataServices();
  _registerBlocs();

  AppLogger.info('Service locator initialized successfully');
}

/// Registers core services.
void _registerCoreServices() {
  // Database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  AppLogger.debug('Core services registered');
}

/// Registers data services.
void _registerDataServices() {
  // Repositories
  getIt
    ..registerFactory<TransactionRepository>(() => TransactionRepositoryImpl(getIt<AppDatabase>()))
    // Use cases
    ..registerFactory<CreateTransaction>(() => CreateTransaction(getIt()))
    ..registerFactory<UpdateTransaction>(() => UpdateTransaction(getIt()))
    ..registerFactory<DeleteTransaction>(() => DeleteTransaction(getIt()))
    ..registerFactory<WatchTransactions>(() => WatchTransactions(getIt()));

  AppLogger.debug('Data services registered');
}

/// Registers BLoCs.
void _registerBlocs() {
  // UI BLoC
  getIt
    ..registerFactory<UiBloc>(() => UiBloc())
    ..registerFactory<TransactionBloc>(
      () => TransactionBloc(
        createTransaction: getIt(),
        updateTransaction: getIt(),
        deleteTransaction: getIt(),
        watchTransactions: getIt(),
      ),
    );

  AppLogger.debug('BLoCs registered');
}

/// Resets the service locator (useful for testing).
Future<void> resetServiceLocator() async {
  await getIt.reset();
  AppLogger.info('Service locator reset');
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpense/core/di/service_locator.dart';
import 'package:trackpense/core/logging/app_logger.dart';
import 'package:trackpense/core/navigation/app_router.dart';
import 'package:trackpense/data/blocs/ui_bloc.dart';
import 'package:trackpense/features/transactions/presentation/blocs/transaction_bloc.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      AppLogger.info('Initializing application...');
      
      // Initialize service locator
      await initServiceLocator();
      
      setState(() {
        _initialized = true;
      });
      
      AppLogger.info('Application initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize application', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<UiBloc>()),
        BlocProvider(create: (context) => getIt<TransactionBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}

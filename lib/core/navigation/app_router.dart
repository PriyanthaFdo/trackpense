import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpense/core/navigation/route_names.dart';
import 'package:trackpense/core/presentation/blocs/ui_bloc.dart';
import 'package:trackpense/core/widgets/common/loading/loading_overlay.dart';
import 'package:trackpense/features/transactions/domain/entities/transaction.dart';
import 'package:trackpense/features/transactions/presentation/pages/transaction_form_page.dart';
import 'package:trackpense/features/transactions/presentation/pages/transaction_list_page.dart';

final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return BlocListener<UiBloc, UiState>(
          listener: (context, state) {
            if (state is UiLoadingState) {
              LoadingOverlay.show(Overlay.of(context));
            } else {
              LoadingOverlay.dismiss();
            }

            if (state is UiErrorState) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      state.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Text(state.message),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: RouteNames.home,
          name: RouteNames.home,
          builder: (context, state) => const TransactionListPage(),
        ),
        GoRoute(
          path: RouteNames.transactionForm,
          name: RouteNames.transactionForm,
          builder: (context, state) {
            final transaction = state.extra as Transaction?;
            return TransactionFormPage(transaction: transaction);
          },
        ),
      ],
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpense/data/blocs/ui_bloc.dart';
import 'package:trackpense/data/models/payment_model.dart';
import 'package:trackpense/src/router/route_names.dart';
import 'package:trackpense/src/views/home_view.dart';
import 'package:trackpense/src/views/payment_form_view.dart';
import 'package:trackpense/src/widgets/loading.dart';

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
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: RouteNames.paymentForm,
          name: RouteNames.paymentForm,
          builder: (context, state) {
            final payment = state.extra as PaymentModel?;
            return PaymentFormView(payment: payment);
          },
        ),
      ],
    ),
  ],
);

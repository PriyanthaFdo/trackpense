import 'dart:async';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpense/core/extensions/string_extension.dart';

class UiBloc extends Bloc<UiEvent, UiState> {
  UiBloc() : super(UiReadyState()) {
    on<UiErrorEvent>(_handleUiErrorEvent);
    on<UiLoadingEvent>((event, emit) => emit(state.loadingState()));
    on<UiReadyEvent>((event, emit) => emit(state.readyState()));
  }

  FutureOr<void> _handleUiErrorEvent(UiErrorEvent event, Emitter<UiState> emit) {
    log(
      event.message ?? 'Error Caught in UiBloc',
      error: event.error,
      stackTrace: event.stackTrace,
    );

    String? message = event.message;
    if (message == null) {
      if (event.error is InvalidDataException) {
        final error = event.error as InvalidDataException;
        message = error.errors.entries.map((e) => '${e.key.dartGetterName} ${e.value.message}'.toSentenceCase()).join(', ');
      }
    }

    emit(state.errorState(message ?? event.error.toString()));
  }
}

// ========== Events ==========
sealed class UiEvent {}

class UiErrorEvent extends UiEvent {
  UiErrorEvent({
    this.message,
    required this.error,
    required this.stackTrace,
  });

  final String? message;
  final Object error;
  final StackTrace stackTrace;
}

class UiLoadingEvent extends UiEvent {}

class UiReadyEvent extends UiEvent {}

// ========== States ==========
sealed class UiState {
  UiErrorState errorState(String message) => UiErrorState(message);
  UiLoadingState loadingState() => UiLoadingState();
  UiReadyState readyState() => UiReadyState();
}

class UiErrorState extends UiState {
  UiErrorState(this.message, [this.title = 'Error']);

  final String message;
  final String title;
}

class UiLoadingState extends UiState {}

class UiReadyState extends UiState {}

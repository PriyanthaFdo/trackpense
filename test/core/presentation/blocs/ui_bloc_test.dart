import 'package:bloc_test/bloc_test.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackpense/core/presentation/blocs/ui_bloc.dart';

Matcher _errorWith(String message) {
  return isA<UiErrorState>().having((s) => s.message, 'message', message).having((s) => s.title, 'title', 'Error');
}

void main() {
  test('starts in UiReadyState', () {
    expect(UiBloc().state, isA<UiReadyState>());
  });

  blocTest<UiBloc, UiState>(
    'UiLoadingEvent emits UiLoadingState',
    build: UiBloc.new,
    act: (bloc) => bloc.add(UiLoadingEvent()),
    expect: () => [isA<UiLoadingState>()],
  );

  blocTest<UiBloc, UiState>(
    'UiReadyEvent emits UiReadyState',
    build: UiBloc.new,
    act: (bloc) => bloc
      ..add(UiLoadingEvent())
      ..add(UiReadyEvent()),
    expect: () => [isA<UiLoadingState>(), isA<UiReadyState>()],
  );

  group('UiErrorEvent', () {
    blocTest<UiBloc, UiState>(
      'uses the given message',
      build: UiBloc.new,
      act: (bloc) => bloc.add(UiErrorEvent(message: 'Save failed', error: Exception('x'), stackTrace: StackTrace.empty)),
      expect: () => [_errorWith('Save failed')],
    );

    blocTest<UiBloc, UiState>(
      'formats Drift validation errors when no message is given',
      build: UiBloc.new,
      act: (bloc) => bloc.add(
        UiErrorEvent(
          error: InvalidDataException('invalid', {
            const VerificationMeta('description'): const VerificationResult.failure('MUST NOT BE EMPTY'),
          }),
          stackTrace: StackTrace.empty,
        ),
      ),
      expect: () => [_errorWith('Description must not be empty')],
    );

    blocTest<UiBloc, UiState>(
      'falls back to the error text for other errors',
      build: UiBloc.new,
      act: (bloc) => bloc.add(UiErrorEvent(error: StateError('broken'), stackTrace: StackTrace.empty)),
      expect: () => [_errorWith('Bad state: broken')],
    );
  });
}

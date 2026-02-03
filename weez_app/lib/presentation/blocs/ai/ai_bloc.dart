import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/ai_repository_impl.dart';

// Events
abstract class AiEvent extends Equatable {
  const AiEvent();
  @override
  List<Object?> get props => [];
}

class AiMessageSent extends AiEvent {
  final Map<String, String> message;
  final List<Map<String, String>> history;

  const AiMessageSent({required this.message, required this.history});

  @override
  List<Object?> get props => [message, history];
}

class AiReset extends AiEvent {}

// States
abstract class AiState extends Equatable {
  const AiState();
  @override
  List<Object?> get props => [];
}

class AiInitial extends AiState {}

class AiLoading extends AiState {}

class AiSuccess extends AiState {
  final String response;
  const AiSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class AiError extends AiState {
  final String message;
  const AiError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AiBloc extends Bloc<AiEvent, AiState> {
  final AiRepository aiRepository;

  AiBloc({required this.aiRepository}) : super(AiInitial()) {
    on<AiMessageSent>(_onMessageSent);
    on<AiReset>((event, emit) => emit(AiInitial()));
  }

  Future<void> _onMessageSent(
    AiMessageSent event,
    Emitter<AiState> emit,
  ) async {
    emit(AiLoading());
    final allMessages = [...event.history, event.message];
    final result = await aiRepository.chat(allMessages);

    result.fold(
      (failure) => emit(AiError(failure.message ?? 'Unknown error')),
      (response) => emit(AiSuccess(response)),
    );
  }
}

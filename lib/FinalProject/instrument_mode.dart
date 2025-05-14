import 'package:flutter_bloc/flutter_bloc.dart';

class InstrumentState {

  bool isPianoMode;

  InstrumentState({required this.isPianoMode});

}

class InstrumentCubit extends Cubit<InstrumentState> {

  InstrumentCubit() : super(InstrumentState(isPianoMode: true));

  // method to check if piano mode
  bool isPianoMode() {
    return state.isPianoMode;
  }

  // method to toggle piano mode
  void togglePianoMode() {
    emit(InstrumentState(isPianoMode: !state.isPianoMode));
  }
}
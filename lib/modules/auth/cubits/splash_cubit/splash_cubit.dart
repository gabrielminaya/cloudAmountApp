import 'package:bloc/bloc.dart';

enum SplashState { initial, databaseSuccess, error }

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashState.initial);

  Future<void> loadDB() async {
    try {
      await Future.delayed(Duration(seconds: 1));

      emit(SplashState.databaseSuccess);
    } catch (_) {
      emit(SplashState.error);
    }
  }
}

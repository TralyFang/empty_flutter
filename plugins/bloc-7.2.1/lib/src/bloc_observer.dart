import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

class BlocObserver {
  @protected
  @mustCallSuper
  void onCreate(BlocBase bloc) {}

  @protected
  @mustCallSuper
  void onEvent(Bloc bloc, Object? event) {}

  @protected
  @mustCallSuper
  void onChange(BlocBase bloc, Change change) {}

  @protected
  @mustCallSuper
  void onTransition(Bloc bloc, Transition transition) {}

  @protected
  @mustCallSuper
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {}

  @protected
  @mustCallSuper
  void onClose(BlocBase bloc) {}
}

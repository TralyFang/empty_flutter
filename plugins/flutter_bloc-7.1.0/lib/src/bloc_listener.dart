import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

mixin BlocListenerSingleChildWidget on SingleChildWidget {}

typedef BlocWidgetListener<S> = void Function(BuildContext context, S state);

typedef BlocListenerCondition<S> = bool Function(S previous, S current);

class BlocListener<B extends BlocBase<S>, S> extends BlocListenerBase<B, S>
    with BlocListenerSingleChildWidget {
  const BlocListener({
    Key? key,
    required BlocWidgetListener<S> listener,
    B? bloc,
    /// 只有合适条件才可以注入流中
    BlocListenerCondition<S>? listenWhen,
    Widget? child,
  }) : super(
          key: key,
          child: child,
          listener: listener,
          bloc: bloc,
          listenWhen: listenWhen,
        );
}

abstract class BlocListenerBase<B extends BlocBase<S>, S>
    extends SingleChildStatefulWidget {
  const BlocListenerBase({
    Key? key,
    required this.listener,
    this.bloc,
    this.child,
    this.listenWhen,
  }) : super(key: key, child: child);

  final Widget? child;

  final B? bloc;

  final BlocWidgetListener<S> listener;

  final BlocListenerCondition<S>? listenWhen;

  @override
  SingleChildState<BlocListenerBase<B, S>> createState() =>
      _BlocListenerBaseState<B, S>();
}

class _BlocListenerBaseState<B extends BlocBase<S>, S>
    extends SingleChildState<BlocListenerBase<B, S>> {
  StreamSubscription<S>? _subscription;
  late B _bloc;
  late S _previousState;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
    _previousState = _bloc.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocListenerBase<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.read<B>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = currentBloc;
        _previousState = _bloc.state;
      }
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<B>();
    if (_bloc != bloc) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = bloc;
        _previousState = _bloc.state;
      }
      _subscribe();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    if (widget.bloc == null) context.select<B, int>(identityHashCode);
    return child!;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    /// 不对流过滤，只回调合适的流到监听中
    _subscription = _bloc.stream.listen((state) {
      if (widget.listenWhen?.call(_previousState, state) ?? true) {
        widget.listener(context, state);
      }
      _previousState = state;
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef BlocWidgetSelector<S, T> = T Function(S state);

class BlocSelector<B extends BlocBase<S>, S, T> extends StatefulWidget {
  const BlocSelector({
    Key? key,
    required this.selector,
    required this.builder,
    this.bloc,
  }) : super(key: key);

  final B? bloc;

  final BlocWidgetBuilder<T> builder;

  final BlocWidgetSelector<S, T> selector;

  @override
  State<BlocSelector<B, S, T>> createState() => _BlocSelectorState<B, S, T>();
}

class _BlocSelectorState<B extends BlocBase<S>, S, T>
    extends State<BlocSelector<B, S, T>> {
  late B _bloc;
  late T _state;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
    _state = widget.selector(_bloc.state);
  }

  @override
  void didUpdateWidget(BlocSelector<B, S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.read<B>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
      _state = widget.selector(_bloc.state);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<B>();
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = widget.selector(_bloc.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bloc == null) context.select<B, int>(identityHashCode);
    return BlocListener<B, S>(
      bloc: _bloc,
      listener: (context, state) {
        final selectedState = widget.selector(state);
        if (_state != selectedState) setState(() => _state = selectedState);
      },
      child: widget.builder(context, _state),
    );
  }
}

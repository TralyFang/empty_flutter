import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class BlocConsumer<B extends BlocBase<S>, S> extends StatefulWidget {
  const BlocConsumer({
    Key? key,
    required this.builder,
    required this.listener,
    this.bloc,
    this.buildWhen,
    this.listenWhen,
  }) : super(key: key);

  final B? bloc;

  final BlocWidgetBuilder<S> builder;

  final BlocWidgetListener<S> listener;

  final BlocBuilderCondition<S>? buildWhen;

  final BlocListenerCondition<S>? listenWhen;

  @override
  State<BlocConsumer<B, S>> createState() => _BlocConsumerState<B, S>();
}

class _BlocConsumerState<B extends BlocBase<S>, S>
    extends State<BlocConsumer<B, S>> {
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
  }

  @override
  void didUpdateWidget(BlocConsumer<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.read<B>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) _bloc = currentBloc;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<B>();
    if (_bloc != bloc) _bloc = bloc;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bloc == null) context.select<B, int>(identityHashCode);
    return BlocBuilder<B, S>(
      bloc: _bloc,
      builder: widget.builder,
      buildWhen: (previous, current) {
        if (widget.listenWhen?.call(previous, current) ?? true) {
          widget.listener(context, current);
        }
        return widget.buildWhen?.call(previous, current) ?? true;
      },
    );
  }
}

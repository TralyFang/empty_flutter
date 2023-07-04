import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

mixin BlocProviderSingleChildWidget on SingleChildWidget {}

class BlocProvider<T extends BlocBase<Object?>>
    extends SingleChildStatelessWidget with BlocProviderSingleChildWidget {
  BlocProvider({
    Key? key,
    required Create<T> create,
    this.child,
    this.lazy,
  })  : _create = create,
        _value = null,
        super(key: key, child: child);

  BlocProvider.value({
    Key? key,
    required T value,
    this.child,
  })  : _value = value,
        _create = null,
        lazy = null,
        super(key: key, child: child);

  final Widget? child;

  final bool? lazy;

  final Create<T>? _create;

  final T? _value;

  static T of<T extends BlocBase<Object?>>(
    BuildContext context, {
    bool listen = false,
  }) {
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != T) rethrow;
      throw FlutterError(
        '''
        BlocProvider.of() called with a context that does not contain a $T.
        No ancestor could be found starting from the context that was passed to BlocProvider.of<$T>().

        This can happen if the context you used comes from a widget above the BlocProvider.

        The context used was: $context
        ''',
      );
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final value = _value;
    return value != null
        ? InheritedProvider<T>.value(
            value: value,
            startListening: _startListening,
            lazy: lazy,
            child: child,
          )
        : InheritedProvider<T>(
            create: _create,
            dispose: (_, bloc) => bloc.close(),
            startListening: _startListening,
            child: child,
            lazy: lazy,
          );
  }

  static VoidCallback _startListening(
    InheritedContext<BlocBase> e,
    BlocBase value,
  ) {
    final subscription = value.stream.listen(
      (dynamic _) => e.markNeedsNotifyDependents(),
    );
    return subscription.cancel;
  }
}

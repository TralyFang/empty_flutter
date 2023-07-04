import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

mixin RepositoryProviderSingleChildWidget on SingleChildWidget {}

class RepositoryProvider<T> extends Provider<T>
    with RepositoryProviderSingleChildWidget {
  RepositoryProvider({
    Key? key,
    required Create<T> create,
    Widget? child,
    bool? lazy,
  }) : super(
          key: key,
          create: create,
          dispose: (_, __) {},
          child: child,
          lazy: lazy,
        );

  RepositoryProvider.value({
    Key? key,
    required T value,
    Widget? child,
  }) : super.value(
          key: key,
          value: value,
          child: child,
        );

  static T of<T>(BuildContext context, {bool listen = false}) {
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != T) rethrow;
      throw FlutterError(
        '''
        RepositoryProvider.of() called with a context that does not contain a repository of type $T.
        No ancestor could be found starting from the context that was passed to RepositoryProvider.of<$T>().

        This can happen if the context you used comes from a widget above the RepositoryProvider.

        The context used was: $context
        ''',
      );
    }
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/src/repository_provider.dart';
import 'package:provider/provider.dart';

class MultiRepositoryProvider extends MultiProvider {
  MultiRepositoryProvider({
    Key? key,
    required List<RepositoryProviderSingleChildWidget> providers,
    required Widget child,
  }) : super(key: key, providers: providers, child: child);
}

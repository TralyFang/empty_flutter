import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/src/bloc_provider.dart';
import 'package:provider/provider.dart';

class MultiBlocProvider extends MultiProvider {
  MultiBlocProvider({
    Key? key,
    required List<BlocProviderSingleChildWidget> providers,
    required Widget child,
  }) : super(key: key, providers: providers, child: child);
}

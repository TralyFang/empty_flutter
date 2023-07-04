import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/src/bloc_listener.dart';
import 'package:provider/provider.dart';

class MultiBlocListener extends MultiProvider {
  MultiBlocListener({
    Key? key,
    required List<BlocListenerSingleChildWidget> listeners,
    required Widget child,
  }) : super(key: key, providers: listeners, child: child);
}

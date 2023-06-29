library flutter_redux;
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'easyRX.dart';

// StoreProvider 仅仅提供of 根据context 获取状态
class StoreProvider<S> extends InheritedWidget {
  final Store<S> _store;
  const StoreProvider({
    Key? key,
    required Store<S> store,
    required Widget child,
  })   : _store = store,
        super(key: key, child: child);

  static Store<S> of<S>(BuildContext context, {bool listen = true}) {

    final provider = (listen
        ? context.dependOnInheritedWidgetOfExactType<StoreProvider<S>>()
        : context
            .getElementForInheritedWidgetOfExactType<StoreProvider<S>>()
            ?.widget) as StoreProvider<S>?;

    if (provider == null) throw StoreProviderError<StoreProvider<S>>();

    return provider._store;
  }

  @override
  bool updateShouldNotify(StoreProvider<S> oldWidget) =>
      _store != oldWidget._store;
}

/// 根据状态viewModel 构建 widget
typedef ViewModelBuilder<ViewModel> = Widget Function(
  BuildContext context,
  ViewModel vm,
);
/// 又一种状态转化为另外一种状态
typedef StoreConverter<S, ViewModel> = ViewModel Function(
  Store<S> store,
);
typedef OnInitCallback<S> = void Function(
  Store<S> store,
);
typedef OnDisposeCallback<S> = void Function(
  Store<S> store,
);
typedef IgnoreChangeTest<S> = bool Function(S state);
typedef OnWillChangeCallback<ViewModel> = void Function(
  ViewModel? previousViewModel,
  ViewModel newViewModel,
);
typedef OnDidChangeCallback<ViewModel> = void Function(
  ViewModel? previousViewModel,
  ViewModel viewModel,
);
typedef OnInitialBuildCallback<ViewModel> = void Function(ViewModel viewModel);

/// 将Store 与Widget 链接自动更新，经过中间层converter 转化为对应的状态来构建widget
/// 建立在StoreProvider 树下面
class StoreConnector<S, ViewModel> extends StatelessWidget {
  final ViewModelBuilder<ViewModel> builder;
  final StoreConverter<S, ViewModel> converter;
  final bool distinct;
  final OnInitCallback<S>? onInit;
  final OnDisposeCallback<S>? onDispose;
  final bool rebuildOnChange;
  final IgnoreChangeTest<S>? ignoreChange;
  final OnWillChangeCallback<ViewModel>? onWillChange;
  final OnDidChangeCallback<ViewModel>? onDidChange;
  final OnInitialBuildCallback<ViewModel>? onInitialBuild;
  const StoreConnector({
    Key? key,
    required this.builder,
    required this.converter,
    this.distinct = false,
    this.onInit,
    this.onDispose,
    this.rebuildOnChange = true,
    this.ignoreChange,
    this.onWillChange,
    this.onDidChange,
    this.onInitialBuild,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return _StoreStreamListener<S, ViewModel>(
      store: StoreProvider.of<S>(context),
      builder: builder,
      converter: converter,
      distinct: distinct,
      onInit: onInit,
      onDispose: onDispose,
      rebuildOnChange: rebuildOnChange,
      ignoreChange: ignoreChange,
      onWillChange: onWillChange,
      onDidChange: onDidChange,
      onInitialBuild: onInitialBuild,
    );
  }
}
class StoreBuilder<S> extends StatelessWidget {
  /// 构建一个同一性的转化器 Store<S> 对应 viewModel
  static Store<S> _identity<S>(Store<S> store) => store;
  final ViewModelBuilder<Store<S>> builder;
  final bool rebuildOnChange;
  final OnInitCallback<S>? onInit;
  final OnDisposeCallback<S>? onDispose;
  final OnWillChangeCallback<Store<S>>? onWillChange;
  final OnDidChangeCallback<Store<S>>? onDidChange;
  final OnInitialBuildCallback<Store<S>>? onInitialBuild;
  const StoreBuilder({
    Key? key,
    required this.builder,
    this.onInit,
    this.onDispose,
    this.rebuildOnChange = true,
    this.onWillChange,
    this.onDidChange,
    this.onInitialBuild,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StoreConnector<S, Store<S>>(
      builder: builder,
      converter: _identity,
      rebuildOnChange: rebuildOnChange,
      onInit: onInit,
      onDispose: onDispose,
      onWillChange: onWillChange,
      onDidChange: onDidChange,
      onInitialBuild: onInitialBuild,
    );
  }
}
class _StoreStreamListener<S, ViewModel> extends StatefulWidget {
  final ViewModelBuilder<ViewModel> builder;
  final StoreConverter<S, ViewModel> converter;
  final Store<S> store;
  /// 是否具备自动更新构建的能力，默认自动监听更新
  final bool rebuildOnChange;
  /// ture: 只有状态改变的是否才更新，false: 不做任何处理
  final bool distinct;
  final OnInitCallback<S>? onInit;
  final OnDisposeCallback<S>? onDispose;
  /// 状态变更了，是否执行重构：流被过滤了，不往下发了
  final IgnoreChangeTest<S>? ignoreChange;
  final OnWillChangeCallback<ViewModel>? onWillChange;
  final OnDidChangeCallback<ViewModel>? onDidChange;
  final OnInitialBuildCallback<ViewModel>? onInitialBuild;
  const _StoreStreamListener({
    Key? key,
    required this.builder,
    required this.store,
    required this.converter,
    this.distinct = false,
    this.onInit,
    this.onDispose,
    this.rebuildOnChange = true,
    this.ignoreChange,
    this.onWillChange,
    this.onDidChange,
    this.onInitialBuild,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _StoreStreamListenerState<S, ViewModel>();
  }
}
class _StoreStreamListenerState<S, ViewModel>
    extends State<_StoreStreamListener<S, ViewModel>> {
  late Stream<ViewModel> _stream;
  ViewModel? _latestValue;
  ConverterError? _latestError;
  @override
  void initState() {
    widget.onInit?.call(widget.store);
    _computeLatestValue();
    if (widget.onInitialBuild != null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        widget.onInitialBuild!(_latestValue!);
      });
    }
    _createStream();
    super.initState();
  }
  @override
  void dispose() {
    widget.onDispose?.call(widget.store);
    super.dispose();
  }
  @override
  void didUpdateWidget(_StoreStreamListener<S, ViewModel> oldWidget) {
    _computeLatestValue();
    if (widget.store != oldWidget.store) {
      _createStream();
    }
    super.didUpdateWidget(oldWidget);
  }
  /// 计算最新的状态
  void _computeLatestValue() {
    try {
      _latestError = null;
      _latestValue = widget.converter(widget.store);
    } catch (e, s) {
      _latestValue = null;
      _latestError = ConverterError(e, s);
    }
  }
  @override
  Widget build(BuildContext context) {
    return widget.rebuildOnChange
        ? StreamBuilder<ViewModel>(
            stream: _stream,
            builder: (context, snapshot) {
              if (_latestError != null) throw _latestError!;
              return widget.builder(
                context,
                _latestValue!,
              );
            },
          )
        : _latestError != null
            ? throw _latestError!
            : widget.builder(context, _latestValue!);
  }
  ViewModel _mapConverter(S state) {
    return widget.converter(widget.store);
  }
  bool _whereDistinct(ViewModel vm) {
    if (widget.distinct) {
      return vm != _latestValue;
    }
    return true;
  }
  bool _ignoreChange(S state) {
    if (widget.ignoreChange != null) {
      return !widget.ignoreChange!(widget.store.state);
    }
    return true;
  }
  void _createStream() {
    _stream = widget.store.onChange
        .where(_ignoreChange)
        .map(_mapConverter)
        // Don't use `Stream.distinct` because it cannot capture the initial
        // ViewModel produced by the `converter`.
        .where(_whereDistinct)
        // After each ViewModel is emitted from the Stream, we update the
        // latestValue. Important: This must be done after all other optional
        // transformations, such as ignoreChange.
        .transform(StreamTransformer.fromHandlers(
          handleData: _handleChange,
          handleError: _handleError,
        ));
  }

  /// 流触发前的操作
  void _handleChange(ViewModel vm, EventSink<ViewModel> sink) {
    _latestError = null;
    widget.onWillChange?.call(_latestValue, vm);
    final previousValue = vm;
    _latestValue = vm;
    if (widget.onDidChange != null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        if (mounted) {
          /// 已经改变了，说明新的跟老的都变成了最新的。
          widget.onDidChange!(previousValue, _latestValue!);
        }
      });
    }
    sink.add(vm);
  }
  void _handleError(
    Object error,
    StackTrace stackTrace,
    EventSink<ViewModel> sink,
  ) {
    _latestValue = null;
    _latestError = ConverterError(error, stackTrace);
    sink.addError(error, stackTrace);
  }
}
class StoreProviderError<S> extends Error {
  StoreProviderError();
  @override
  String toString() {
    return '''Error: No $S found. To fix, please try:
  * Wrapping your MaterialApp with the StoreProvider<State>, 
  rather than an individual Route
  * Providing full type information to your Store<State>, 
  StoreProvider<State> and StoreConnector<State, ViewModel>
  * Ensure you are using consistent and complete imports. 
  E.g. always use `import 'package:my_app/app_state.dart';
If none of these solutions work, please file a bug at:
https://github.com/brianegan/flutter_redux/issues/new
      ''';
  }
}

/// 转化失败
class ConverterError extends Error {
  final Object error;
  @override
  final StackTrace stackTrace;
  ConverterError(this.error, this.stackTrace);
  @override
  String toString() {
    return '''Converter Function Error: $error
$stackTrace;
''';
  }
}

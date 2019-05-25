part of 'provider.dart';

/// Listens to a [Listenable], expose it to its descendants
/// and rebuilds dependents whenever the listener emits an event.
///
/// See also:
///   * [ChangeNotifierProvider], a subclass of [ListenableProvider] specific to [ChangeNotifier].
///   * [ValueListenableProvider], which listens to a [ValueListenable] but exposes only [ValueListenable.value] instead of the whole object.
///   * [Listenable]
class ListenableProvider<T extends Listenable>
    extends AdaptiveBuilderWidget<T, T> implements SingleChildCloneableWidget {
  /// Creates a [Listenable] using [builder] and subscribes to it.
  ///
  /// [dispose] can optionally passed to free resources
  /// when [ListenableProvider] is removed from the tree.
  ///
  /// [builder] must not be `null`.
  const ListenableProvider({
    Key key,
    @required ValueBuilder<T> builder,
    this.dispose,
    this.child,
  }) : super(key: key, builder: builder);

  /// Listens [listenable] and expose it to all of [ListenableProvider] descendants.
  ///
  /// Rebuilding [ListenableProvider] without
  /// changing the instance of [listenable] will not rebuild dependants.
  const ListenableProvider.value({
    Key key,
    @required T listenable,
    this.child,
  })  : dispose = null,
        super.value(key: key, value: listenable);

  /// Function used to dispose of an object created by [builder].
  ///
  /// [dispose] will be called whenever [ListenableProvider] is removed from the tree
  /// or when switching from [ListenableProvider] to [ListenableProvider.value] constructor.
  final Disposer<T> dispose;

  /// The widget that is below the current [ListenableProvider] widget in the
  /// tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  @override
  _ListenableProviderState<T> createState() => _ListenableProviderState<T>();

  @override
  ListenableProvider<T> cloneWithChild(Widget child) {
    return builder != null
        ? ListenableProvider(
            key: key,
            builder: builder,
            dispose: dispose,
            child: child,
          )
        : ListenableProvider.value(
            key: key,
            listenable: value,
            child: child,
          );
  }
}

class _ListenableProviderState<T extends Listenable>
    extends State<ListenableProvider<T>>
    with AdaptiveBuilderWidgetStateMixin<T, T, ListenableProvider<T>> {
  /// The number of time [Listenable] called its listeners.
  ///
  /// It is used to differentiate external rebuilds from rebuilds caused by the listenable emitting an event.
  /// This allows [InheritedWidget.updateShouldNotify] to return true only in the latter scenario.
  int _buildCount = 0;
  UpdateShouldNotify<T> updateShouldNotify;

  void listener() {
    setState(() {
      _buildCount++;
    });
  }

  void startListening(T listenable) {
    updateShouldNotify = createUpdateShouldNotify();
    listenable.addListener(listener);
  }

  void stopListening(T listenable) {
    listenable?.removeListener(listener);
  }

  UpdateShouldNotify<T> createUpdateShouldNotify() {
    var capturedBuildCount = _buildCount;
    return updateShouldNotify = (_, __) {
      final res = _buildCount != capturedBuildCount;
      capturedBuildCount = _buildCount;
      return res;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Provider<T>.value(
      value: value,
      child: widget.child,
      updateShouldNotify: updateShouldNotify,
    );
  }

  @override
  T didBuild(T built) {
    return built;
  }

  @override
  void disposeBuilt(ListenableProvider<T> widget, T built) {
    if (widget.dispose != null) {
      widget.dispose(context, built);
    }
  }

  @override
  void dispose() {
    stopListening(value);
    super.dispose();
  }

  @override
  void changeValue(ListenableProvider<T> oldWidget, T oldValue, T newValue) {
    if (oldValue != newValue) {
      if (oldValue != null) stopListening(oldValue);
      if (newValue != null) startListening(newValue);
    }
  }
}

Widget _listenableProviderBuilder<R extends Listenable>(
  BuildContext context,
  R value,
  Widget child,
) =>
    ListenableProvider<R>.value(listenable: value, child: child);

class ListenableProxyProvider<T, R extends Listenable>
    extends ProxyProviderBase<R> implements SingleChildCloneableWidget {
  const ListenableProxyProvider({
    Key key,
    ValueBuilder<R> initialBuilder,
    @required this.builder,
    Disposer<R> dispose,
    Widget child,
  })  : assert(builder != null),
        super.custom(
          key: key,
          initialBuilder: initialBuilder,
          providerBuilder: _listenableProviderBuilder,
          dispose: dispose,
          child: child,
        );

  final ProxyProviderBuilder<T, R> builder;

  @override
  ListenableProxyProvider<T, R> cloneWithChild(Widget child) {
    return ListenableProxyProvider(
      key: key,
      initialBuilder: initialBuilder,
      builder: builder,
      child: child,
    );
  }

  @override
  R didChangeDependencies(BuildContext context, R previous) => builder(
        context,
        Provider.of<T>(context),
        previous,
      );
}

class ListenableProxyProvider2<T, T2, R extends Listenable>
    extends ProxyProviderBase<R> implements SingleChildCloneableWidget {
  const ListenableProxyProvider2({
    Key key,
    ValueBuilder<R> initialBuilder,
    @required this.builder,
    Disposer<R> dispose,
    Widget child,
  })  : assert(builder != null),
        super.custom(
          key: key,
          initialBuilder: initialBuilder,
          providerBuilder: _listenableProviderBuilder,
          dispose: dispose,
          child: child,
        );

  final ProxyProviderBuilder2<T, T2, R> builder;

  @override
  ListenableProxyProvider2<T, T2, R> cloneWithChild(Widget child) {
    return ListenableProxyProvider2(
      key: key,
      initialBuilder: initialBuilder,
      builder: builder,
      child: child,
    );
  }

  @override
  R didChangeDependencies(BuildContext context, R previous) => builder(
        context,
        Provider.of<T>(context),
        Provider.of<T2>(context),
        previous,
      );
}

class ListenableProxyProvider3<T, T2, T3, R extends Listenable>
    extends ProxyProviderBase<R> implements SingleChildCloneableWidget {
  const ListenableProxyProvider3({
    Key key,
    ValueBuilder<R> initialBuilder,
    @required this.builder,
    Disposer<R> dispose,
    Widget child,
  })  : assert(builder != null),
        super.custom(
          key: key,
          initialBuilder: initialBuilder,
          providerBuilder: _listenableProviderBuilder,
          dispose: dispose,
          child: child,
        );

  final ProxyProviderBuilder3<T, T2, T3, R> builder;

  @override
  ListenableProxyProvider3<T, T2, T3, R> cloneWithChild(Widget child) {
    return ListenableProxyProvider3(
      key: key,
      initialBuilder: initialBuilder,
      builder: builder,
      child: child,
    );
  }

  @override
  R didChangeDependencies(BuildContext context, R previous) => builder(
        context,
        Provider.of<T>(context),
        Provider.of<T2>(context),
        Provider.of<T3>(context),
        previous,
      );
}

class ListenableProxyProvider4<T, T2, T3, T4, R extends Listenable>
    extends ProxyProviderBase<R> implements SingleChildCloneableWidget {
  const ListenableProxyProvider4({
    Key key,
    ValueBuilder<R> initialBuilder,
    @required this.builder,
    Disposer<R> dispose,
    Widget child,
  })  : assert(builder != null),
        super.custom(
          key: key,
          initialBuilder: initialBuilder,
          providerBuilder: _listenableProviderBuilder,
          dispose: dispose,
          child: child,
        );

  final ProxyProviderBuilder4<T, T2, T3, T4, R> builder;

  @override
  ListenableProxyProvider4<T, T2, T3, T4, R> cloneWithChild(Widget child) {
    return ListenableProxyProvider4(
      key: key,
      initialBuilder: initialBuilder,
      builder: builder,
      child: child,
    );
  }

  @override
  R didChangeDependencies(BuildContext context, R previous) => builder(
        context,
        Provider.of<T>(context),
        Provider.of<T2>(context),
        Provider.of<T3>(context),
        Provider.of<T4>(context),
        previous,
      );
}

class ListenableProxyProvider5<T, T2, T3, T4, T5, R extends Listenable>
    extends ProxyProviderBase<R> implements SingleChildCloneableWidget {
  const ListenableProxyProvider5({
    Key key,
    ValueBuilder<R> initialBuilder,
    @required this.builder,
    Disposer<R> dispose,
    Widget child,
  })  : assert(builder != null),
        super.custom(
          key: key,
          initialBuilder: initialBuilder,
          providerBuilder: _listenableProviderBuilder,
          dispose: dispose,
          child: child,
        );

  final ProxyProviderBuilder5<T, T2, T3, T4, T5, R> builder;

  @override
  ListenableProxyProvider5<T, T2, T3, T4, T5, R> cloneWithChild(Widget child) {
    return ListenableProxyProvider5(
      key: key,
      initialBuilder: initialBuilder,
      builder: builder,
      child: child,
    );
  }

  @override
  R didChangeDependencies(BuildContext context, R previous) => builder(
        context,
        Provider.of<T>(context),
        Provider.of<T2>(context),
        Provider.of<T3>(context),
        Provider.of<T4>(context),
        Provider.of<T5>(context),
        previous,
      );
}

class ListenableProxyProvider6<T, T2, T3, T4, T5, T6, R extends Listenable>
    extends ProxyProviderBase<R> implements SingleChildCloneableWidget {
  const ListenableProxyProvider6({
    Key key,
    ValueBuilder<R> initialBuilder,
    @required this.builder,
    Disposer<R> dispose,
    Widget child,
  })  : assert(builder != null),
        super.custom(
          key: key,
          initialBuilder: initialBuilder,
          providerBuilder: _listenableProviderBuilder,
          dispose: dispose,
          child: child,
        );

  final ProxyProviderBuilder6<T, T2, T3, T4, T5, T6, R> builder;

  @override
  ListenableProxyProvider6<T, T2, T3, T4, T5, T6, R> cloneWithChild(
      Widget child) {
    return ListenableProxyProvider6(
      key: key,
      initialBuilder: initialBuilder,
      builder: builder,
      child: child,
    );
  }

  @override
  R didChangeDependencies(BuildContext context, R previous) => builder(
        context,
        Provider.of<T>(context),
        Provider.of<T2>(context),
        Provider.of<T3>(context),
        Provider.of<T4>(context),
        Provider.of<T5>(context),
        Provider.of<T6>(context),
        previous,
      );
}

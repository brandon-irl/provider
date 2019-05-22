part of 'provider.dart';

/// Listens to a [ValueListenable] and expose its current value.
class ValueListenableProvider<T>
    extends AdaptiveBuilderWidget<ValueListenable<T>, ValueNotifier<T>>
    implements SingleChildCloneableWidget {
  /// Creates a [ValueNotifier] using [builder] and automatically dispose it
  /// when [ValueListenableProvider] is removed from the tree.
  ///
  /// [builder] must not be `null`.
  ///
  /// {@macro provider.updateshouldnotify}
  /// See also:
  ///   * [ValueListenable]
  ///   * [ListenableProvider], similar to [ValueListenableProvider] but for any kind of [Listenable].
  const ValueListenableProvider({
    Key key,
    @required ValueBuilder<ValueNotifier<T>> builder,
    this.updateShouldNotify,
    this.child,
  }) : super(key: key, builder: builder);

  /// Listens to [valueListenable] and exposes its current value.
  ///
  /// Changing [valueListenable] will stop listening to the previous [valueListenable] and listen the new one.
  /// Removing [ValueListenableProvider] from the tree will also stop listening to [valueListenable].
  ///
  /// ```dart
  /// ValueListenable<int> foo;
  ///
  /// ValueListenableProvider<int>.value(
  ///   valueListenable: foo,
  ///   child: Container(),
  /// );
  /// ```
  const ValueListenableProvider.value({
    Key key,
    @required ValueListenable<T> valueListenable,
    this.updateShouldNotify,
    this.child,
  }) : super.value(key: key, value: valueListenable);

  /// The widget that is below the current [ValueListenableProvider] widget in the
  /// tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// {@macro provider.updateshouldnotify}
  final UpdateShouldNotify<T> updateShouldNotify;

  @override
  _ValueListenableProviderState<T> createState() =>
      _ValueListenableProviderState<T>();

  @override
  ValueListenableProvider<T> cloneWithChild(Widget child) {
    return builder != null
        ? ValueListenableProvider(key: key, builder: builder, child: child)
        : ValueListenableProvider.value(
            key: key,
            valueListenable: value,
            child: child,
          );
  }
}

class _ValueListenableProviderState<T> extends State<ValueListenableProvider<T>>
    with
        AdaptiveBuilderWidgetStateMixin<ValueListenable<T>, ValueNotifier<T>,
            ValueListenableProvider<T>> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: value,
      builder: (_, value, child) {
        return Provider<T>.value(
          value: value,
          child: widget.child,
          updateShouldNotify: widget.updateShouldNotify,
        );
      },
      child: widget.child,
    );
  }

  @override
  ValueListenable<T> didBuild(ValueNotifier<T> built) {
    return built;
  }

  @override
  void disposeBuilt(
      ValueListenableProvider<T> oldWidget, ValueNotifier<T> built) {
    built.dispose();
  }
}

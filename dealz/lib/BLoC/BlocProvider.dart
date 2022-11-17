import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'BLoC.dart';

class BlocProvider<T extends Bloc> extends StatefulWidget {
  final Widget child;
  final T bloc;

  const BlocProvider({Key key, @required this.child, @required this.bloc})
      : super(key: key);

  static U of<U extends Bloc>(BuildContext context) {
    final BlocProvider<U> provider =
        context.findAncestorWidgetOfExactType<BlocProvider<U>>();
    return provider?.bloc;
  }

  @override
  State<StatefulWidget> createState() => new _BlockProviderState();
}

class _BlockProviderState extends State<BlocProvider> {
  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }
}

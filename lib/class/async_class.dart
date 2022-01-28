import 'package:asyncstate/observers/async_navigator_observer.dart';
import 'package:flutter/material.dart';

//TODO Classe static que é inicializada
late final AsyncStateClass asyncStateClass;

//TODO protected para evitar o user criar fora do package (acho que protege disso kkkk)
@protected
class AsyncStateClass<T> {
  final Widget _defaultDialog;
  BuildContext? context;
  static final _observer = AsyncNavigatorObserver();

  set setContext(BuildContext ctx) => context = ctx;

  //Static Init
  static AsyncNavigatorObserver get observer => _observer;
  static onInitAsyncState({
    required Widget defaultDialogWidget,
  }) =>
      asyncStateClass = AsyncStateClass(
        defaultDialogWidget: defaultDialogWidget,
      );
  //Constructor
  AsyncStateClass({
    required Widget defaultDialogWidget,
  }) : _defaultDialog = defaultDialogWidget;

  Future<T> callAsyncLoader(Future<T> futureFunction,
      {Widget? customLoader}) async {
    try {
      return await _callDialog(customLoader, futureFunction);
    } catch (e) {
      rethrow;
    }
  }

  Future<T> _callDialog(
    Widget? customLoader,
    Future<T> futureFunction,
  ) async {
    debugPrint('Call - ${_getStackName()}');

    //TODO Chama os dois future ao mesmo tempo .... o dialog fica até o futureFunction terminar e dar o pop.
    final futures = await Future.wait([
      showDialog(
        barrierDismissible: false,
        context: context!,
        useRootNavigator: false,
        builder: (_) => AlertDialog(
          content: customLoader ?? _defaultDialog,
        ),
      ),
      futureFunction.whenComplete(() {
        Navigator.of(context!).pop();
      }),
    ]);

    debugPrint('Close - ${_getStackName()}');
    return futures[1] as T;
  }

  String _getStackName() {
    var value = StackTrace.current.toString().split('\n');
    value.removeWhere((element) => !element.startsWith('#4'));
    return value[0].substring(2).replaceAll(' ', '');
  }
}

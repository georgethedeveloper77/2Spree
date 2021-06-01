import 'package:flutter/material.dart';
import 'package:reddigram/app.dart';
import 'package:reddigram/store/store.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart' show thunkMiddleware;

void main() {
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    /* FirebaseCrashlytics.instance.crash();*/
  };

  final store = Store<ReddigramState>(
    rootReducer,
    initialState: ReddigramState(),
    middleware: [
      (Store<ReddigramState> store, action, NextDispatcher next) {
        debugPrint(action.toString());

        next(action);
      },
      thunkMiddleware
    ],
  );

  runApp(ReddigramApp(store: store));
}

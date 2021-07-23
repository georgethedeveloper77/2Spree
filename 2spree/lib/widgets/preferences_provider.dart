import 'package:flutter/material.dart';
import 'package:reddigram/store/store.dart';

class PreferencesProvider extends InheritedWidget {
  final PreferencesState preferences;
  final Widget child;

  PreferencesProvider({@required this.preferences, @required this.child})
      : assert(preferences != null),
        assert(child != null);

  static PreferencesState of(BuildContext context) {
    /*context.dependOnInheritedWidgetOfExactType<PreferencesProvider>() as PreferencesProvider*/
    return (context.dependOnInheritedWidgetOfExactType<PreferencesProvider>())
        .preferences;
  }

  @override
  bool updateShouldNotify(PreferencesProvider oldWidget) =>
      preferences != oldWidget.preferences;
}

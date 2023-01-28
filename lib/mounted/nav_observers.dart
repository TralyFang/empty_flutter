
import 'package:flutter/material.dart';

class YBDRouteObserver extends RouteObserver<PageRoute<dynamic>> {

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    print('obs didPush setting :${route.settings.name}, pre: ${previousRoute?.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    print('obs didPop setting :${route.settings.name}, pre: ${previousRoute?.settings.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    print('obs didRemove setting :${route.settings.name}, pre: ${previousRoute?.settings.name}');
  }

  @override
  void didReplace({ Route<dynamic>? newRoute, Route<dynamic>? oldRoute }) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    print('obs didReplace setting :${newRoute?.settings.name}, pre: ${oldRoute?.settings.name}');

  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    print('obs didStartUserGesture setting :${route.settings.name}, pre: ${previousRoute?.settings.name}');

  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    print('obs didStopUserGesture');

  }

}

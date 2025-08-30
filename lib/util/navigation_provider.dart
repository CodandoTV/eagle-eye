import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';

abstract class NavigatorProvider {
  void onPop<T extends Object?>(BuildContext context, T? result);

  Future<T?> push<T extends Object?>(
    BuildContext context,
    PageRouteInfo pageRouteInfo,
  );

  void replace(BuildContext context, PageRouteInfo pageRouteInfo);
}

@Injectable(as: NavigatorProvider)
class AutoRouterNavigator extends NavigatorProvider {
  @override
  void onPop<T extends Object?>(BuildContext context, T? result) {
    AutoRouter.of(context).pop(result);
  }

  @override
  Future<T?> push<T extends Object?>(
      BuildContext context, PageRouteInfo<Object?> pageRouteInfo) {
    return AutoRouter.of(context).push(pageRouteInfo);
  }

  @override
  void replace(BuildContext context, PageRouteInfo<Object?> pageRouteInfo) {
    AutoRouter.of(context).replace(pageRouteInfo);
  }
}

import 'package:auto_route/src/route/page_route_info.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:todoapp/util/navigation_provider.dart';

class FakeNavigatorProvider extends NavigatorProvider {
  @override
  void onPop<T extends Object?>(BuildContext context, T? result) {}

  @override
  Future<T?> push<T extends Object?>(
      BuildContext context, PageRouteInfo<Object?> pageRouteInfo) {
    throw Exception('Not implemented yet');
  }

  @override
  void replace(BuildContext context, PageRouteInfo<Object?> pageRouteInfo) {}
}

import 'package:auto_route/auto_route.dart';
import 'package:todoapp/ui/todo_app_router_config.gr.dart';

@AutoRouterConfig()
class TodoAppRouterConfig extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: StartupRoute.page,
          initial: true,
          allowSnapshotting: false,
        ),
        AutoRoute(
          page: TasksRoute.page,
          allowSnapshotting: false,
        ),
        AutoRoute(
          page: TaskRoute.page,
          allowSnapshotting: false,
        ),
        AutoRoute(
          page: ChecklistsRoute.page,
          allowSnapshotting: false,
        ),
        AutoRoute(
          page: ChecklistRoute.page,
          allowSnapshotting: false,
        )
      ];
}

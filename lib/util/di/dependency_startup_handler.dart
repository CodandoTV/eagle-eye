import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:todoapp/util/di/dependency_startup_handler.config.dart';

GetIt _getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() => _getIt.init();

class GetItStartupHandlerWrapper {
  static Future<void> init() async {
    await configureDependencies();
  }

  static GetIt get getIt => _getIt;
}

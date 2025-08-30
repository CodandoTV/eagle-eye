import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/util/di/dependency_startup_handler.dart';

class StartupViewmodel extends Cubit<bool> {

  StartupViewmodel() : super(true) {
    _loadDependencies();
  }

  Future<void> _loadDependencies() async {
    await GetItStartupHandlerWrapper.init();
    await Future.delayed(const Duration(milliseconds: 500));
    emit(false);
  }
}

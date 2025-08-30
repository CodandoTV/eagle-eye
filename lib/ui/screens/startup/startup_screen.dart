import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/ui/screens/startup/startup_viewmodel.dart';
import 'package:todoapp/ui/todo_app_router_config.gr.dart';

@RoutePage()
class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = StartupViewmodel();
    return BlocProvider(
      create: (_) => viewModel,
      child: BlocBuilder<StartupViewmodel, bool>(
        builder: (context, uiState) => StartupContainer(
          isLoading: uiState,
        ),
      ),
    );
  }
}

class StartupContainer extends StatelessWidget {
  final bool isLoading;

  const StartupContainer({super.key,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading == false) {
      AutoRouter.of(context).replace(const ChecklistsRoute());
    }

    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: isLoading ? const CircularProgressIndicator() : null,
      ),
    );
  }
}

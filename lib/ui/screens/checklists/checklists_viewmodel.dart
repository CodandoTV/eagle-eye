import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:todoapp/data/model/checklist.dart';
import 'package:todoapp/data/todo_repository.dart';

import 'package:todoapp/ui/screens/checklists/checklists_screen_state.dart';

@injectable
class ChecklistsViewModel extends Cubit<ChecklistsScreenState> {
  late TodoRepository _repository;

  ChecklistsViewModel(
    TodoRepository repository,
  ) : super(
          const ChecklistsScreenState(
            checklists: [],
            isLoading: true,
          ),
        ) {
    _repository = repository;
  }

  void _onLoad() {
    emit(
      state.copyWith(isLoading: true),
    );
  }

  Future<void> updateChecklists() async {
    _onLoad();

    var checklists = await _repository.getChecklists();
    emit(
      ChecklistsScreenState(
        isLoading: false,
        checklists: checklists,
      ),
    );
  }

  Future<void> onRemoveChecklist(Checklist checklist) async {
    _onLoad();

    var result = await _repository.deleteChecklist(checklist);

    if (result) {
      List<Checklist> checklists = List.from(state.checklists);
      checklists.remove(checklist);
      emit(
        ChecklistsScreenState(
          isLoading: false,
          checklists: checklists,
        ),
      );
    }
  }
}

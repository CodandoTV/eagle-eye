import 'package:todoapp/data/model/checklist.dart';

import 'package:todoapp/data/todo_repository.dart';

class ChecklistViewModel {
  late TodoRepository _repository;

  ChecklistViewModel(TodoRepository repository) {
    _repository = repository;
  }

  bool validateChecklistName(String checklistName) {
    return checklistName.isNotEmpty;
  }

  Future<void> addChecklist({
    required String title,
  }) async {
    await _repository.addChecklist(
      Checklist(
        id: null,
        title: title,
      ),
    );
  }
}

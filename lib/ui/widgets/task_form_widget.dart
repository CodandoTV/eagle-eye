import 'package:flutter/material.dart';

import 'package:todoapp/ui/components/form_validator.dart';

class TaskFormWidget extends StatelessWidget {
  final Key formKey;
  final String taskLabel;
  final String taskErrorMessage;
  final TextEditingController taskEditingController;
  final FormScreenValidator formScreenValidator;

  const TaskFormWidget({
    super.key,
    required this.taskLabel,
    required this.taskErrorMessage,
    required this.formKey,
    required this.taskEditingController,
    required this.formScreenValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            autofocus: true,
            controller: taskEditingController,
            decoration: InputDecoration(
              labelText: taskLabel,
              labelStyle: Theme.of(context).textTheme.titleMedium,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (formScreenValidator.validateValue(value) == false) {
                return taskErrorMessage;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

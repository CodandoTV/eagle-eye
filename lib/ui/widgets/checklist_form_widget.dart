import 'package:flutter/material.dart';
import 'package:todoapp/ui/components/form_validator.dart';

class ChecklistFormWidget extends StatelessWidget {
  final Key formKey;
  final TextEditingController checklistEditingController;
  final FormScreenValidator formScreenValidator;
  final String checklistLabel;
  final String checklistErrorMessage;

  const ChecklistFormWidget({
    super.key,
    required this.formKey,
    required this.checklistLabel,
    required this.checklistErrorMessage,
    required this.checklistEditingController,
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
            controller: checklistEditingController,
            decoration: InputDecoration(
              labelText: checklistLabel,
              labelStyle: Theme.of(context).textTheme.titleMedium,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (formScreenValidator.validateValue(value) == false) {
                return checklistErrorMessage;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

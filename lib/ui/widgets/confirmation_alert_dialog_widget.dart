import 'package:flutter/material.dart';

class ConfirmationAlertDialogWidget extends StatelessWidget {
  final String title;
  final String? description;
  final String secondaryButtonText;
  final String primaryButtonText;
  final VoidCallback onSecondaryButtonPressed;
  final VoidCallback onPrimaryButtonPressed;

  const ConfirmationAlertDialogWidget({
    super.key,
    required this.title,
    this.description,
    required this.secondaryButtonText,
    required this.primaryButtonText,
    required this.onSecondaryButtonPressed,
    required this.onPrimaryButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: description != null ? Text(description!) : null,
      actions: <Widget>[
        OutlinedButton(
          onPressed: onSecondaryButtonPressed,
          child: Text(secondaryButtonText),
        ),
        FilledButton(
          onPressed: onPrimaryButtonPressed,
          child: Text(primaryButtonText),
        ),
      ],
    );
  }
}

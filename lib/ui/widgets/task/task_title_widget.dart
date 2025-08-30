import 'package:flutter/material.dart';

class TaskTitleWidget extends StatelessWidget {
  final String taskTitle;
  final bool isComplete;

  const TaskTitleWidget({
    super.key,
    required this.taskTitle,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Text(
          taskTitle,
          key: ValueKey(isComplete),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 18,
                decoration: isComplete
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                fontStyle: isComplete ? FontStyle.italic : FontStyle.normal,
              ),
        ),
      ),
    );
  }
}

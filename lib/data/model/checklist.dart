import 'package:freezed_annotation/freezed_annotation.dart';

part 'checklist.freezed.dart';

@freezed
class Checklist with _$Checklist {
  @override
  final int? id;
  @override
  final String title;

  const Checklist({
    required this.id,
    required this.title,
  });
}

import 'package:json_annotation/json_annotation.dart';

part 'LeaveTypes.g.dart';

@JsonSerializable()
class LeaveTypes{
  String name;
  LeaveTypes({required this.name,});

  factory LeaveTypes.fromJson(Map<String, dynamic> json) =>
      _$LeaveTypesFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveTypesToJson(this);
}
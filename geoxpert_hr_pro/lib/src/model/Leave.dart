import 'package:json_annotation/json_annotation.dart';

part 'Leave.g.dart';

@JsonSerializable()
class Leave{
  String leaveType;
  DateTime startDate;
  DateTime endDate;
  String status;
  bool isHalfDay;
  Leave({required this.leaveType,required this.startDate,required this.endDate,required this.status, required this.isHalfDay});

  factory Leave.fromJson(Map<String, dynamic> json) =>
      _$LeaveFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveToJson(this);
}
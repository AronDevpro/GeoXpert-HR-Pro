import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'AttendanceList.g.dart';

@JsonSerializable()
class AttendanceList {
  final String status;
  final DateTime createdAt;
  final double? totalHours;

  AttendanceList({
    required this.createdAt,
    required this.status,
    this.totalHours,
  });

  String get formattedCreatedAt {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(createdAt);
  }

  factory AttendanceList.fromJson(Map<String, dynamic> json) =>
      _$AttendanceListFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceListToJson(this);
}
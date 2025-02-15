import 'package:json_annotation/json_annotation.dart';

part 'Salary.g.dart';

@JsonSerializable()
class Salary{
  String period;
  double netSalary;
  double basicSalary;
  String status;
  Salary({required this.period,required this.netSalary,required this.basicSalary,required this.status});

  factory Salary.fromJson(Map<String, dynamic> json) =>
      _$SalaryFromJson(json);

  Map<String, dynamic> toJson() => _$SalaryToJson(this);
}
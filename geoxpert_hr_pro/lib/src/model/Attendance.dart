class Attendance {
  String? clockInTime;
  double longitude;
  double latitude;
  String? clockOutTime;
  Attendance({this.clockInTime, required this.longitude, required this.latitude, this.clockOutTime});

  Map<String, dynamic> toMap() {
    return {
      'clockInTime': clockInTime,
      'clockOutTime': clockOutTime,
      'longitude': longitude,
      'latitude': latitude,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      clockInTime: map['clockInTime'] ?? '',
      clockOutTime: map['clockOutTime'] ?? '',
      longitude: map['longitude'] ?? 0.0,
      latitude: map['latitude'] ?? 0.0,
    );
  }
}

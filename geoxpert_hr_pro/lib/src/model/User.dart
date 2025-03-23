class User {
  var id;
  String name;
  String email;
  String branch;
  String branchId;
  String role;
  String startTime;
  String endTime;
  double longitude;
  double latitude;
  int radius;
  String? photo;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.branch,
      required this.branchId,
      required this.role,
      required this.startTime,
      required this.endTime,
      required this.longitude,
      required this.latitude,
      required this.radius,
      this.photo});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'branch': branch,
      'branchId': branchId,
      'role': role,
      'startTime': startTime,
      'endTime': endTime,
      'longitude': longitude,
      'latitude': latitude,
      'radius': radius,
      'photo': photo
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        branch: map['branch'],
        branchId: map['branchId'],
        role: map['role'],
        startTime: map['startTime'],
        endTime: map['endTime'],
        longitude: map['longitude'],
        latitude: map['latitude'],
        radius: map['radius'],
        photo: map['photo']);
  }
}

class PublicSetting{
  final String siteName;
  final String logo;
  PublicSetting({required this.siteName,required this.logo,});

  factory PublicSetting.fromJson(Map<String, dynamic> json) {
    return PublicSetting(
      siteName: json['siteName'] ?? 'GeoXpert HR Pro',
      logo: json['logo'] ?? '',
    );
  }
}
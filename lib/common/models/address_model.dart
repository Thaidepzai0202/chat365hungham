class Cities {
  final int? cityId;
  final String? cityName;

  Cities({
    this.cityId,
    this.cityName,
  });

  factory Cities.fromJson(Map<String, dynamic> json) {
    return Cities(
      cityId: json["cit_id"] ?? null,
      cityName: json["cit_name"] ?? '',
    );
  }
}

class District {
  final String? districtId;
  final String? districtName;
  final String? cityId;

  District({
    this.districtId,
    this.districtName,
    this.cityId,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      districtId: '${json["cit_id"]}',
      districtName: json["cit_name"] ?? '',
      cityId: '${json['cit_parent']}',
    );
  }
}
